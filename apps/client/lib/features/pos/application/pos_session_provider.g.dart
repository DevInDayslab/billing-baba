// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// POS terminal UI state plus backend cash-drawer session.

@ProviderFor(PosSession)
final posSessionProvider = PosSessionProvider._();

/// POS terminal UI state plus backend cash-drawer session.
final class PosSessionProvider
    extends $NotifierProvider<PosSession, PosSessionState> {
  /// POS terminal UI state plus backend cash-drawer session.
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
  Override overrideWithValue(PosSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PosSessionState>(value),
    );
  }
}

String _$posSessionHash() => r'217dd2d1c4bbccb2dc64b8bd2c0391fc39d3d5ea';

/// POS terminal UI state plus backend cash-drawer session.

abstract class _$PosSession extends $Notifier<PosSessionState> {
  PosSessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PosSessionState, PosSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PosSessionState, PosSessionState>,
              PosSessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
