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

  // --- Multi-Sig Integration ---

  /// Fetches groups the current user is a member of.
  Future<List<Map<String, dynamic>>> getMultiSigGroups() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('multi_sig_members')
          .select('multi_sig_groups(*)')
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // AppLogger.e('Error fetching multi-sig groups', e);
      return [];
    }
  }

  /// Pushes a hardware-backed signature to Supabase for a pending transaction.
  Future<bool> pushSignature({
    required String transactionId,
    required String signature,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _client.from('pending_signatures').insert({
        'transaction_id': transactionId,
        'signer_id': userId,
        'signature': signature,
        'signed_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      // AppLogger.e('Error pushing signature', e);
      return false;
    }
  }

  /// Listens for new signature requirements in real-time.
  Stream<List<Map<String, dynamic>>> watchPendingApprovals() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    // In a real Supabase setup, we'd use .on(SupabaseEventTypes.insert)
    // for the pending_signatures table joined with user groups.
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending');
  }
}
