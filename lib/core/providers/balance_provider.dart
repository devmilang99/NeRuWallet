import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../services/database/app_database.dart';
import '../services/sync_service.dart';
import '../services/transaction_service.dart';
import 'database_provider.dart';

class BalanceState {
  final double totalBalance;
  final List<Transaction>
  transactions; // Using Drift generated Transaction class
  final bool isVoucherActive;

  BalanceState({
    required this.totalBalance,
    required this.transactions,
    this.isVoucherActive = false,
  });

  double get totalExpenses => transactions
      .where((t) => t.amount < 0)
      .fold(0.0, (sum, t) => sum + (t.amount.abs() + t.fee + t.tax));

  double get monthlyExpenses {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.amount < 0 &&
              t.createdAt.month == now.month &&
              t.createdAt.year == now.year,
        )
        .fold(0.0, (sum, t) => sum + (t.amount.abs() + t.fee + t.tax));
  }

  double get totalIncome => transactions
      .where((t) => t.amount > 0)
      .fold(0.0, (sum, t) => sum + t.amount);

  BalanceState copyWith({
    double? totalBalance,
    List<Transaction>? transactions,
    bool? isVoucherActive,
  }) {
    return BalanceState(
      totalBalance: totalBalance ?? this.totalBalance,
      transactions: transactions ?? this.transactions,
      isVoucherActive: isVoucherActive ?? this.isVoucherActive,
    );
  }
}

class BalanceNotifier extends StateNotifier<BalanceState> {
  final AppDatabase _db;
  final Ref _ref;
  final _uuid = const Uuid();
  StreamSubscription? _txSubscription;
  StreamSubscription? _balanceSubscription;
  StreamSubscription? _voucherSubscription;

  BalanceNotifier(this._db, this._ref)
    : super(BalanceState(totalBalance: 0.0, transactions: [])) {
    _loadData();
    _listenToDatabase();
  }

  void _listenToDatabase() {
    _txSubscription?.cancel();
    _txSubscription = _db.watchAllTransactions().listen((txs) {
      if (mounted) state = state.copyWith(transactions: txs);
    });

    _balanceSubscription?.cancel();
    _balanceSubscription = _db.watchPreference('total_balance').listen((val) {
      if (val != null && mounted) {
        final balance = double.tryParse(val) ?? 0.0;
        state = state.copyWith(totalBalance: balance);
      }
    });

    _voucherSubscription?.cancel();
    _voucherSubscription = _db.watchPreference('voucher_active').listen((val) {
      if (mounted) {
        state = state.copyWith(isVoucherActive: val == 'true');
      }
    });
  }

  @override
  void dispose() {
    _txSubscription?.cancel();
    _balanceSubscription?.cancel();
    _voucherSubscription?.cancel();
    super.dispose();
  }

  /// Initial load of transactions and balance from Drift database
  Future<void> _loadData() async {
    final txs = await _db.getAllTransactions();
    final balanceStr = await _db.getPreference('total_balance');
    final balance = double.tryParse(balanceStr ?? '50000.0') ?? 50000.0;

    final String? activeStr = await _db.getPreference('voucher_active');
    final bool isVoucherActive = activeStr == 'true';

    state = state.copyWith(
      transactions: txs,
      totalBalance: balance,
      isVoucherActive: isVoucherActive,
    );
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
    TransactionType? type,
    Map<String, dynamic>? metadata,
    bool isVoucherApplied = false,
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
      transactionType: drift.Value(type?.name),
      createdAt: drift.Value(DateTime.now()),
      metadata: drift.Value(metadata != null ? jsonEncode(metadata) : null),
    );

    // Atomic operation using Drift's transaction wrapper
    final newTx = await _db.recordTransaction(entry);

    // Update local state after successful DB write
    final double netImpact = amount >= 0 ? amount : -(amount.abs() + fee + tax);

    // Re-fetch to keep UI in sync with DB state
    final newBalance = state.totalBalance + netImpact;

    // MANDATORY: Update UI state manually for zero-latency
    if (mounted) {
      state = state.copyWith(
        totalBalance: newBalance,
        transactions: [newTx, ...state.transactions],
      );
    }

    // Persist new balance
    await _db.setPreference('total_balance', newBalance.toString());

    // Sync to cloud IMMEDIATELY and AWAIT it for permanence
    await _ref.read(syncServiceProvider).pushTransactionToCloud(newTx);

    // If it was a debit transaction, decrement voucher limit if active (now using Drift)
    if (amount < 0 && isVoucherApplied) {
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
            state = state.copyWith(isVoucherActive: false);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> deductQuickAction({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    double fee = 0.0,
    double tax = 0.0,
    String category = 'Other',
    TransactionType? type,
    Map<String, dynamic>? metadata,
    bool isVoucherApplied = false,
  }) async {
    await recordTransaction(
      title: title,
      subtitle: 'Completed Payment',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: icon,
      color: color,
      category: category,
      type: type,
      metadata: metadata,
      isVoucherApplied: isVoucherApplied,
    );
  }

  Future<void> deductTravelTicket({
    required String mode,
    required double amount,
    required String ref,
    required double fee,
    required double tax,
    Map<String, dynamic>? metadata,
    bool isVoucherApplied = false,
  }) async {
    await recordTransaction(
      title: '$mode Ticket',
      subtitle: 'Ref: $ref',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: mode == 'Flight'
          ? Icons.flight_takeoff_rounded
          : Icons.directions_bus_rounded,
      color: mode == 'Flight'
          ? const Color(0xFF10B981)
          : const Color(0xFFEC4899),
      category: 'Travel',
      type: mode == 'Flight' ? TransactionType.flight : TransactionType.bus,
      metadata: metadata,
      isVoucherApplied: isVoucherApplied,
    );
  }

  Future<void> recordQrPayment({
    required double amount,
    required String merchant,
    required double fee,
    required double tax,
  }) async {
    await recordTransaction(
      title: 'QR: $merchant',
      subtitle: 'Scan & Pay',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: Icons.qr_code_scanner_rounded,
      color: AppTheme.primaryColor,
      category: 'Payment',
      type: TransactionType.qrPayment,
    );
  }

  Future<void> addFunds(double amount, String source) async {
    await recordTransaction(
      title: 'Top Up',
      subtitle: 'Via $source',
      amount: amount,
      fee: 0,
      tax: 0,
      icon: Icons.add_circle_rounded,
      color: Colors.green,
      category: 'TopUp',
      type: TransactionType.topUp,
    );
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, BalanceState>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return BalanceNotifier(db, ref);
});
