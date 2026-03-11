import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> canCheckBiometrics() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
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
