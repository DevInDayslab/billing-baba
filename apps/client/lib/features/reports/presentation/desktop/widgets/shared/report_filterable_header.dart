import 'package:billing_baba/features/reports/application/report_table_column_filters_provider.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_utils.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportFilterableHeaderCell extends ConsumerWidget {
  const ReportFilterableHeaderCell({
    required this.reportScope,
    required this.columnId,
    required this.label,
    required this.filterType,
    this.width,
    this.flex = 0,
    this.alignment = Alignment.centerLeft,
    this.hintText,
    this.filterOptions = const [],
    this.showFilter = true,
    super.key,
  });

  final String reportScope;
  final String columnId;
  final String label;
  final FilterType filterType;
  final double? width;
  final int flex;
  final Alignment alignment;
  final String? hintText;
  final List<String> filterOptions;
  final bool showFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(
      reportTableColumnFiltersProvider.select(
        (state) => state[reportScope] ?? const {},
      ),
    );
    final initialValue = filters[columnId];

    Widget header;
    if (!showFilter) {
      header = ReportAlignedHeaderCell(
        label: label,
        width: width,
        alignment: alignment,
        showFilter: false,
      );
    } else {
      header = TableColumnFilterTrigger(
        config: ColumnFilter(
          id: columnId,
          title: label,
          type: filterType,
          values: filterOptions,
          hintText: hintText,
        ),
        initialValue: initialValue,
        alignment: alignment,
        headerStyle: reportTableHeaderStyle.copyWith(fontSize: 11),
        onApply: (result) {
          ref
              .read(reportTableColumnFiltersProvider.notifier)
              .setFilter(reportScope, columnId, FilterUtils.fromResult(result));
        },
      );
    }

    if (width != null) {
      return SizedBox(width: width, child: header);
    }
    if (flex > 0) {
      return Expanded(flex: flex, child: header);
    }
    return header;
  }
}
