import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(ref.watch(supabaseClientProvider));
});

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  /// Get the current user
  User? get currentUser => _client.auth.currentUser;

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Example: Upsert user preferences to Supabase 'user_profiles' table
  Future<void> syncPreferences(Map<String, dynamic> preferences) async {
    final user = currentUser;
    if (user == null) return;

    await _client.from('user_profiles').upsert({
      'id': user.id,
      'preferences': preferences,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Example: Fetch preferences
  Future<Map<String, dynamic>?> fetchPreferences() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _client
        .from('user_profiles')
        .select('preferences')
        .eq('id', user.id)
        .single();

    return response['preferences'] as Map<String, dynamic>?;
  }
}
