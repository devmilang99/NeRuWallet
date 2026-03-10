import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return status.isGranted;
  }

  static Future<bool> requestBiometricsPermission() async {
    // Requires local_auth package, but let's check for standard permission if applicable
    // For now, let's handle the common ones.
    return true;
  }

  static Future<void> checkInitialPermissions() async {
    // Request multiple permissions initially if needed
    await [
      Permission.camera,
      Permission.storage,
      Permission.notification,
    ].request();
  }
}
