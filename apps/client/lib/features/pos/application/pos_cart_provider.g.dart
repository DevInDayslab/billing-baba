// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PosCart)
final posCartProvider = PosCartProvider._();

final class PosCartProvider extends $NotifierProvider<PosCart, PosCartState> {
  PosCartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posCartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posCartHash();

  @$internal
  @override
  PosCart create() => PosCart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PosCartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PosCartState>(value),
    );
  }
}

String _$posCartHash() => r'7c736eaee595d75206874b13ba891c39b5c1e314';

abstract class _$PosCart extends $Notifier<PosCartState> {
  PosCartState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PosCartState, PosCartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PosCartState, PosCartState>,
              PosCartState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
