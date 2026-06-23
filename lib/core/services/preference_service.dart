import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/services/encryption_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preference_service.g.dart';

@Riverpod(keepAlive: true)
PreferenceService preferenceService(Ref ref) {
  return PreferenceService(ref.watch(appDatabaseProvider));
}

// I need to define appDatabaseProvider if it doesn't exist. 
// Let's check if it exists in app_database.dart or elsewhere.
class PreferenceService {
  final AppDatabase _db;

  PreferenceService(this._db);

  /// Saves a string preference. Set [encrypted] to true to use AES encryption.
  Future<void> setString(String key, String value, {bool encrypted = false}) async {
    final storageValue = encrypted ? EncryptionService.encrypt(value) : value;
    await _db.setPreference(key, storageValue);
  }

  /// Gets a string preference.
  Future<String?> getString(String key, {bool encrypted = false}) async {
    final value = await _db.getPreference(key);
    if (value == null) return null;
    return encrypted ? EncryptionService.decrypt(value) : value;
  }

  /// Saves a boolean preference.
  Future<void> setBool(String key, bool value) async {
    await _db.setPreference(key, value.toString());
  }

  /// Gets a boolean preference.
  Future<bool?> getBool(String key) async {
    final value = await _db.getPreference(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Saves an integer preference.
  Future<void> setInt(String key, int value) async {
    await _db.setPreference(key, value.toString());
  }

  /// Gets an integer preference.
  Future<int?> getInt(String key) async {
    final value = await _db.getPreference(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Saves a string list preference.
  Future<void> setStringList(String key, List<String> value) async {
    await _db.setPreference(key, value.join(','));
  }

  /// Gets a string list preference.
  Future<List<String>?> getStringList(String key) async {
    final value = await _db.getPreference(key);
    if (value == null) return null;
    return value.split(',').where((e) => e.isNotEmpty).toList();
  }

  /// Removes a preference.
  Future<void> remove(String key) async {
    await _db.setPreference(key, null);
  }
}
