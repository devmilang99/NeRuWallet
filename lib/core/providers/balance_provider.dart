import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/dashboard/data/models/transaction_model.dart';
import '../../core/theme/app_theme.dart';

class BalanceState {
  final double totalBalance;
  final List<TransactionModel> transactions;

  BalanceState({
    required this.totalBalance,
    required this.transactions,
  });

  double get totalExpenses => transactions
      .where((t) => t.amount < 0)
      .fold(0, (sum, t) => sum + t.totalPayable);

  BalanceState copyWith({
    double? totalBalance,
    List<TransactionModel>? transactions,
  }) {
    return BalanceState(
      totalBalance: totalBalance ?? this.totalBalance,
      transactions: transactions ?? this.transactions,
    );
  }
}

class BalanceNotifier extends StateNotifier<BalanceState> {
  BalanceNotifier() : super(BalanceState(totalBalance: 50000.0, transactions: []));

  void recordTransaction(TransactionModel transaction) {
    // Determine the total impact on balance (amount + fee + tax)
    final double netImpact = transaction.amount >= 0 
        ? transaction.amount 
        : -(transaction.amount.abs() + transaction.fee + transaction.tax);

    state = state.copyWith(
      totalBalance: state.totalBalance + netImpact,
      transactions: [transaction, ...state.transactions],
    );

    // If it was a debit transaction, decrement voucher limit if active
    if (transaction.amount < 0) {
      _decrementVoucher();
    }
  }

  Future<void> _decrementVoucher() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isActive = prefs.getBool('voucher_active') ?? false;
      if (isActive) {
        int limit = prefs.getInt('voucher_limit') ?? 0;
        if (limit > 0) {
          limit--;
          await prefs.setInt('voucher_limit', limit);
          if (limit <= 0) {
            await prefs.setBool('voucher_active', false);
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
    final transaction = TransactionModel(
      title: title,
      subtitle: 'Completed Payment',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: icon,
      color: color,
      time: 'Just now',
      category: category,
      metadata: metadata,
    );

    recordTransaction(transaction);
  }

  void deductTravelTicket({
    required String mode,
    required double amount,
    required String ref,
    required double fee,
    required double tax,
    Map<String, dynamic>? metadata,
  }) {
    final transaction = TransactionModel(
      title: '$mode Ticket',
      subtitle: 'Ref: $ref',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: mode == 'Flight' ? Icons.flight_takeoff_rounded : Icons.directions_bus_rounded,
      color: mode == 'Flight' ? const Color(0xFF10B981) : const Color(0xFFEC4899),
      time: 'Just now',
      category: 'Travel',
      metadata: metadata,
    );

    recordTransaction(transaction);
  }

  void recordQrPayment({
    required double amount,
    required String merchant,
    required double fee,
    required double tax,
  }) {
    final transaction = TransactionModel(
      title: 'QR: $merchant',
      subtitle: 'Scan & Pay',
      amount: -amount,
      fee: fee,
      tax: tax,
      icon: Icons.qr_code_scanner_rounded,
      color: AppTheme.primaryColor,
      time: 'Just now',
      category: 'Payment',
    );

    recordTransaction(transaction);
  }

  void addFunds(double amount, String source) {
    final transaction = TransactionModel(
      title: 'Top Up',
      subtitle: 'Via $source',
      amount: amount,
      fee: 0,
      tax: 0,
      icon: Icons.add_circle_rounded,
      color: Colors.green,
      time: 'Just now',
      category: 'TopUp',
    );

    recordTransaction(transaction);
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, BalanceState>((ref) {
  return BalanceNotifier();
});
