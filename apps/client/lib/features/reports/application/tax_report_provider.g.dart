// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaxReport)
final taxReportProvider = TaxReportFamily._();

final class TaxReportProvider
    extends $AsyncNotifierProvider<TaxReport, GstReportEnvelopeDto> {
  TaxReportProvider._({
    required TaxReportFamily super.from,
    required TaxReportKind super.argument,
  }) : super(
         retry: null,
         name: r'taxReportProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taxReportHash();

  @override
  String toString() {
    return r'taxReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaxReport create() => TaxReport();

  @override
  bool operator ==(Object other) {
    return other is TaxReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taxReportHash() => r'f8373df36d621741dffcd5678a82fe11fc4312dc';

final class TaxReportFamily extends $Family
    with
        $ClassFamilyOverride<
          TaxReport,
          AsyncValue<GstReportEnvelopeDto>,
          GstReportEnvelopeDto,
          FutureOr<GstReportEnvelopeDto>,
          TaxReportKind
        > {
  TaxReportFamily._()
    : super(
        retry: null,
        name: r'taxReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TaxReportProvider call(TaxReportKind kind) =>
      TaxReportProvider._(argument: kind, from: this);

  @override
  String toString() => r'taxReportProvider';
}

abstract class _$TaxReport extends $AsyncNotifier<GstReportEnvelopeDto> {
  late final _$args = ref.$arg as TaxReportKind;
  TaxReportKind get kind => _$args;

  FutureOr<GstReportEnvelopeDto> build(TaxReportKind kind);
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
