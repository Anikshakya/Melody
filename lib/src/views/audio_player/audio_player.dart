import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';

class AudioPlayerView extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());
  final int initialIndex;

  AudioPlayerView({Key? key, required this.initialIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set the current index when the view is initialized
    audioController.currentIndex.value = initialIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: Obx(() {
        if (audioController.songList.isEmpty) {
          return const Center(child: Text('No songs available'));
        }

        final currentSong = audioController.songList[audioController.currentIndex.value];
        final songTitle = currentSong.title; // Use SongModel properties
        final songArtist = currentSong.artist ?? 'Unknown Artist';
        final songAlbum = currentSong.album ?? 'Unknown Album';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display current song title, artist, and album
            Text(
              songTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              songArtist,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              songAlbum,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            // Player controls
            IconButton(
              icon: Icon(
                audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                size: 64,
              ),
              onPressed: () {
                if (audioController.isPlaying.value) {
                  audioController.pause();
                } else {
                  audioController.play(currentSong.uri!); // Use SongModel.uri
                }
              },
            ),
            Row(
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
            ),
            // Shuffle and repeat controls
            Row(
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
            ),
          ],
        );
      }),
    );
  }
}
