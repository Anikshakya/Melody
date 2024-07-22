import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';

class AudioController extends GetxController {
  final player = AudioPlayer();
  var isPlaying = false.obs;
  var currentSong = ''.obs;
  var songList = <String>[].obs;
  var currentIndex = 0.obs;
  var isShuffle = false.obs;
  var isRepeat = false.obs;

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }

  Future<void> play(String path) async {
    if (currentSong.value != path) {
      currentSong.value = path;
      try {
        await player.setFilePath(path);
        player.play();
        isPlaying.value = true;
      } catch (e) {
        print("Error: $e");
      }
    } else if (!isPlaying.value) {
      player.play();
      isPlaying.value = true;
    }
  }

  void pause() {
    player.pause();
    isPlaying.value = false;
  }

  void stop() {
    player.stop();
    isPlaying.value = false;
  }

  Future<List<String>> pickSongs() async {
    List<String> paths = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result != null) {
      paths = result.paths.whereType<String>().toList();
      songList.assignAll(paths);
    }
    return paths;
  }

  void next() {
    if (currentIndex.value < songList.length - 1) {
      currentIndex.value++;
    } else {
      currentIndex.value = 0;
    }
    play(songList[currentIndex.value]);
  }

  void previous() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    } else {
      currentIndex.value = songList.length - 1;
    }
    play(songList[currentIndex.value]);
  }

  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
  }

  void toggleRepeat() {
    isRepeat.value = !isRepeat.value;
  }

  void playCurrentSong() {
    if (currentSong.value.isNotEmpty) {
      play(currentSong.value);
    }
  }
}
