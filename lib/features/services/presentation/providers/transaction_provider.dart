import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  TransactionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  TransactionState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
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
    state = state.copyWith(isLoading: true, isSuccess: false);

    // Simulate network delay for portfolio polish
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would integrate with a backend here.
    // For this portfolio demo, we'll assume success.
    state = state.copyWith(isLoading: false, isSuccess: true);
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier();
    });
