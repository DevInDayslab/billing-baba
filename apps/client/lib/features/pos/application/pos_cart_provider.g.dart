// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PosCart)
final posCartProvider = PosCartFamily._();

final class PosCartProvider extends $NotifierProvider<PosCart, PosCartState> {
  PosCartProvider._({
    required PosCartFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'posCartProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$posCartHash();

  @override
  String toString() {
    return r'posCartProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is PosCartProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$posCartHash() => r'e94ffb04cf4cbff1334c68dba7e044fd5c3272db';

final class PosCartFamily extends $Family
    with
        $ClassFamilyOverride<
          PosCart,
          PosCartState,
          PosCartState,
          PosCartState,
          String
        > {
  PosCartFamily._()
    : super(
        retry: null,
        name: r'posCartProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PosCartProvider call({String sessionKey = defaultPosCartSessionKey}) =>
      PosCartProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'posCartProvider';
}

abstract class _$PosCart extends $Notifier<PosCartState> {
  late final _$args = ref.$arg as String;
  String get sessionKey => _$args;

  PosCartState build({String sessionKey = defaultPosCartSessionKey});
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
    return element.handleCreate(ref, () => build(sessionKey: _$args));
  }
}
