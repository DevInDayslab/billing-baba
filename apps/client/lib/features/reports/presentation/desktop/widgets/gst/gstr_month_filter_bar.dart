import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:flutter/material.dart';

/// GST report date filter — single **Between** range using the shared sale calendar.
@Deprecated('Use ReportFromToDateFilter directly')
class GstrMonthFilterBar extends StatelessWidget {
  @Deprecated('Use ReportFromToDateFilter directly')
  const GstrMonthFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReportFromToDateFilter();
  }
}
