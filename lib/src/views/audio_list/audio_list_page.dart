import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
// import 'package:melody/src/views/audio_player/audio_player.dart';

class AudioList extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());

  AudioList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Melody Music Player'),
      ),
      body: Obx(() {
        if (audioController.songList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: audioController.songList.length,
            itemBuilder: (context, index) {
              final song = audioController.songList[index];
              return Obx((){ // To show which song is playing
                  return ListTile(
                    trailing: audioController.currentIndex.value == index
                      ? const Icon(Icons.music_note, color: Colors.deepPurple) // Icon indicating the current playing song
                      : null,
                    title: Text(song.title),
                    subtitle: Text(song.artist.toString()),
                    onTap: () {
                      audioController.currentIndex.value = index;
                      audioController.play(uri: song.uri);
                      // Get.to(
                      //   () => AudioPlayerView(
                      //     initialIndex: audioController.currentIndex.value,
                      //   ),
                      //   transition: Transition.cupertinoDialog,
                      //   duration: const Duration(milliseconds: 400),
                      //   curve: Curves.easeInOut
                      // );
                    },
                  );
                }
              );
            },
          );
        }
      }),
    );
  }
}
