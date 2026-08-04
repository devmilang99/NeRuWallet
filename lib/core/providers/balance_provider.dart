import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../services/database/app_database.dart';
import '../services/sync_service.dart';
import '../services/transaction_service.dart';
import 'database_provider.dart';

part 'balance_provider.g.dart';

class BalanceState {
  final double totalBalance;
  final List<Transaction> transactions;
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

@riverpod
class Balance extends _$Balance {
  late AppDatabase _db;
  final _uuid = const Uuid();
  StreamSubscription? _txSubscription;
  StreamSubscription? _balanceSubscription;
  StreamSubscription? _voucherSubscription;

  @override
  BalanceState build() {
    _db = ref.watch(databaseProvider);

    // Initial load
    _loadData();
    _listenToDatabase();

    ref.onDispose(() {
      _txSubscription?.cancel();
      _balanceSubscription?.cancel();
      _voucherSubscription?.cancel();
    });

    return BalanceState(totalBalance: 0.0, transactions: []);
  }

  void _listenToDatabase() {
    _txSubscription?.cancel();
    _txSubscription = _db.watchAllTransactions().listen((txs) {
      state = state.copyWith(transactions: txs);
    });

    _balanceSubscription?.cancel();
    _balanceSubscription = _db.watchPreference('total_balance').listen((val) {
      if (val != null) {
        final balance = double.tryParse(val) ?? 0.0;
        state = state.copyWith(totalBalance: balance);
      }
    });

    _voucherSubscription?.cancel();
    _voucherSubscription = _db.watchPreference('voucher_active').listen((val) {
      state = state.copyWith(isVoucherActive: val == 'true');
    });
  }

  Future<void> _loadData() async {
    final txs = await _db.getAllTransactions();
    final balanceStr = await _db.getPreference('total_balance');
    final balance = double.tryParse(balanceStr ?? '50000.0') ?? 50000.0;

    final activeStr = await _db.getPreference('voucher_active');
    final isVoucherActive = activeStr == 'true';

    state = state.copyWith(
      transactions: txs,
      totalBalance: balance,
      isVoucherActive: isVoucherActive,
    );
  }

  Future<void> recordTransaction({
    required String title,
    required String subtitle,
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
    final transactionId = _uuid.v4();

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

    final newTx = await _db.recordTransaction(entry);
    final netImpact = amount >= 0 ? amount : -(amount.abs() + fee + tax);
    final newBalance = state.totalBalance + netImpact;

    state = state.copyWith(
      totalBalance: newBalance,
      transactions: [newTx, ...state.transactions],
    );

    await _db.setPreference('total_balance', newBalance.toString());
    await ref.read(syncServiceProvider).pushTransactionToCloud(newTx);

    if (amount < 0 && isVoucherApplied) {
      _decrementVoucher();
    }
  }

  Future<void> _decrementVoucher() async {
    try {
      final activeStr = await _db.getPreference('voucher_active');
      final isActive = activeStr == 'true';

      if (isActive) {
        final limitStr = await _db.getPreference('voucher_limit');
        var limit = int.tryParse(limitStr ?? '0') ?? 0;

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
      icon: Icons.add_circle_rounded,
      color: Colors.green,
      category: 'TopUp',
      type: TransactionType.topUp,
    );
  }
}
