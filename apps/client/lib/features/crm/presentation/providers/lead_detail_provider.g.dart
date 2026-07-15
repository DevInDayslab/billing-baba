// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LeadDetail)
final leadDetailProvider = LeadDetailFamily._();

final class LeadDetailProvider
    extends $StreamNotifierProvider<LeadDetail, LeadWithActivities?> {
  LeadDetailProvider._({
    required LeadDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leadDetailProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadDetailHash();

  @override
  String toString() {
    return r'leadDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LeadDetail create() => LeadDetail();

  @override
  bool operator ==(Object other) {
    return other is LeadDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadDetailHash() => r'4140e93fe536f0165f3e89522e6869b3901262a1';

final class LeadDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          LeadDetail,
          AsyncValue<LeadWithActivities?>,
          LeadWithActivities?,
          Stream<LeadWithActivities?>,
          String
        > {
  LeadDetailFamily._()
    : super(
        retry: null,
        name: r'leadDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  LeadDetailProvider call(String leadId) =>
      LeadDetailProvider._(argument: leadId, from: this);

  @override
  String toString() => r'leadDetailProvider';
}

abstract class _$LeadDetail extends $StreamNotifier<LeadWithActivities?> {
  late final _$args = ref.$arg as String;
  String get leadId => _$args;

  Stream<LeadWithActivities?> build(String leadId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LeadWithActivities?>, LeadWithActivities?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LeadWithActivities?>, LeadWithActivities?>,
              AsyncValue<LeadWithActivities?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
