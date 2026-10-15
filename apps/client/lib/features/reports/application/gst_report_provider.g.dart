// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gst_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GstReport)
final gstReportProvider = GstReportFamily._();

final class GstReportProvider
    extends $AsyncNotifierProvider<GstReport, GstReportEnvelopeDto> {
  GstReportProvider._({
    required GstReportFamily super.from,
    required GstReportType super.argument,
  }) : super(
         retry: null,
         name: r'gstReportProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gstReportHash();

  @override
  String toString() {
    return r'gstReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GstReport create() => GstReport();

  @override
  bool operator ==(Object other) {
    return other is GstReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gstReportHash() => r'50950d88d252a6864c7d2d994200c4159f348e51';

final class GstReportFamily extends $Family
    with
        $ClassFamilyOverride<
          GstReport,
          AsyncValue<GstReportEnvelopeDto>,
          GstReportEnvelopeDto,
          FutureOr<GstReportEnvelopeDto>,
          GstReportType
        > {
  GstReportFamily._()
    : super(
        retry: null,
        name: r'gstReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GstReportProvider call(GstReportType type) =>
      GstReportProvider._(argument: type, from: this);

  @override
  String toString() => r'gstReportProvider';
}

abstract class _$GstReport extends $AsyncNotifier<GstReportEnvelopeDto> {
  late final _$args = ref.$arg as GstReportType;
  GstReportType get type => _$args;

  FutureOr<GstReportEnvelopeDto> build(GstReportType type);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<GstReportEnvelopeDto>, GstReportEnvelopeDto>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<GstReportEnvelopeDto>,
                GstReportEnvelopeDto
              >,
              AsyncValue<GstReportEnvelopeDto>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
