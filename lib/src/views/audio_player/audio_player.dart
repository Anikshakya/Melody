import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
import 'package:melody/src/helpers/common_function.dart';
import 'package:melody/src/models/audio_model.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class AudioPlayerView extends StatelessWidget {
  // Instantiate the audio controller using GetX
  final AudioController audioController = Get.put(AudioController());
  final int initialIndex;

  // Constructor to initialize the initial index of the song
  AudioPlayerView({Key? key, required this.initialIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.pop(context);
          },
          icon: const Icon(Icons.keyboard_arrow_down, size: 35),
        ),
      ),
      body: Obx(() {
        // Check if the song list is empty
        if (audioController.songList.isEmpty) {
          return const Center(child: Text('No songs available'));
        }

        // Get the current song based on the current index
        final currentSong = audioController.songList[audioController.currentIndex.value];

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the song image
            _buildSongImage(currentSong),
            // Display the song information
            _buildSongInfo(currentSong),
            // Display the duration and slider for playback
            _buildDurationAndSlider(),
            // Display play, pause, previous, and next controls
            _buildPlayPausePrevAndNext(),
            // Display shuffle and repeat controls
            _buildShuffleRepeatControls(),
          ],
        );
      }),
    );
  }

  /// Builds the widget to display the song image.
  Widget _buildSongImage(AudioModel song) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CommonFunctions().getImageWidget(
          url: song.image,
          width: 300,
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Builds the widget to display the song information (title, artist, album).
  Widget _buildSongInfo(AudioModel song) {
    return Column(
      children: [
        Text(
          song.title,
          style: Get.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          song.artist.toString(),
          style: Get.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          song.album.toString(),
          style: Get.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the play, pause, previous, and next controls.
  Widget _buildPlayPausePrevAndNext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: audioController.previous,
        ),
        IconButton(
          icon: Icon(
            audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
            size: 64,
          ),
          onPressed: () {
            // Toggle play and pause based on current state
            if (audioController.isPlaying.value) {
              audioController.pause();
            } else {
              if (audioController.currentPosition.value > Duration.zero) {
                audioController.resume();
              } else {
                audioController.play(uri: audioController.songList[audioController.currentIndex.value].uri);
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: audioController.next,
        ),
      ],
    );
  }

  /// Builds the shuffle and repeat controls.
  Widget _buildShuffleRepeatControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            audioController.isShuffle.value ? Icons.shuffle : Icons.shuffle_outlined,
            color: audioController.isShuffle.value ? Colors.deepPurple : null, // Change color based on shuffle state
          ),
          onPressed: audioController.toggleShuffle,
        ),
        IconButton(
          icon: Icon(
            audioController.isRepeat.value ? Icons.repeat_one : Icons.repeat,
            color: audioController.isRepeat.value ? Colors.deepPurple : null, // Change color based on repeat state
          ),
          onPressed: audioController.toggleRepeat,
        ),
      ],
    );
  }

  /// Builds the duration display and slider for the audio player.
  Widget _buildDurationAndSlider() {
    return StreamBuilder<PositionData>(
      stream: rxdart.Rx.combineLatest2(
        audioController.audioPlayer.positionStream,
        audioController.audioPlayer.durationStream,
        (position, duration) => PositionData(position, duration ?? Duration.zero),
      ),
      builder: (context, snapshot) {
        // Show a loading indicator while waiting for data
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final positionData = snapshot.data!;
        final position = positionData.position;
        final duration = positionData.duration;

        // Handle song completion if the song finishes playing
        _handleSongCompletion(position, duration);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)), // Display current position
                  Text(_formatDuration(duration)), // Display total duration
                ],
              ),
            ),
            Obx(() {
              return Slider(
                value: audioController.sliderPosition.value,
                min: 0.0,
                max: duration.inSeconds.toDouble(),
                onChanged: (value) {
                  audioController.sliderPosition.value = value; // Update slider position
                },
                onChangeEnd: (value) {
                  audioController.seek(Duration(seconds: value.toInt())); // Seek to the new position
                },
              );
            }),
          ],
        );
      },
    );
  }

  /// Handles song completion by checking if the song has finished playing.
  void _handleSongCompletion(Duration position, Duration duration) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (position >= duration) {
        // If the song is finished, take appropriate action based on repeat and shuffle states
        if (audioController.isRepeat.value) {
          audioController.seek(Duration.zero); // Restart the song
        } else if (audioController.isShuffle.value) {
          _playRandomSong(); // Play a random song
        } else {
          audioController.next(); // Move to the next song
        }
      }
    });
  }

  /// Plays a random song from the song list.
  void _playRandomSong() {
    final randomIndex = Random().nextInt(audioController.songList.length);
    audioController.currentIndex.value = randomIndex;
    audioController.play(uri: audioController.songList[randomIndex].uri);
  }

  /// Formats the duration into a readable string (MM:SS).
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Class to hold the position and duration of the currently playing audio.
class PositionData {
  final Duration position;
  final Duration duration;

  PositionData(this.position, this.duration);
}
