import 'package:billing_baba/features/reports/application/report_table_column_filters_provider.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_header.dart';
import 'package:billing_baba/features/reports/utils/report_column_filter_utils.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ReportCellBuilder<T> = ReportAlignedCell Function(T row, int index);

/// Column definition for [ReportFilterableSyncTable].
class ReportColumnSpec<T> {
  const ReportColumnSpec({
    required this.id,
    required this.label,
    required this.filterType,
    required this.filterValue,
    required this.buildCell,
    this.width,
    this.flex = 0,
    this.alignment = Alignment.centerLeft,
    this.hintText,
    this.filterOptions = const [],
    this.showFilter = true,
  });

  final String id;
  final String label;
  final FilterType filterType;
  final Object? Function(T row) filterValue;
  final ReportCellBuilder<T> buildCell;
  final double? width;
  final int flex;
  final Alignment alignment;
  final String? hintText;
  final List<String> filterOptions;
  final bool showFilter;
}

class ReportFilterableSyncTable<T> extends ConsumerWidget {
  const ReportFilterableSyncTable({
    required this.reportScope,
    required this.columns,
    required this.rows,
    this.minWidth = 960,
    this.emptyState,
    super.key,
  });

  final String reportScope;
  final List<ReportColumnSpec<T>> columns;
  final List<T> rows;
  final double minWidth;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(
      reportTableColumnFiltersProvider.select(
        (state) => state[reportScope] ?? const {},
      ),
    );

    final filteredRows = rows
        .where(
          (row) => reportMatchesColumnFilters(
            row: row,
            columns: columns,
            filters: filters,
          ),
        )
        .toList();

    final headerChildren = [
      for (final column in columns)
        ReportFilterableHeaderCell(
          reportScope: reportScope,
          columnId: column.id,
          label: column.label,
          filterType: column.filterType,
          width: column.width,
          flex: column.flex,
          alignment: column.alignment,
          hintText: column.hintText,
          filterOptions: column.filterOptions,
          showFilter: column.showFilter,
        ),
    ];

    final tableRows = [
      for (var i = 0; i < filteredRows.length; i++)
        ReportAlignedRowStrip(
          index: i,
          child: ReportAlignedDataRow(
            cells: [
              for (final column in columns)
                column.buildCell(filteredRows[i], i),
            ],
          ),
        ),
    ];

    return ReportSyncScrollTable(
      minWidth: minWidth,
      headerChildren: headerChildren,
      rows: tableRows,
      emptyState: emptyState,
    );
  }
}
