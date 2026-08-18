// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Balance)
final balanceProvider = BalanceProvider._();

final class BalanceProvider extends $NotifierProvider<Balance, BalanceState> {
  BalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'balanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$balanceHash();

  @$internal
  @override
  Balance create() => Balance();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BalanceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BalanceState>(value),
    );
  }
}

String _$balanceHash() => r'34e1455c0f0614a565c8ac7fecadf27efb8c10b0';

abstract class _$Balance extends $Notifier<BalanceState> {
  BalanceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BalanceState, BalanceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BalanceState, BalanceState>,
              BalanceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
