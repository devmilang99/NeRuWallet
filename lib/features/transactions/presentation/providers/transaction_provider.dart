import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  TransactionState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  TransactionState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(TransactionState());

  Future<void> processTransaction({
    required String type,
    required double amount,
    required String target,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    // Mock Process
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random mock error
    if (amount > 10000) {
      state = state.copyWith(
        isLoading: false,
        error: 'Monthly transaction limit exceeded for $type.',
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
      return TransactionNotifier();
    });
