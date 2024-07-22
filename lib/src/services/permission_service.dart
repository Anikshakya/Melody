import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request storage permission
  Future requestStoragePermission() async {
    await Permission.manageExternalStorage.request();
    await Permission.audio.request();
    await Permission.videos.request();
    await Permission.photos.request();
  }
}
