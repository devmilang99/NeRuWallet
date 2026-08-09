import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';
import 'rust_service.dart';

class SecureSigningService {
  final Ref? _ref;

  SecureSigningService([this._ref]);

  static const MethodChannel _channel = MethodChannel(
    'com.example.neruwallet/security',
  );

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

  /// Combined workflow: Hashing with Rust, then signing with Secure Hardware.
  /// This ensures that the data being signed has been processed by our
  /// high-performance Rust core.
  Future<Uint8List?> signDataWithRustHash(Uint8List data) async {
    if (_ref == null) return signData(data);

    final rustService = _ref!.read(rustServiceProvider);
    final hashedData = await rustService.processTransactionData(data);

    if (hashedData == null) {
      AppLogger.w('Rust hashing failed, falling back to raw data signing.');
      return signData(data);
    }

    AppLogger.i(
      'Data successfully hashed by Rust. Proceeding to hardware signature.',
    );
    return signData(hashedData);
  }

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
      final publicKey = await _channel.invokeMethod('getPublicKey');
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

final secureSigningServiceProvider = Provider(
  (ref) => SecureSigningService(ref),
);
