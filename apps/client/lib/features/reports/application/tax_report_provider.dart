import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_refresh_provider.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/tax_report_kind.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_report_provider.g.dart';

@Riverpod(keepAlive: true)
class TaxReport extends _$TaxReport {
  @override
  Future<GstReportEnvelopeDto> build(TaxReportKind kind) async {
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    ref.watch(reportFiltersProvider);
    return runReportLoad(ref, () => _load(kind));
  }

  Future<void> refresh() async {
    await guardedReportRefresh(
      state,
      (value) => state = value,
      () => _load(kind),
    );
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    await refresh();
  }

  Future<GstReportEnvelopeDto> _load(TaxReportKind reportKind) async {
    final service = await ref.read(reportsServiceProvider.future);
    final query = ref.read(reportFiltersProvider).toQuery();
    return service.fetchTaxReport(reportKind, query);
  }
}

