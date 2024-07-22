import 'dart:developer';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melody/src/models/audio_model.dart';
import 'package:melody/src/services/permission_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  final OnAudioQuery audioQuery = OnAudioQuery();
  
  RxList<AudioModel> songList = <AudioModel>[].obs;
  RxInt currentIndex = 0.obs;
  RxBool isPlaying = false.obs;
  RxBool isShuffle = false.obs;
  RxBool isRepeat = false.obs;
  var sliderPosition = 0.0.obs;
  Rx<Duration> currentPosition = Duration.zero.obs; // Track the current position of the audio

  @override
  void onInit() {
    super.onInit();
    checkPermission();

    // Update the current position and slider position when the position stream changes
    audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
      sliderPosition.value = position.inSeconds.toDouble();
    });

    // Update playback state when the state changes
    audioPlayer.playbackEventStream.listen((event) {
      isPlaying.value = audioPlayer.playing;
    });

    // Handle end of song based on repeat or next song settings
    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (isRepeat.value) {
          play(uri: songList[currentIndex.value].uri);
        } else {
          next();
        }
      }
    });
  }

  /// Check and request permissions for accessing audio files
  Future<void> checkPermission() async {
    await PermissionService().checkAndRequestPermissions();
    fetchSongs();
  }

  /// Fetch the list of songs from the device and map them to AudioModel
  Future<void> fetchSongs() async {
    final songs = await audioQuery.querySongs();
    songList.assignAll(songs.map((song) => AudioModel(
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      uri: song.uri!,
      image: song.title, // This may return a URI or path to the album art
      duration: Duration(milliseconds: song.duration ?? 0),
      isFavourite: false, // Default to false
      genre: song.genre ?? 'Unknown Genre',
      fileExtension: song.fileExtension,
      track: song.track ?? 0,
      albumId: song.albumId ?? 0,
      artistId: song.artistId ?? 0,
    )));
  }

  /// Play the audio from a given URI
  Future<void> play({required String uri}) async {
    try {
      if (audioPlayer.playing) {
        audioPlayer.pause(); // Pause current playback if playing
      }
      await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      log('Error playing audio: $e');
    }
  }

  /// Resume playback if paused
  Future<void> resume() async {
    try {
      await audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      log('Error resuming audio: $e');
    }
  }

  /// Pause playback and update current position
  Future<void> pause() async {
    try {
      currentPosition.value = audioPlayer.position; // Save the current position
      await audioPlayer.pause();
      isPlaying.value = false;
    } catch (e) {
      log('Error pausing audio: $e');
    }
  }

  /// Play the previous song in the list
  void previous() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      sliderPosition.value = 0.0; // Reset slider position
      play(uri: songList[currentIndex.value].uri);
    }
  }

  /// Play the next song in the list
  void next() {
    if (currentIndex.value < songList.length - 1) {
      currentIndex.value++;
      sliderPosition.value = 0.0; // Reset slider position
      play(uri: songList[currentIndex.value].uri);
    }
  }

  /// Toggle shuffle mode and ensure repeat mode is disabled
  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
    isRepeat.value = false;
    // Implement additional shuffle logic if needed
  }

  /// Toggle repeat mode and ensure shuffle mode is disabled
  void toggleRepeat() {
    isRepeat.value = !isRepeat.value;
    isShuffle.value = false;
    // Implement additional repeat logic if needed
  }

  /// Seek to a specific position in the audio
  void seek(Duration position) {
    audioPlayer.seek(position);
  }
}
