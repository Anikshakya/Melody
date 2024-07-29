import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
import 'package:melody/src/views/main_screen.dart';
import 'package:melody/src/widgets/fade_animation_wdget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioController audioController = Get.put(AudioController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Call the onInit method to preload songs
    audioController.onInit();

    // Wait for a few seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 4));

    // Navigate to the audio list page
    Get.off(() => const MainScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 36, 109),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInUp(
              child: const Icon(
                Icons.music_note,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Melody Music Player',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
