import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
import 'package:melody/src/views/audio_player/audio_player.dart';

class MinimizedPlayer extends StatefulWidget {
  const MinimizedPlayer({Key? key}) : super(key: key);

  @override
  _MinimizedPlayerState createState() => _MinimizedPlayerState();
}

class _MinimizedPlayerState extends State<MinimizedPlayer> {
  final AudioController audioController = Get.find<AudioController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Only show the minimized player if there's a song and it's playing
      if (audioController.songList.isEmpty) {
        return const SizedBox.shrink(); // Hide when there's no song
      }

      final currentSong = audioController.songList[audioController.currentIndex.value];

      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Song title
              Expanded(
                child: Text(
                  currentSong.title,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () {
                  audioController.previous();
                },
              ),
              IconButton(
                icon: Icon(
                  audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (audioController.isPlaying.value) {
                    audioController.pause();
                  } else {
                    audioController.resume();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {
                  audioController.next();
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: () {
                  Get.to(() => AudioPlayerView(
                    initialIndex: audioController.currentIndex.value,
                  ));
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
