import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/theme/app_theme.dart';
import '../services/database/app_database.dart';
import 'database_provider.dart';

class BalanceState {
  final double totalBalance;
  final List<Transaction> transactions; // Using Drift generated Transaction class

  BalanceState({
    required this.totalBalance,
    required this.transactions,
  });

  double get totalExpenses => transactions
      .where((t) => t.amount < 0)
      .fold(0.0, (sum, t) => sum + (t.amount.abs() + t.fee + t.tax));

  BalanceState copyWith({
    double? totalBalance,
    List<Transaction>? transactions,
  }) {
    return BalanceState(
      totalBalance: totalBalance ?? this.totalBalance,
      transactions: transactions ?? this.transactions,
    );
  }
}

class BalanceNotifier extends StateNotifier<BalanceState> {
  final AppDatabase _db;
  final _uuid = const Uuid();

  BalanceNotifier(this._db) : super(BalanceState(totalBalance: 50000.0, transactions: [])) {
    _loadData();
  }

  /// Initial load of transactions from Drift database
  Future<void> _loadData() async {
    final txs = await _db.getAllTransactions();
    // In a real app, you'd calculate total balance from transactions or store it separately
    state = state.copyWith(transactions: txs);
  }

  /// Records a transaction atomically in Drift for offline mode
  /// This ensures that even if the app crashes mid-process, the database remains consistent.
  Future<void> recordTransaction({
    required String title,
    required String subtitle,
    required double amount,
    double fee = 0.0,
    double tax = 0.0,
    required IconData icon,
    required Color color,
    String category = 'Other',
    Map<String, dynamic>? metadata,
  }) async {
    // Generate a unique ID for atomicity and tracking
    final String transactionId = _uuid.v4();

    final entry = TransactionsCompanion(
      id: drift.Value(transactionId),
      title: drift.Value(title),
      subtitle: drift.Value(subtitle),
      amount: drift.Value(amount),
      fee: drift.Value(fee),
      tax: drift.Value(tax),
      iconCode: drift.Value(icon.codePoint),
      colorValue: drift.Value(color.toARGB32()),
      category: drift.Value(category),
      createdAt: drift.Value(DateTime.now()),
      // Serialization of metadata would happen here in a real production app
    );

    // Atomic operation using Drift's transaction wrapper
    await _db.recordTransaction(entry);

    // Update local state after successful DB write
    final double netImpact = amount >= 0 
        ? amount 
        : -(amount.abs() + fee + tax);

    // Re-fetch to keep UI in sync with DB state
    final updatedTxs = await _db.getAllTransactions();

    state = state.copyWith(
      totalBalance: state.totalBalance + netImpact,
      transactions: updatedTxs,
    );

    // If it was a debit transaction, decrement voucher limit if active (now using Drift)
    if (amount < 0) {
      _decrementVoucher();
    }
  }

  /// Migrated voucher logic from SharedPreferences to Drift AppPreferences for offline persistence
  Future<void> _decrementVoucher() async {
    try {
      final String? activeStr = await _db.getPreference('voucher_active');
      final bool isActive = activeStr == 'true';
      
      if (isActive) {
        final String? limitStr = await _db.getPreference('voucher_limit');
        int limit = int.tryParse(limitStr ?? '0') ?? 0;
        
        if (limit > 0) {
          limit--;
          await _db.setPreference('voucher_limit', limit.toString());
          if (limit <= 0) {
            await _db.setPreference('voucher_active', 'false');
          }
        }
      }
    } catch (_) {}
  }

  void deductQuickAction({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    double fee = 0.0,
    double tax = 0.0,
    String category = 'Other',
    Map<String, dynamic>? metadata,
  }) {
    recordTransaction(
      title: title,
      subtitle: 'Completed Payment',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: icon,
      color: color,
      category: category,
      metadata: metadata,
    );
  }

  void deductTravelTicket({
    required String mode,
    required double amount,
    required String ref,
    required double fee,
    required double tax,
    Map<String, dynamic>? metadata,
  }) {
    recordTransaction(
      title: '$mode Ticket',
      subtitle: 'Ref: $ref',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: mode == 'Flight' ? Icons.flight_takeoff_rounded : Icons.directions_bus_rounded,
      color: mode == 'Flight' ? const Color(0xFF10B981) : const Color(0xFFEC4899),
      category: 'Travel',
      metadata: metadata,
    );
  }

  void recordQrPayment({
    required double amount,
    required String merchant,
    required double fee,
    required double tax,
  }) {
    recordTransaction(
      title: 'QR: $merchant',
      subtitle: 'Scan & Pay',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: Icons.qr_code_scanner_rounded,
      color: AppTheme.primaryColor,
      category: 'Payment',
    );
  }

  void addFunds(double amount, String source) {
    recordTransaction(
      title: 'Top Up',
      subtitle: 'Via $source',
      amount: amount,
      fee: 0,
      tax: 0,
      icon: Icons.add_circle_rounded,
      color: Colors.green,
      category: 'TopUp',
    );
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, BalanceState>((ref) {
  final db = ref.watch(databaseProvider);
  return BalanceNotifier(db);
});
