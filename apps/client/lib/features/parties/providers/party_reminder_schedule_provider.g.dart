// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_reminder_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(partyReminderScheduleRepository)
final partyReminderScheduleRepositoryProvider =
    PartyReminderScheduleRepositoryProvider._();

final class PartyReminderScheduleRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PartyReminderScheduleRepository>,
          PartyReminderScheduleRepository,
          FutureOr<PartyReminderScheduleRepository>
        >
    with
        $FutureModifier<PartyReminderScheduleRepository>,
        $FutureProvider<PartyReminderScheduleRepository> {
  PartyReminderScheduleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyReminderScheduleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyReminderScheduleRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PartyReminderScheduleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PartyReminderScheduleRepository> create(Ref ref) {
    return partyReminderScheduleRepository(ref);
  }
}

String _$partyReminderScheduleRepositoryHash() =>
    r'a48ad6ccc0f0e6b62b2e86f0ea3a76ce269f4123';

@ProviderFor(PartyReminderScheduleMap)
final partyReminderScheduleMapProvider = PartyReminderScheduleMapProvider._();

final class PartyReminderScheduleMapProvider
    extends
        $AsyncNotifierProvider<
          PartyReminderScheduleMap,
          Map<String, PartyReminderSchedule>
        > {
  PartyReminderScheduleMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyReminderScheduleMapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyReminderScheduleMapHash();

  @$internal
  @override
  PartyReminderScheduleMap create() => PartyReminderScheduleMap();
}

String _$partyReminderScheduleMapHash() =>
    r'405915e1ffb8f4a30b75db94ae851aa319de0b78';

abstract class _$PartyReminderScheduleMap
    extends $AsyncNotifier<Map<String, PartyReminderSchedule>> {
  FutureOr<Map<String, PartyReminderSchedule>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, PartyReminderSchedule>>,
              Map<String, PartyReminderSchedule>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, PartyReminderSchedule>>,
                Map<String, PartyReminderSchedule>
              >,
              AsyncValue<Map<String, PartyReminderSchedule>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(partyNextReminder)
final partyNextReminderProvider = PartyNextReminderFamily._();

final class PartyNextReminderProvider
    extends
        $FunctionalProvider<
          PartyReminderSchedule?,
          PartyReminderSchedule?,
          PartyReminderSchedule?
        >
    with $Provider<PartyReminderSchedule?> {
  PartyNextReminderProvider._({
    required PartyNextReminderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyNextReminderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyNextReminderHash();

  @override
  String toString() {
    return r'partyNextReminderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<PartyReminderSchedule?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PartyReminderSchedule? create(Ref ref) {
    final argument = this.argument as String;
    return partyNextReminder(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PartyReminderSchedule? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PartyReminderSchedule?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PartyNextReminderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyNextReminderHash() => r'249985439b13d92a0c8533fbcaae09c87110719f';

final class PartyNextReminderFamily extends $Family
    with $FunctionalFamilyOverride<PartyReminderSchedule?, String> {
  PartyNextReminderFamily._()
    : super(
        retry: null,
        name: r'partyNextReminderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PartyNextReminderProvider call(String partyId) =>
      PartyNextReminderProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyNextReminderProvider';
}
