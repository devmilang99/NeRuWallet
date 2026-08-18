// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuickActions)
final quickActionsProvider = QuickActionsProvider._();

final class QuickActionsProvider
    extends $NotifierProvider<QuickActions, List<QuickActionModel>> {
  QuickActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickActionsHash();

  @$internal
  @override
  QuickActions create() => QuickActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<QuickActionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<QuickActionModel>>(value),
    );
  }
}

String _$quickActionsHash() => r'36eb070452ca489687a7cbcc2ecdfa179e70dc48';

abstract class _$QuickActions extends $Notifier<List<QuickActionModel>> {
  List<QuickActionModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<QuickActionModel>, List<QuickActionModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<QuickActionModel>, List<QuickActionModel>>,
              List<QuickActionModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
