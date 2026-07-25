import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs a report fetch and clears the table loading flag when complete.
Future<T> runReportLoad<T>(Ref ref, Future<T> Function() load) async {
  try {
    return await load();
  } finally {
    ref.read(reportFiltersProvider.notifier).clearTableLoading();
  }
}

/// Whether the report table should show a reload overlay.
bool reportIsTableReloading(AsyncValue<dynamic> value, bool isTableLoading) {
  return value.isReloading || value.isRefreshing || isTableLoading;
}
