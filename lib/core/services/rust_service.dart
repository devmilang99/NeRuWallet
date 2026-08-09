import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';

class RustService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.neruwallet/security',
  );

  /// Processes transaction data using Rust's high-performance hashing (SHA-256).
  Future<Uint8List?> processTransactionData(Uint8List data) async {
    AppLogger.d('RUST_SERVICE: processTransactionData start');
    AppLogger.i('Flutter: Requesting Rust hashing for ${data.length} bytes');
    try {
      final processedData = await _channel.invokeMethod(
        'processTransactionData',
        {'data': data},
      );
      if (processedData != null) {
        AppLogger.i(
          'Flutter: Rust hashing successful. Received ${processedData.length} bytes',
        );
        AppLogger.d('RUST_SERVICE: processTransactionData success');
      }
      return processedData as Uint8List?;
    } on PlatformException catch (e) {
      AppLogger.e('RUST_SERVICE: processTransactionData failed', e);
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
    AppLogger.i('Flutter: Requesting Rust signature verification');
    try {
      final bool isValid = await _channel.invokeMethod('verifyRustSignature', {
        'publicKey': publicKey,
        'message': message,
        'signature': signature,
      });
      AppLogger.i('Flutter: Rust verification result: $isValid');
      return isValid;
    } on PlatformException catch (e) {
      AppLogger.e('Flutter: Rust Verification Failed', e);
      return false;
    }
  }
}

final rustServiceProvider = Provider((ref) => RustService());
