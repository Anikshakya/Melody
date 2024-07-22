import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melody/src/services/permission_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  RxList<SongModel> songList = <SongModel>[].obs;
  RxInt currentIndex = 0.obs;
  RxBool isPlaying = false.obs;
  RxBool isShuffle = false.obs;
  RxBool isRepeat = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  checkPermission() async {
    await PermissionService().requestStoragePermission();
    fetchSongs();
  }
  Future fetchSongs() async {
    final songs = await _audioQuery.querySongs();
    songList.assignAll(songs);
  }

  void play(String uri) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      _audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void pause() {
    _audioPlayer.pause();
    isPlaying.value = false;
  }

  void previous() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      play(songList[currentIndex.value].uri!);
    }
  }

  void next() {
    if (currentIndex.value < songList.length - 1) {
      currentIndex.value++;
      play(songList[currentIndex.value].uri!);
    }
  }

  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
    // Implement shuffle logic if needed
  }

  void toggleRepeat() {
    isRepeat.value = !isRepeat.value;
    // Implement repeat logic if needed
  }
}
