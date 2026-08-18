// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KycState)
const kycStateProvider = KycStateProvider._();

final class KycStateProvider extends $AsyncNotifierProvider<KycState, bool> {
  const KycStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycStateHash();

  @$internal
  @override
  KycState create() => KycState();
}

String _$kycStateHash() => r'f77925dad39fba871c88d83d7644793865f5e56e';

abstract class _$KycState extends $AsyncNotifier<bool> {
  FutureOr<bool> build();

  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
