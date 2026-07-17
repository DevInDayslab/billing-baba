// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Invitations)
final invitationsProvider = InvitationsProvider._();

final class InvitationsProvider
    extends $AsyncNotifierProvider<Invitations, List<Invitation>> {
  InvitationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitationsHash();

  @$internal
  @override
  Invitations create() => Invitations();
}

String _$invitationsHash() => r'3c753bddce9a155f8f5a961aafd8ffac74e65236';

abstract class _$Invitations extends $AsyncNotifier<List<Invitation>> {
  FutureOr<List<Invitation>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Invitation>>, List<Invitation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Invitation>>, List<Invitation>>,
              AsyncValue<List<Invitation>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LastInvitation)
final lastInvitationProvider = LastInvitationProvider._();

final class LastInvitationProvider
    extends $NotifierProvider<LastInvitation, LastInvitationResult?> {
  LastInvitationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastInvitationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastInvitationHash();

  @$internal
  @override
  LastInvitation create() => LastInvitation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LastInvitationResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LastInvitationResult?>(value),
    );
  }
}

String _$lastInvitationHash() => r'aaa6a3dfa0807b149e93bfd92a433434eb52b8fc';

abstract class _$LastInvitation extends $Notifier<LastInvitationResult?> {
  LastInvitationResult? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LastInvitationResult?, LastInvitationResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LastInvitationResult?, LastInvitationResult?>,
              LastInvitationResult?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
