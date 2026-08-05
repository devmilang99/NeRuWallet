import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:neruwallet/core/utils/logger.dart';
import 'package:safe_device/safe_device.dart';

class SecurityHardeningService {
  static const _channel = MethodChannel('com.example.neruwallet/security');

  /// Runs environment integrity checks.
  /// Returns true if the environment is secure, false otherwise.
  Future<bool> checkEnvironmentIntegrity() async {
    try {
      final isJailBroken = await FlutterJailbreakDetection.jailbroken;
      final isDeveloperMode = await FlutterJailbreakDetection.developerMode;

      // Advanced checks with safe_device
      final isRealDevice = await SafeDevice.isRealDevice;
      final isSafe = !isJailBroken && isRealDevice;

      AppLogger.i(
        'Security Check: Jailbroken: $isJailBroken, DeveloperMode: $isDeveloperMode, RealDevice: $isRealDevice',
      );

      if (!isSafe) {
        AppLogger.e('Security breach detected: Device is not secure.');
      }

      return isSafe;
    } catch (e) {
      AppLogger.e('Failed to check security environment', e);
      return false;
    }
  }

  /// Prevents screenshots and screen recording (Android only).
  /// On iOS, this should be combined with detecting [isScreenRecording].
  Future<void> setSecure(bool secure) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('setSecure', {'isSecure': secure});
      } catch (e) {
        AppLogger.e('Failed to set secure flag', e);
      }
    }
  }

  /// Checks if the screen is currently being recorded (iOS specific).
  Future<bool> isScreenRecording() async {
    if (Platform.isIOS) {
      try {
        final bool isRecording = await _channel.invokeMethod(
          'isScreenRecording',
        );
        return isRecording;
      } catch (e) {
        AppLogger.e('Failed to check screen recording status', e);
      }
    }
    return false;
  }
}
