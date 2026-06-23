import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _auth
          .getAvailableBiometrics();
      return canCheckBiometrics &&
          isDeviceSupported &&
          availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticate({
    String localizedReason = 'Please authenticate to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            biometricHint: 'Authenticate to continue',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(cancelButton: 'Cancel'),
        ],
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
      final List<BiometricType> available = await _auth
          .getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isLockedOut() async {
    try {
      // There's no direct way to check for lockout without trying to authenticate or checking available biometrics
      // But we can check if available biometrics returns empty despite hardware support, which might indicate lockout
      // Or we just rely on the authenticate() method returning false and handling the error there.
      return false;
    } catch (e) {
      return false;
    }
  }
}
