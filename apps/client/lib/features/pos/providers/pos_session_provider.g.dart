// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PosSession)
final posSessionProvider = PosSessionProvider._();

final class PosSessionProvider extends $NotifierProvider<PosSession, bool> {
  PosSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posSessionHash();

  @$internal
  @override
  PosSession create() => PosSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$posSessionHash() => r'd4e5f678901234567890abcdef012345678901234';

abstract class _$PosSession extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
