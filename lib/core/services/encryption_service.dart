import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';
import 'secure_storage_service.dart';

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService(ref.watch(secureStorageServiceProvider));
});

class EncryptionService {
  final SecureStorageService _secureStorage;
  Key? _key;
  final _iv = IV.fromUtf8(
    '8822991100334455',
  ); // Constant IV for consistent decryption

  EncryptionService(this._secureStorage);

  Future<void> init() async {
    final keyString = await _secureStorage.getOrGenerateKey('aes_key_seed');
    _key = Key.fromUtf8(keyString);
  }

  String encrypt(String text) {
    if (text.isEmpty || _key == null) return text;
    try {
      final encrypter = Encrypter(AES(_key!));
      final encrypted = encrypter.encrypt(text, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      AppLogger.e('Encryption Error', e);
      return text;
    }
  }

  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty || _key == null) return encryptedText;
    try {
      final encrypter = Encrypter(AES(_key!));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      AppLogger.e('Decryption Error', e);
      return '';
    }
  }

  /// Generates a key from a string (like a user PIN or device ID)
  static Key generateKey(String seed) {
    final bytes = utf8.encode(seed);
    final digest = sha256.convert(bytes);
    return Key(Uint8List.fromList(digest.bytes));
  }
}
