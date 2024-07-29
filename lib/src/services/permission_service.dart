import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request required permissions if they are not already granted
  Future<void> checkAndRequestPermissions() async {
    final permissions = [
      Permission.manageExternalStorage,
      Permission.audio,
      Permission.videos,
      Permission.photos,
      Permission.notification
    ];

    for (var permission in permissions) {
      var status = await permission.status;
      if (!status.isGranted) {
        await permission.request();
      }
    }
  }
}
