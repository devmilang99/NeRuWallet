import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/rust/api.dart' as rust;
import '../utils/logger.dart';

class RustService {
  /// Processes transaction data using Rust's high-performance hashing (SHA-256).
  /// Now powered by direct FFI (flutter_rust_bridge).
  Future<Uint8List?> processTransactionData(Uint8List data) async {
    AppLogger.d('RUST_SERVICE: processTransactionData start');
    AppLogger.i(
      'Flutter: Requesting Rust hashing for ${data.length} bytes via FFI',
    );
    try {
      final processedData = await rust.processTransactionData(data: data);
      AppLogger.i(
        'Flutter: Rust hashing successful. Received ${processedData.length} bytes',
      );
      AppLogger.d('RUST_SERVICE: processTransactionData success');
      return processedData;
    } catch (e) {
      AppLogger.e('RUST_SERVICE: processTransactionData failed', e);
      return null;
    }
  }

  /// Verifies an ECDSA signature using Rust's `ring` library.
  /// This is used for multi-sig verification or verifying external payloads.
  /// Now powered by direct FFI (flutter_rust_bridge).
  Future<bool> verifySignature({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  }) async {
    AppLogger.i('Flutter: Requesting Rust signature verification via FFI');
    try {
      final bool isValid = await rust.verifySignature(
        publicKey: publicKey,
        message: message,
        signature: signature,
      );
      AppLogger.i('Flutter: Rust verification result: $isValid');
      return isValid;
    } catch (e) {
      AppLogger.e('Flutter: Rust Verification Failed', e);
      return false;
    }
  }
}

final rustServiceProvider = Provider((ref) => RustService());
