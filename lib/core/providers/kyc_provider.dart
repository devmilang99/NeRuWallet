import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/preference_service.dart';

part 'kyc_provider.g.dart';

@riverpod
class KycState extends _$KycState {
  @override
  FutureOr<bool> build() async {
    final prefService = ref.watch(preferenceServiceProvider);
    return await prefService.getBool('is_kyc_verified') ?? false;
  }

  Future<void> updateVerificationStatus(bool isVerified) async {
    final prefService = ref.read(preferenceServiceProvider);
    await prefService.setBool('is_kyc_verified', isVerified);
    state = AsyncData(isVerified);
  }
}
