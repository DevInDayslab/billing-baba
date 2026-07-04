// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_work_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(jobWorkService)
final jobWorkServiceProvider = JobWorkServiceProvider._();

final class JobWorkServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<JobWorkService>,
          JobWorkService,
          FutureOr<JobWorkService>
        >
    with $FutureModifier<JobWorkService>, $FutureProvider<JobWorkService> {
  JobWorkServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobWorkServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobWorkServiceHash();

  @$internal
  @override
  $FutureProviderElement<JobWorkService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<JobWorkService> create(Ref ref) {
    return jobWorkService(ref);
  }
}

String _$jobWorkServiceHash() => r'7389a89cf5ac4d900ca5cb6c7361a851345b7e64';
