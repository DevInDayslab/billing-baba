import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/party_statement_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/party_statement_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _dateColWidth = 120.0;
const _typeColWidth = 120.0;
const _refColWidth = 180.0;
const _totalColWidth = 110.0;
const _balanceColWidth = 110.0;

class PartyStatementTransactionsTable extends ConsumerWidget {
  const PartyStatementTransactionsTable({
    required this.entries,
    super.key,
  });

  final List<ReportPartyStatementEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnFilters = ref.watch(partyStatementColumnFiltersProvider);
    final filteredRows = applyPartyStatementColumnFilters(
      entries,
      columnFilters,
    );

    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No statement entries for this party.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    if (filteredRows.isEmpty) {
      return const Center(
        child: Text(
          'No statement entries match your filters.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final columns = _PartyStatementTableColumns.build(
      ref: ref,
      rows: entries,
    );
    final tableRows = [
      for (var i = 0; i < filteredRows.length; i++)
        _PartyStatementTableRows.buildDataRow(
          entry: filteredRows[i],
          isOdd: i.isOdd,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ResizableDataTable(
        columns: columns,
        rows: tableRows,
      ),
    );
  }
}

class _PartyStatementTableColumns {
  const _PartyStatementTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required List<ReportPartyStatementEntry> rows,
  }) {
    final filters = ref.watch(partyStatementColumnFiltersProvider);
    final filtersNotifier =
        ref.read(partyStatementColumnFiltersProvider.notifier);
    final typeOptions = reportUniqueSortedValues(
      rows.map((row) => row.type),
    );

    return [
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 96,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'date',
            title: 'Date',
            type: FilterType.date,
          ),
          initialValue: filters.dateColumnFilter,
          onApply: (result) => filtersNotifier.setDateColumnFilter(
            FilterUtils.fromResult(result) as DateColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _typeColWidth,
        minWidth: 96,
        header: TableColumnFilterTrigger(
          config: ColumnFilter(
            id: 'type',
            title: 'Type',
            type: FilterType.singleSelect,
            values: typeOptions,
          ),
          initialValue: filters.typeColumnFilter != null
              ? SelectColumnFilter(value: filters.typeColumnFilter!.value)
              : null,
          onApply: (result) => filtersNotifier.setTypeColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _refColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'refNo',
            title: 'Ref no.',
            type: FilterType.text,
            hintText: 'Reference number',
          ),
          initialValue: filters.refNoColumnFilter,
          onApply: (result) => filtersNotifier.setRefNoColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _totalColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'total',
            title: 'Total',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.totalColumnFilter,
          onApply: (result) => filtersNotifier.setTotalColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _balanceColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'balance',
            title: 'Balance',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.balanceColumnFilter,
          onApply: (result) => filtersNotifier.setBalanceColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _PartyStatementTableRows {
  const _PartyStatementTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ResizableDataRow buildDataRow({
    required ReportPartyStatementEntry entry,
    required bool isOdd,
  }) {
    final balanceColor = entry.balance > 0
        ? const Color(0xFFC62828)
        : entry.balance < 0
        ? const Color(0xFF2E7D32)
        : null;

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(entry.date))),
        _DataCell(child: Text(_formatType(entry.type))),
        _DataCell(
          child: Text(
            entry.refNo,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(entry.total),
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w500,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(entry.balance),
            style: TextStyle(
              color: balanceColor,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatType(String type) {
    if (type.isEmpty) return type;
    if (type.length == 1) return type.toUpperCase();
    return '${type[0].toUpperCase()}${type.substring(1)}';
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}
