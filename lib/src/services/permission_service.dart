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

    // Check current permission statuses
    final statuses = await Future.wait(permissions.map((p) => p.status));
    
    // Determine which permissions are not granted
    final permissionsToRequest = [
      for (int i = 0; i < permissions.length; i++)
        if (!statuses[i].isGranted) permissions[i]
    ];

    if (permissionsToRequest.isNotEmpty) {
      // Request permissions that are not granted
      await Future.wait(permissionsToRequest.map((p) => p.request()));
    }
  }
}
