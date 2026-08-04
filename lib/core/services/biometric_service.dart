import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Checks if the Android version is supported (API 23+)
  static Future<bool> isAndroidVersionSupported() async {
    if (!Platform.isAndroid) return true;
    final androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 23;
  }

  /// Checks if the device has biometric hardware and if any are enrolled.
  static Future<bool> canAuthenticate() async {
    try {
      if (!await isAndroidVersionSupported()) return false;
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      return false;
    }
  }

  /// Returns a list of available biometric types (fingerprint, face, etc.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticate({
    required String title,
    required String reason,
    String localizedReason = 'Please authenticate to continue',
    String? subtitle,
    bool biometricOnly = true,
  }) async {
    try {
      // Ensure we can authenticate before showing the dialog
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      if (!canCheck && !isSupported) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: title,
            signInHint: subtitle,
            cancelButton: 'Cancel',
          ),
          const IOSAuthMessages(cancelButton: 'Cancel'),
        ],
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable' ||
          e.code == 'NotEnrolled' ||
          e.code == 'LockedOut' ||
          e.code == 'PermanentlyLockedOut') {
        // Handle specific errors if needed
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasHardwareSupport() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isEnrolled() async {
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
