import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/services/preference_service.dart';

class TransactionState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  TransactionState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  TransactionState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref _ref;

  TransactionNotifier(this._ref) : super(TransactionState());

  Future<void> processTransaction({
    required String type,
    required double amount,
    required String target,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    // Get current limit settings
    final prefService = _ref.read(preferenceServiceProvider);
    final limitEnabled =
        await prefService.getBool('monthly_limit_enabled') ?? false;
    final limitStr =
        await prefService.getString('monthly_spending_limit') ?? '0.0';
    final monthlyLimit = double.tryParse(limitStr) ?? 0.0;

    final currentSpending = _ref.read(balanceProvider).monthlyExpenses;

    // Validation: Check if the new transaction will exceed the user's monthly limit
    if (limitEnabled &&
        monthlyLimit > 0 &&
        (currentSpending + amount) > monthlyLimit) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Monthly spending limit of Rs. ${monthlyLimit.toStringAsFixed(0)} would be exceeded. You have already spent Rs. ${currentSpending.toStringAsFixed(2)} this month.',
      );
      return;
    }

    // Mock Process
    await Future.delayed(const Duration(seconds: 2));

    // Basic system limit
    if (amount > 500000) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Transaction amount exceeds maximum allowed per transaction (Rs. 5,00,000).',
      );
      return;
    }

    if (amount == 404) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error. Please check your connection.',
      );
      return;
    }

    state = state.copyWith(isLoading: false, isSuccess: true);
  }

  void reset() {
    state = TransactionState();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier(ref);
    });
