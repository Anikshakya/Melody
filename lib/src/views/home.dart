import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
import 'package:melody/src/views/audio_player/audio_player.dart';

class HomeView extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Obx(() {
        if (audioController.songList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: audioController.songList.length,
            itemBuilder: (context, index) {
              final song = audioController.songList[index];
              return ListTile(
                title: Text(song.title), // Use SongModel.title
                subtitle: Text(song.artist ?? 'Unknown Artist'), // Use SongModel.artist
                onTap: () {
                  audioController.currentIndex.value = index;
                  audioController.play(song.uri!); // Use SongModel.uri
                  Get.to(
                    () => AudioPlayerView(
                      initialIndex: audioController.currentIndex.value,
                    ),
                  );
                },
              );
            },
          );
        }
      }),
    );
  }
}