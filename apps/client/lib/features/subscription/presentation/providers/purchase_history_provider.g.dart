// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseHistoryState)
final purchaseHistoryStateProvider = PurchaseHistoryStateProvider._();

final class PurchaseHistoryStateProvider
    extends
        $AsyncNotifierProvider<PurchaseHistoryState, List<PurchaseHistory>> {
  PurchaseHistoryStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseHistoryStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseHistoryStateHash();

  @$internal
  @override
  PurchaseHistoryState create() => PurchaseHistoryState();
}

String _$purchaseHistoryStateHash() =>
    r'871e7ac1cd089769a68562f97a3ef4bcbf85468d';

abstract class _$PurchaseHistoryState
    extends $AsyncNotifier<List<PurchaseHistory>> {
  FutureOr<List<PurchaseHistory>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<PurchaseHistory>>, List<PurchaseHistory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PurchaseHistory>>,
                List<PurchaseHistory>
              >,
              AsyncValue<List<PurchaseHistory>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
