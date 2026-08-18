// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_limit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(spendingLimit)
final spendingLimitProvider = SpendingLimitProvider._();

final class SpendingLimitProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpendingLimit>,
          SpendingLimit,
          FutureOr<SpendingLimit>
        >
    with $FutureModifier<SpendingLimit>, $FutureProvider<SpendingLimit> {
  SpendingLimitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spendingLimitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spendingLimitHash();

  @$internal
  @override
  $FutureProviderElement<SpendingLimit> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SpendingLimit> create(Ref ref) {
    return spendingLimit(ref);
  }
}

String _$spendingLimitHash() => r'645256bf5a5cd86e3220cea58c17159a1caaaf88';
