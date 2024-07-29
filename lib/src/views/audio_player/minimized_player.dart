import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
import 'package:melody/src/helpers/common_function.dart';
import 'package:melody/src/models/audio_model.dart';
import 'package:melody/src/views/audio_player/audio_player.dart';
import 'package:melody/src/widgets/animated_text.dart';
import 'package:melody/src/widgets/spinner_widget.dart';

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
      if (audioController.songList.isEmpty || audioController.currentIndex.value == -1) {
        return const SizedBox.shrink(); // Hide when there's no song
      }

      return Positioned(
        bottom: 16,
        left: 16,  
        right: 16, 
        child: _buildMinimizedPlayerContainer(context),
      );
    });
  }

  /// Builds the container for the minimized player with all its components
  Widget _buildMinimizedPlayerContainer(BuildContext context) {
    final currentSong = audioController.songList[audioController.currentIndex.value];

    return Container(
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
      child: InkWell(
        onTap: _navigateToAudioPlayerView,
        child: Row(
          children: [
            const SizedBox(width: 10.0),
            _buildSongArtwork(currentSong), // Builds the song artwork widget
            const SizedBox(width: 10.0),
            _buildSongTitle(currentSong), // Builds the song title widget
            _buildPlayerControls(), // Builds the player control buttons
          ],
        ),
      ),
    );
  }

  /// Builds the song artwork widget with a spinning animation if the song is playing
  Widget _buildSongArtwork(AudioModel currentSong) {
    return SpinnerWidget(
      isPlaying: audioController.isPlaying.value,
      child: ClipOval(
        child: CommonFunctions().getImageWidget(
          url: currentSong.image,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Builds the song title widget with an animated text
  Widget _buildSongTitle(AudioModel currentSong) {
    return Expanded(
      child: AnimatedText(
        text: currentSong.title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  /// Builds the player control buttons (previous, play/pause, next, expand)
  Widget _buildPlayerControls() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          onPressed: audioController.previous, // Plays the previous song
        ),
        IconButton(
          icon: Icon(
            audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: _togglePlayPause, // Toggles play/pause
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          onPressed: audioController.next, // Plays the next song
        ),
        IconButton(
          icon: const Icon(Icons.arrow_upward, color: Colors.white),
          onPressed: _navigateToAudioPlayerView, // Expands the minimized player to full player view
        ),
      ],
    );
  }

  /// Navigates to the full audio player view with a transition
  void _navigateToAudioPlayerView() {
    Get.to(
      () => AudioPlayerView(
        initialIndex: audioController.currentIndex.value,
      ),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  /// Toggles play and pause functionality
  Future<void> _togglePlayPause() async {
    if (audioController.isPlaying.value) {
      audioController.pause();
    } else {
      final currentSong = audioController.songList[audioController.currentIndex.value];
      if (audioController.currentPosition.value > Duration.zero) {
        audioController.resume();
      } else {
        await audioController.play(uri: currentSong.uri);
      }
    }
  }
}
