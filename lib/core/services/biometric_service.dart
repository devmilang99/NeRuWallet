import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> hasHardwareSupport() async {
    try {
      // isDeviceSupported() returns true if biometrics OR a PIN/passcode is available.
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isEnrolled() async {
    try {
      // canCheckBiometrics returns true if hardware is present AND biometrics are enrolled.
      final bool canCheck = await _auth.canCheckBiometrics;
      if (canCheck) return true;

      // Fallback: check the list of available biometrics directly.
      final List<BiometricType> available = await _auth
          .getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canCheckBiometrics() async {
    return await hasHardwareSupport() || await _auth.isDeviceSupported();
  }

  static Future<bool> isLockedOut() async {
    try {
      final List<BiometricType> availableBiometrics = await _auth
          .getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      // Attempt a silent authentication to check for lockout without showing UI?
      // Actually local_auth doesn't have a direct "isLocked" check without attempting auth.
      // But we can check for specific exceptions in a failed auth attempt.
      return false;
    } catch (e) {
      if (e is PlatformException) {
        return e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut';
      }
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      if (!await canCheckBiometrics()) return false;
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your wallet',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            biometricHint: 'Authenticate to continue',
          ),
          IOSAuthMessages(cancelButton: 'No thanks'),
        ],
      );
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }
}
