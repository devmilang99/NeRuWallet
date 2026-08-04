import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        // Android 13+ handles storage differently
        final statuses = await [Permission.photos, Permission.videos].request();
        return statuses[Permission.photos]!.isGranted ||
            statuses[Permission.videos]!.isGranted;
      }
    }

    final status = await Permission.storage.request();
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
    var androidVersion = 0;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      androidVersion = deviceInfo.version.sdkInt;
    }

    final permissions = <Permission>[
      Permission.camera,
      Permission.notification,
    ];

    if (Platform.isAndroid && androidVersion >= 33) {
      permissions.add(Permission.photos);
      permissions.add(Permission.videos);
    } else {
      permissions.add(Permission.storage);
    }

    await permissions.request();
  }
}
