import 'dart:developer';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
  Rx<Duration> currentPosition = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();

    audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
      sliderPosition.value = position.inSeconds.toDouble();
    });

    audioPlayer.playbackEventStream.listen((event) {
      isPlaying.value = audioPlayer.playing;
      updateNotification();
    });

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

  Future<void> checkPermission() async {
    await PermissionService().checkAndRequestPermissions();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    final songs = await audioQuery.querySongs();
    songList.assignAll(songs.map((song) => AudioModel(
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      uri: song.uri!,
      image: song.title, 
      duration: Duration(milliseconds: song.duration ?? 0),
      isFavourite: false, 
      genre: song.genre ?? 'Unknown Genre',
      fileExtension: song.fileExtension,
      track: song.track ?? 0,
      albumId: song.albumId ?? 0,
      artistId: song.artistId ?? 0,
    )));
  }

  Future<void> play({required String uri}) async {
    try {
      if (audioPlayer.playing) {
        audioPlayer.pause(); 
      }
      await audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(uri),
        tag: MediaItem(
          id: uri,
          title: songList[currentIndex.value].title,
          artist: songList[currentIndex.value].artist,
          album: songList[currentIndex.value].album,
          duration: songList[currentIndex.value].duration,
          artUri: Uri.parse(songList[currentIndex.value].image!),
        ),
      ));
      await audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      log('Error playing audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      await audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      log('Error resuming audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      currentPosition.value = audioPlayer.position; 
      await audioPlayer.pause();
      isPlaying.value = false;
    } catch (e) {
      log('Error pausing audio: $e');
    }
  }

  void previous() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      sliderPosition.value = 0.0; 
      play(uri: songList[currentIndex.value].uri);
    }
  }

  void next() {
    if (currentIndex.value < songList.length - 1) {
      currentIndex.value++;
      sliderPosition.value = 0.0; 
      play(uri: songList[currentIndex.value].uri);
    }
  }

  void updateNotification() {
    final currentSong = songList[currentIndex.value];
    final mediaItem = MediaItem(
      id: currentSong.uri,
      title: currentSong.title,
      artist: currentSong.artist,
      album: currentSong.album,
      duration: currentSong.duration,
      artUri: Uri.parse(currentSong.image!),
    );

    AudioSource.uri(
      Uri.parse(currentSong.uri),
      tag: mediaItem
    );
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
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
}