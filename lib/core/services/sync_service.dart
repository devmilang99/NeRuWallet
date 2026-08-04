import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  final Ref _ref;
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;
  Timer? _periodicSync;
  bool _isSyncing = false;

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

  /// Pushes a single transaction to the cloud immediately.
  Future<void> pushTransactionToCloud(Transaction tx) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('transactions').upsert({
        'id': tx.id,
        'user_id': user.id,
        'title': tx.title,
        'subtitle': tx.subtitle,
        'amount': tx.amount,
        'fee': tx.fee,
        'tax': tx.tax,
        'icon_code': tx.iconCode,
        'color_value': tx.colorValue,
        'category': tx.category,
        'transaction_type': tx.transactionType,
        'created_at': tx.createdAt.toIso8601String(),
        'metadata': tx.metadata,
      }, onConflict: 'id');
      AppLogger.i('✅ Individual Transaction Push Successful.');
    } catch (e) {
      AppLogger.e('❌ Individual Transaction Push Failed', e);
    }
  }

  /// Manually fetches specific transaction data from Supabase.
  /// Useful for verifying status or getting deep details for a specific "process".
  Future<List<Map<String, dynamic>>> getTransactionsFromCloud({
    String? type,
    int limit = 20,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      var query = _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id);

      if (type != null) {
        query = query.eq('transaction_type', type);
      }

      final List<dynamic> data = await query
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.e('Cloud Get Failed', e);
      return [];
    }
  }

  /// Orchestrates a full atomic sync between Supabase and Drift
  Future<void> performFullSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    final user = _supabase.auth.currentUser;
    if (user == null) {
      AppLogger.i('⚠️ Sync skipped: No authenticated Supabase user.');
      _isSyncing = false;
      return;
    }

    AppLogger.i('🔄 Starting Atomic Sync for user: ${user.id}...');
    try {
      // Sync tasks shouldn't block the main flow, so we catch errors individually
      await Future.wait([
        _syncTransactions(
          user.id,
        ).catchError((e) => AppLogger.e('Tx Sync Failed', e)),
        _syncPreferences(
          user.id,
        ).catchError((e) => AppLogger.e('Pref Sync Failed', e)),
        _syncAiMemories(
          user.id,
        ).catchError((e) => AppLogger.e('AI Sync Failed', e)),
        _syncNotifications(
          user.id,
        ).catchError((e) => AppLogger.e('Notif Sync Failed', e)),
      ]);
      AppLogger.i('✅ Sync Complete.');
    } catch (e) {
      AppLogger.e('❌ Sync Orchestration Failed', e);
    } finally {
      _isSyncing = false;
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

      // 3. Atomic Batch Update to Drift (Incoming from Cloud)
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
                  transactionType: Value(row['transaction_type']),
                  createdAt: Value(DateTime.parse(row['created_at'])),
                  metadata: Value(
                    row['metadata'] is Map
                        ? jsonEncode(row['metadata'])
                        : row['metadata'],
                  ),
                ),
              );
        }
      });

      // 4. Push local-only transactions to cloud
      final remoteIds = remoteData.map((e) => e['id']).toSet();
      final localOnly = localData
          .where((tx) => !remoteIds.contains(tx.id))
          .toList();

      if (localOnly.isNotEmpty) {
        AppLogger.i(
          '📤 Pushing ${localOnly.length} local transactions to cloud...',
        );
        final List<Map<String, dynamic>> toUpsert = localOnly.map((tx) {
          return {
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
            'transaction_type': tx.transactionType,
            'created_at': tx.createdAt.toIso8601String(),
            'metadata': tx.metadata,
          };
        }).toList();

        await _supabase.from('transactions').upsert(toUpsert, onConflict: 'id');
        AppLogger.i('✅ Cloud sync for transactions successful.');
      }
    } catch (e) {
      if (e is sb.PostgrestException) {
        AppLogger.e('❌ Supabase Transaction Sync Error', e);
      } else {
        AppLogger.e('Transaction Sync Error', e);
      }
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
        'is_kyc_verified',
        'total_balance',
        'voucher_active',
        'voucher_limit',
      ];

      // 1. Collect local changes
      final prefsToPush = <Map<String, dynamic>>[];
      for (var key in syncKeys) {
        final val = await prefService.getString(key);
        if (val != null && val.isNotEmpty) {
          prefsToPush.add({'user_id': userId, 'key': key, 'value': val});
        }
      }

      // 2. Batch Push to Remote
      if (prefsToPush.isNotEmpty) {
        await _supabase
            .from('app_preferences')
            .upsert(prefsToPush, onConflict: 'user_id,key');
      }

      // 3. Fetch remote and update local (in case of new device)
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
      AppLogger.e('Preferences Sync Error', e);
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
      AppLogger.e('AI Memory Sync Error', e);
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
      AppLogger.e('Notification Sync Error', e);
    }
  }
}
