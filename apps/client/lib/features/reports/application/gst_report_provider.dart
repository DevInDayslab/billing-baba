import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_refresh_provider.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/models/gst_report_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gst_report_provider.g.dart';

@Riverpod(keepAlive: true)
class GstReport extends _$GstReport {
  @override
  Future<GstReportEnvelopeDto> build(GstReportType type) async {
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    ref.watch(reportFiltersProvider);
    return runReportLoad(ref, () => _load(type));
  }

  Future<void> refresh() async {
    await guardedReportRefresh(
      state,
      (value) => state = value,
      () => _load(type),
    );
  }

  Future<GstReportEnvelopeDto> _load(GstReportType type) async {
    final service = await ref.read(reportsServiceProvider.future);
    final query = ref.read(reportFiltersProvider).toQuery();
    return service.fetchGstFilingReport(type, query);
  }
}
