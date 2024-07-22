import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';

class AudioPlayerView extends StatelessWidget {
  AudioController audioController = Get.put(AudioController());

  AudioPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Obx(() => Text(
            audioController.currentSong.value.split('/').last,
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 150,
                color: Colors.grey,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 64,
                onPressed: () {
                  audioController.previous();
                },
              ),
              Obx(() => IconButton(
                icon: Icon(
                  audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                ),
                iconSize: 64,
                onPressed: () {
                  if (audioController.isPlaying.value) {
                    audioController.pause();
                  } else {
                    audioController.playCurrentSong();
                  }
                },
              )),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 64,
                onPressed: () {
                  audioController.next();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon:  Icon(
                  audioController.isShuffle.value ? Icons.shuffle_on : Icons.shuffle,
                ),
                iconSize: 36,
                onPressed: () {
                  audioController.toggleShuffle();
                },
              ),
              IconButton(
                icon:  Icon(
                  audioController.isRepeat.value ? Icons.repeat_on : Icons.repeat,
                ),
                iconSize: 36,
                onPressed: () {
                  audioController.toggleRepeat();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
