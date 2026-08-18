// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(preferenceService)
const preferenceServiceProvider = PreferenceServiceProvider._();

final class PreferenceServiceProvider
    extends
        $FunctionalProvider<
          PreferenceService,
          PreferenceService,
          PreferenceService
        >
    with $Provider<PreferenceService> {
  const PreferenceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferenceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferenceServiceHash();

  @$internal
  @override
  $ProviderElement<PreferenceService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PreferenceService create(Ref ref) {
    return preferenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferenceService>(value),
    );
  }
}

String _$preferenceServiceHash() => r'de2cb7a9845b44ab20008511e1407c107084ba24';
