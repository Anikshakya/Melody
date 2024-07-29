import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melody/src/models/audio_model.dart';
import 'package:melody/src/services/permission_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class AudioController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer(); // Instance of the audio player
  final OnAudioQuery audioQuery = OnAudioQuery(); // Instance of the audio query service

  // Observable lists and variables for managing audio playback state
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
    checkPermission(); // Check for necessary permissions
    listenToAudioStreams();
  }

  // Listen To Audio Stream
  listenToAudioStreams(){
    // Listen for position updates and playback events
    audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
      sliderPosition.value = position.inSeconds.toDouble(); // Update slider position
    });

    audioPlayer.playbackEventStream.listen((event) {
      isPlaying.value = audioPlayer.playing; // Update playback state
       // Use addPostFrameCallback to avoid updates during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
          updateNotification(); // Update notification with the current song
      });
    });
    

    audioPlayer.processingStateStream.listen((state) {
      // Handle playback completion
      if (state == ProcessingState.completed) {
        if (isRepeat.value) {
          play(uri: songList[currentIndex.value].uri); // Repeat the current song
        } else {
          next(); // Move to the next song
        }
      }
    });
  }

  /// Check and request permissions for accessing audio files
  Future<void> checkPermission() async {
    await PermissionService().checkAndRequestPermissions();
    fetchSongs(); // Fetch songs after permissions are granted
  }

  /// Fetch the list of songs from the device and map them to AudioModel
  Future<void> fetchSongs() async {
    final songs = await audioQuery.querySongs(); // Query songs from the device
    songList.assignAll(await Future.wait(songs.map((song) async {
      // Retrieve and save artwork for each song
      String artworkPath = await queryNSave(
        id: song.albumId ?? 0,
        type: ArtworkType.ALBUM,
        fileName: song.title.replaceAll(' ', '_'), // Use a safe file name
      );

      return AudioModel(
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? 'Unknown Album',
        uri: song.uri!,
        image: artworkPath, // Use the saved artwork path
        duration: Duration(milliseconds: song.duration ?? 0),
        isFavourite: false,
        genre: song.genre ?? 'Unknown Genre',
        fileExtension: song.fileExtension,
        track: song.track ?? 0,
        albumId: song.albumId ?? 0,
        artistId: song.artistId ?? 0,
      );
    })));
  }

  /// Query artwork and save it to the specified path
  Future<String> queryNSave({
    required int id,
    required ArtworkType type,
    required String fileName,
    int size = 200,
    int quality = 100,
    ArtworkFormat format = ArtworkFormat.JPEG,
  }) async {
      // Get the temporary directory for the app
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path; // Use the temp directory path
      final File file = File('$tempPath/$fileName.jpg');

      // Create the directory if it doesn't exist
      if (!await file.parent.exists()) {
          await file.parent.create(recursive: true); // Create the parent directory
      }

      if (!await file.exists()) {
          await file.create(); // Create the file if it doesn't exist
          final Uint8List? image = await audioQuery.queryArtwork(
              id,
              type,
              format: format,
              size: size,
              quality: quality,
          );

          if (image != null) {
              await file.writeAsBytes(image); // Write the image to the file
          }
      }
      return file.path; // Return the path to the saved artwork
  }

  /// Play the audio from a given URI
  Future<void> play({required String uri}) async {
    try {
      if (audioPlayer.playing) {
        audioPlayer.pause(); // Pause current playback if playing
      }

      await audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(uri),
        tag: MediaItem(
          id: uri,
          title: songList[currentIndex.value].title,
          artist: songList[currentIndex.value].artist,
          album: songList[currentIndex.value].album,
          duration: songList[currentIndex.value].duration,
          artUri: Uri.file(songList[currentIndex.value].image!), // Use the image path
        ),
      ));
      await audioPlayer.play(); // Start playback
      isPlaying.value = true; // Update playback state
    } catch (e) {
      log('Error playing audio: $e'); // Log any errors
    }
  }

  /// Resume playback if paused
  Future<void> resume() async {
    try {
      await audioPlayer.play(); // Resume playback
      isPlaying.value = true; // Update playback state
    } catch (e) {
      log('Error resuming audio: $e'); // Log any errors
    }
  }

  /// Pause playback and update current position
  Future<void> pause() async {
    try {
      currentPosition.value = audioPlayer.position; // Save the current position
      await audioPlayer.pause(); // Pause playback
      isPlaying.value = false; // Update playback state
    } catch (e) {
      log('Error pausing audio: $e'); // Log any errors
    }
  }

  void previous() {
    if (currentIndex.value > 0) {
        currentIndex.value--;
        // Reset slider position only if the new song has a valid duration
        sliderPosition.value = songList[currentIndex.value].duration.inSeconds > 0
            ? 0.0
            : sliderPosition.value; 
        play(uri: songList[currentIndex.value].uri);
    }
  }

  void next() {
    if (currentIndex.value < songList.length - 1) {
        currentIndex.value++;
        // Reset slider position only if the new song has a valid duration
        sliderPosition.value = songList[currentIndex.value].duration.inSeconds > 0
            ? 0.0
            : sliderPosition.value; 
        play(uri: songList[currentIndex.value].uri);
    }
  }

  /// Update the notification with the current song details
  void updateNotification() {
    if(songList.isNotEmpty){
      final currentSong = songList[currentIndex.value];
      final mediaItem = MediaItem(
        id: currentSong.uri,
        title: currentSong.title,
        artist: currentSong.artist,
        album: currentSong.album,
        duration: currentSong.duration,
        artUri: Uri.file(currentSong.image!), // Use the image path
      );

      // Update the audio source with the current song
      AudioSource.uri(
        Uri.parse(currentSong.uri),
        tag: mediaItem,
      );
    }
  }

  /// Seek to a specific position in the audio
  void seek(Duration position) {
    audioPlayer.seek(position); // Seek to the specified position
  }

  /// Toggle shuffle mode and ensure repeat mode is disabled
  void toggleShuffle() {
    isShuffle.value = !isShuffle.value; // Toggle shuffle state
    isRepeat.value = false; // Disable repeat mode
  }

  /// Toggle repeat mode and ensure shuffle mode is disabled
  void toggleRepeat() {
    isRepeat.value = !isRepeat.value; // Toggle repeat state
    isShuffle.value = false; // Disable shuffle mode
  }
}
