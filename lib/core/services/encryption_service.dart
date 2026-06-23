import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final _key = Key.fromUtf8(
    'my32lengthsupersecretnooneknows1',
  ); // 32 chars for AES-256
  static final _iv = IV.fromUtf8('8822991100334455'); // 16 chars consistent IV
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String text) {
    if (text.isEmpty) return text;
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;
    try {
      final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return '';
    }
  }

  /// Generates a key from a string (like a user PIN or device ID)
  static Key generateKey(String seed) {
    final bytes = utf8.encode(seed);
    final digest = sha256.convert(bytes);
    return Key(digest.bytes as dynamic);
  }
}
