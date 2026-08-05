import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';

class SecureSigningService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.neruwallet/security',
  );

  /// Generates a hardware-backed key (StrongBox if available, else TEE).
  Future<bool> generateSecureKey() async {
    try {
      final bool success = await _channel.invokeMethod('generateKey');
      return success;
    } on PlatformException catch (e) {
      AppLogger.e('Error generating key', e);
      return false;
    }
  }

  /// Signs data using the hardware-backed key, gated by biometrics.
  Future<Uint8List?> signData(Uint8List data) async {
    try {
      final signature = await _channel.invokeMethod('signData', {'data': data});
      return signature;
    } on PlatformException catch (e) {
      AppLogger.e('Error signing data', e);
      return null;
    }
  }

  /// Specialized signing for Multi-Sig that includes group context.
  Future<Uint8List?> signMultiSigPayload(
    Uint8List payload,
    String groupId,
  ) async {
    // In a production app, we might add group-specific metadata to the payload
    // before signing, or log the intent specifically for the group.
    AppLogger.i('Initiating Multi-Sig signature for group: $groupId');
    return signData(payload);
  }

  /// Gets the hardware-backed public key to share with other group members.
  Future<String?> getPublicKey() async {
    try {
      final String? publicKey = await _channel.invokeMethod('getPublicKey');
      return publicKey;
    } on PlatformException catch (e) {
      AppLogger.e('Error fetching public key', e);
      return null;
    }
  }

  /// Checks if the secure key has already been generated.
  Future<bool> isKeyGenerated() async {
    try {
      final bool exists = await _channel.invokeMethod('isKeyGenerated');
      return exists;
    } on PlatformException catch (e) {
      AppLogger.e('Error checking key status', e);
      return false;
    }
  }
}

final secureSigningServiceProvider = Provider((ref) => SecureSigningService());
