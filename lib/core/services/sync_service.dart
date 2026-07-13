import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  final Ref _ref;
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;
  Timer? _periodicSync;

  SyncService(this._ref);

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  /// Starts periodic background syncing every 5 minutes
  void startPeriodicSync() {
    _periodicSync?.cancel();
    _periodicSync = Timer.periodic(
      const Duration(minutes: 5),
      (_) => performFullSync(),
    );
    performFullSync(); // Initial sync
  }

  void stopPeriodicSync() => _periodicSync?.cancel();

  /// Orchestrates a full atomic sync between Supabase and Drift
  Future<void> performFullSync() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('⚠️ Sync skipped: No authenticated Supabase user.');
      return;
    }

    debugPrint('🔄 Starting Atomic Sync for user: ${user.id}...');
    try {
      // Sync tasks shouldn't block the main flow, so we catch errors individually
      await Future.wait([
        _syncTransactions(
          user.id,
        ).catchError((e) => debugPrint('Tx Sync Failed: $e')),
        _syncPreferences(
          user.id,
        ).catchError((e) => debugPrint('Pref Sync Failed: $e')),
        _syncAiMemories(
          user.id,
        ).catchError((e) => debugPrint('AI Sync Failed: $e')),
        _syncNotifications(
          user.id,
        ).catchError((e) => debugPrint('Notif Sync Failed: $e')),
      ]);
      debugPrint('✅ Sync Complete.');
    } catch (e) {
      debugPrint('❌ Sync Orchestration Failed: $e');
    }
  }

  // --- Transactions Sync ---
  Future<void> _syncTransactions(String userId) async {
    try {
      // 1. Fetch remote changes
      final List<dynamic> remoteData = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId);

      // 2. Fetch local data
      final localData = await _db.getAllTransactions();

      // 3. Atomic Batch Update to Drift
      await _db.transaction(() async {
        for (var row in remoteData) {
          await _db
              .into(_db.transactions)
              .insertOnConflictUpdate(
                TransactionsCompanion.insert(
                  id: row['id'],
                  title: row['title'],
                  subtitle: row['subtitle'],
                  amount: (row['amount'] as num).toDouble(),
                  fee: Value((row['fee'] as num?)?.toDouble() ?? 0.0),
                  tax: Value((row['tax'] as num?)?.toDouble() ?? 0.0),
                  iconCode: row['icon_code'],
                  colorValue: row['color_value'],
                  category: Value(row['category']),
                  createdAt: Value(DateTime.parse(row['created_at'])),
                  metadata: Value(row['metadata']),
                ),
              );
        }

        // 4. Push local-only transactions to cloud
        final remoteIds = remoteData.map((e) => e['id']).toSet();
        final localOnly = localData
            .where((tx) => !remoteIds.contains(tx.id))
            .toList();

        for (var tx in localOnly) {
          await _supabase.from('transactions').upsert({
            'id': tx.id,
            'user_id': userId,
            'title': tx.title,
            'subtitle': tx.subtitle,
            'amount': tx.amount,
            'fee': tx.fee,
            'tax': tx.tax,
            'icon_code': tx.iconCode,
            'color_value': tx.colorValue,
            'category': tx.category,
            'created_at': tx.createdAt.toIso8601String(),
            'metadata': tx.metadata,
          });
        }
      });
    } catch (e) {
      debugPrint('Transaction Sync Error: $e');
    }
  }

  // --- Preferences Sync ---
  Future<void> _syncPreferences(String userId) async {
    try {
      final prefService = _ref.read(preferenceServiceProvider);
      const syncKeys = [
        'transaction_pin',
        'app_password',
        'security_question',
        'security_answer',
        'monthly_spending_limit',
        'monthly_limit_enabled',
        'registration_complete',
        'registration_data',
      ];

      // 1. Push local changes to remote first (Source of truth is often local for these UI settings)
      for (var key in syncKeys) {
        final val = await prefService.getString(key);
        if (val != null && val.isNotEmpty) {
          await _supabase.from('app_preferences').upsert({
            'user_id': userId,
            'key': key,
            'value': val,
          });
        }
      }

      // 2. Fetch remote and update local (in case of new device)
      final remoteData = await _supabase
          .from('app_preferences')
          .select()
          .eq('user_id', userId);

      await _db.transaction(() async {
        for (var row in remoteData) {
          await _db.setPreference(row['key'], row['value']);
        }
      });
    } catch (e) {
      debugPrint('Preferences Sync Error: $e');
    }
  }

  // --- AI Memories Sync ---
  Future<void> _syncAiMemories(String userId) async {
    try {
      final remoteData = await _supabase
          .from('ai_memories')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);

      await _db.transaction(() async {
        for (var row in remoteData) {
          // Note: Drift uses auto-increment for AI Memories,
          // but we can mapping remote IDs if we modify the schema.
          // For now, we perform an additive sync.
          await _db
              .into(_db.aiMemories)
              .insert(
                AiMemoriesCompanion.insert(
                  role: row['role'],
                  content: row['content'],
                  type: Value(row['type']),
                  createdAt: Value(DateTime.parse(row['created_at'])),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      });
    } catch (e) {
      debugPrint('AI Memory Sync Error: $e');
    }
  }

  // --- Notifications Sync ---
  Future<void> _syncNotifications(String userId) async {
    try {
      final List<dynamic> remoteData = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId);

      await _db.transaction(() async {
        for (var row in remoteData) {
          await _db
              .into(_db.dbNotifications)
              .insertOnConflictUpdate(
                DbNotificationsCompanion.insert(
                  id: Value(row['id']),
                  title: row['title'],
                  body: row['body'],
                  receivedAt: Value(DateTime.parse(row['received_at'])),
                  isRead: Value(row['is_read'] ?? false),
                ),
              );
        }
      });
    } catch (e) {
      debugPrint('Notification Sync Error: $e');
    }
  }
}
