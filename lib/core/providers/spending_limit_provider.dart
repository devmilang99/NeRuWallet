import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/preference_service.dart';

part 'spending_limit_provider.g.dart';

class SpendingLimit {
  final bool enabled;
  final double limit;

  SpendingLimit({required this.enabled, required this.limit});
}

@riverpod
Future<SpendingLimit> spendingLimit(Ref ref) async {
  final prefService = ref.watch(preferenceServiceProvider);
  final enabled = await prefService.getBool('monthly_limit_enabled') ?? false;
  final limitStr =
      await prefService.getString('monthly_spending_limit') ?? '0.0';
  final limit = double.tryParse(limitStr) ?? 0.0;
  return SpendingLimit(enabled: enabled, limit: limit);
}
