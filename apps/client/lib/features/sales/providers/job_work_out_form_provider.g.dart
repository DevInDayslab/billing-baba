// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_work_out_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JobWorkOutFormNotifier)
final jobWorkOutFormProvider = JobWorkOutFormNotifierProvider._();

final class JobWorkOutFormNotifierProvider
    extends $NotifierProvider<JobWorkOutFormNotifier, JobWorkOutFormState> {
  JobWorkOutFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobWorkOutFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobWorkOutFormNotifierHash();

  @$internal
  @override
  JobWorkOutFormNotifier create() => JobWorkOutFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobWorkOutFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobWorkOutFormState>(value),
    );
  }
}

String _$jobWorkOutFormNotifierHash() =>
    r'd4e5f60718293a4b5c6d7e8f9012345678901234';

abstract class _$JobWorkOutFormNotifier
    extends $Notifier<JobWorkOutFormState> {
  JobWorkOutFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<JobWorkOutFormState, JobWorkOutFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<JobWorkOutFormState, JobWorkOutFormState>,
              JobWorkOutFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SavedJobWorkOutsNotifier)
final savedJobWorkOutsProvider = SavedJobWorkOutsNotifierProvider._();

final class SavedJobWorkOutsNotifierProvider
    extends
        $NotifierProvider<SavedJobWorkOutsNotifier, List<SavedJobWorkOut>> {
  SavedJobWorkOutsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedJobWorkOutsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedJobWorkOutsNotifierHash();

  @$internal
  @override
  SavedJobWorkOutsNotifier create() => SavedJobWorkOutsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedJobWorkOut> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedJobWorkOut>>(value),
    );
  }
}

String _$savedJobWorkOutsNotifierHash() =>
    r'e5f60718293a4b5c6d7e8f901234567890123456';

abstract class _$SavedJobWorkOutsNotifier
    extends $Notifier<List<SavedJobWorkOut>> {
  List<SavedJobWorkOut> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<List<SavedJobWorkOut>, List<SavedJobWorkOut>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SavedJobWorkOut>, List<SavedJobWorkOut>>,
              List<SavedJobWorkOut>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(jobWorkOutGrandTotal)
final jobWorkOutGrandTotalProvider = JobWorkOutGrandTotalProvider._();

final class JobWorkOutGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  JobWorkOutGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobWorkOutGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobWorkOutGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return jobWorkOutGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$jobWorkOutGrandTotalHash() =>
    r'f60718293a4b5c6d7e8f90123456789012345678';
