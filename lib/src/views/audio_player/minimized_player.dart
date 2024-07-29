import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
import 'package:melody/src/views/audio_player/audio_player.dart';

class MinimizedPlayer extends StatefulWidget {
  const MinimizedPlayer({Key? key}) : super(key: key);

  @override
  State<MinimizedPlayer> createState() => _MinimizedPlayerState();
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
        bottom: 16, // Add some space from the bottom
        left: 16,   // Add some space from the left
        right: 16,  // Add some space from the right
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20), // Rounded corners
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10.0,
                offset: Offset(0, 4), // Shadow position
              ),
            ],
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const SizedBox(width: 10.0),
              // Song artwork
              ClipOval(
                child: currentSong.image != null 
                  ? Image.file(
                      File(currentSong.image!),
                      width: 40, // Set the width for the image
                      height: 40, // Set the height for the image
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.music_note, color: Colors.white, size: 40), // Placeholder icon if no image
              ),
              const SizedBox(width: 10.0),
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
                  Get.to(
                    () => AudioPlayerView(
                      initialIndex: audioController.currentIndex.value,
                    ),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
