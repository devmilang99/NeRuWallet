import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';

class RustService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.neruwallet/security',
  );

  /// Processes transaction data using Rust's high-performance hashing (SHA-256).
  Future<Uint8List?> processTransactionData(Uint8List data) async {
    try {
      final processedData = await _channel.invokeMethod(
        'processTransactionData',
        {'data': data},
      );
      return processedData as Uint8List?;
    } on PlatformException catch (e) {
      AppLogger.e('Rust Hashing Failed', e);
      return null;
    }
  }

  /// Verifies an ECDSA signature using Rust's `ring` library.
  /// This is used for multi-sig verification or verifying external payloads.
  Future<bool> verifySignature({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  }) async {
    try {
      final bool isValid = await _channel.invokeMethod('verifyRustSignature', {
        'publicKey': publicKey,
        'message': message,
        'signature': signature,
      });
      return isValid;
    } on PlatformException catch (e) {
      AppLogger.e('Rust Verification Failed', e);
      return false;
    }
  }
}

final rustServiceProvider = Provider((ref) => RustService());
