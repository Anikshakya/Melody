import 'dart:developer';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melody/src/models/audio_model.dart';
import 'package:melody/src/services/permission_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import the notifications package

class AudioController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  final OnAudioQuery audioQuery = OnAudioQuery();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin(); // Create an instance of the plugin

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
    _initializeNotifications(); // Initialize notifications
    checkPermission();

    audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
      sliderPosition.value = position.inSeconds.toDouble();
      _updateNotification(); // Update notification with current position
    });

    audioPlayer.playbackEventStream.listen((event) {
      isPlaying.value = audioPlayer.playing;
      _updateNotification(); // Update notification with playback state
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

  /// Initialize notification settings
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Show or update the notification with current song details
  Future<void> _updateNotification() async {
    if (isPlaying.value) {
      final song = songList[currentIndex.value];
      await _notificationsPlugin.show(
        0, // Notification ID
        song.title,
        '${song.artist} - ${song.album}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id', // Channel ID
            'your_channel_name', // Channel name
            channelDescription: 'your_channel_description', // Channel description
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            playSound: false,
          ),
        ),
      );
    } else {
      await _notificationsPlugin.cancel(0); // Cancel notification if not playing
    }
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
      _updateNotification(); // Update notification when playback starts
    } catch (e) {
      log('Error playing audio: $e');
    }
  }

  /// Resume playback if paused
  Future<void> resume() async {
    try {
      await audioPlayer.play();
      isPlaying.value = true;
      _updateNotification(); // Update notification when playback resumes
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
      _updateNotification(); // Update notification when playback pauses
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
