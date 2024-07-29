import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
import 'package:melody/src/helpers/common_function.dart';
import 'package:melody/src/models/audio_model.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class AudioPlayerView extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());
  final int initialIndex;

  AudioPlayerView({Key? key, required this.initialIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        if (audioController.songList.isEmpty) {
          return const Center(child: Text('No songs available'));
        }
        // Get the current song
        final currentSong = audioController.songList[audioController.currentIndex.value];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the song image
            _buildSongImage(currentSong),
            // Display current song title, artist, and album
            _buildSongInfo(currentSong),
            // Duration and Slider
            _buildDurationAndSlider(),
            // Player controls
            _buildPlayerControls(currentSong.uri),
            // Prev and Next
            _buildPrevAndNext(),
            // Shuffle and repeat controls
            _buildShuffleRepeatControls(),
          ],
        );
      }),
    );
  }

  /// Build the widget to display the song image.
  Widget _buildSongImage(AudioModel song) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CommonFunctions().getImageWidget(
          url: song.image,
          width: 300, // Set width as per your requirement
          height: 300, // Set height as per your requirement
          fit: BoxFit.cover, // Adjust the image fit
        )
      ),
    );
  }

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

  Widget _buildPlayerControls(String uri) {
    return IconButton(
      icon: Icon(
        audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
        size: 64,
      ),
      onPressed: () {
        if (audioController.isPlaying.value) {
          audioController.pause();
        } else {
          if (audioController.currentPosition.value > Duration.zero) {
            audioController.resume();
          } else {
            audioController.play(uri: uri);
          }
        }
      },
    );
  }

  Widget _buildPrevAndNext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: audioController.previous,
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: audioController.next,
        ),
      ],
    );
  }

  Widget _buildShuffleRepeatControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            audioController.isShuffle.value ? Icons.shuffle : Icons.shuffle_outlined,
          ),
          onPressed: audioController.toggleShuffle,
        ),
        IconButton(
          icon: Icon(
            audioController.isRepeat.value ? Icons.repeat : Icons.repeat_one,
          ),
          onPressed: audioController.toggleRepeat,
        ),
      ],
    );
  }

  Widget _buildDurationAndSlider() {
    return StreamBuilder<PositionData>(
      stream: rxdart.Rx.combineLatest2(
        audioController.audioPlayer.positionStream,
        audioController.audioPlayer.durationStream,
        (position, duration) => PositionData(position, duration ?? Duration.zero),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            )
          );
        }
        final positionData = snapshot.data!;
        final position = positionData.position;
        final duration = positionData.duration;

        // Handle song completion after the build phase
        _handleSongCompletion(position, duration);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)),
                  Text(_formatDuration(duration)),
                ],
              ),
            ),
            Obx(() {
              return Slider(
                value: audioController.sliderPosition.value,
                min: 0.0,
                max: duration.inSeconds.toDouble(),
                onChanged: (value) {
                  audioController.sliderPosition.value = value;
                },
                onChangeEnd: (value) {
                  audioController.seek(Duration(seconds: value.toInt()));
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _handleSongCompletion(Duration position, Duration duration) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (position >= duration) {
        if (audioController.isRepeat.value) {
          audioController.seek(Duration.zero);
        } else if (audioController.isShuffle.value) {
          _playRandomSong();
        } else {
          audioController.next();
        }
      }
    });
  }

  void _playRandomSong() {
    final randomIndex = Random().nextInt(audioController.songList.length);
    audioController.currentIndex.value = randomIndex;
    audioController.play(uri: audioController.songList[randomIndex].uri);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class PositionData {
  final Duration position;
  final Duration duration;

  PositionData(this.position, this.duration);
}
