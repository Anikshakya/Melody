import 'package:flutter/material.dart';
import 'package:melody/src/views/audio_player/minimized_player.dart';
import 'package:melody/src/views/audio_list/audio_list_page.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          AudioList(), // Your main content
          MinimizedPlayer(), // Minimized player
        ],
      ),
    );
  }
}
