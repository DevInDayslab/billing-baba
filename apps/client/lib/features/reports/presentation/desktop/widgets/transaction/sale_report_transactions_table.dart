import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/sale_report_column_filters_provider.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/sale_report_row_filter.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_invoice_status_badge.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _dateColWidth = 120.0;
const _invoiceColWidth = 120.0;
const _partyColWidth = 180.0;
const _transactionColWidth = 120.0;
const _paymentColWidth = 120.0;
const _statusColWidth = 100.0;
const _amountColWidth = 110.0;
const _balanceColWidth = 100.0;
const _actionsColWidth = 100.0;

const _saleReportStatusFilterOptions = [
  'Paid',
  'Unpaid',
  'Partial',
  'Overdue',
  'Cancelled',
];

const _defaultTransactionTypeOptions = [
  'Tax Invoice',
  'Bill of Supply',
  'Normal Invoice',
  'POS',
];

class SaleReportTransactionsTable extends ConsumerWidget {
  const SaleReportTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(saleReportProvider);
    final columnFilters = ref.watch(saleReportColumnFiltersProvider);
    final isTableLoading = ref.watch(
      reportFiltersProvider.select((filters) => filters.isTableLoading),
    );
    final isReloading = reportIsTableReloading(reportAsync, isTableLoading);

    return ReportReloadScope(
      isReloading: isReloading,
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (report) {
          final filteredRows = applySaleReportColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;
          final columns = _SaleReportTableColumns.build(
            ref: ref,
            rows: report.rows,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _SaleReportTableRows.buildDataRow(
                invoice: filteredRows[i],
                isOdd: i.isOdd,
              ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              columnFilters.hasActiveFilters
                                  ? '${filteredRows.length} shown · ${meta.total} total'
                                  : '${meta.total} total',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: ReportSearchField(
                          hintText: 'Search invoices...',
                        ),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      Expanded(
                        child: ReportTableArea(
                          child: filteredRows.isEmpty
                              ? Center(
                                  child: Text(
                                    columnFilters.hasActiveFilters
                                        ? 'No transactions match your filters'
                                        : 'No transactions to show',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  child: ResizableDataTable(
                                    columns: columns,
                                    rows: tableRows,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ReportPaginationBar(
                page: meta.page,
                totalPages: meta.totalPages,
                onPrevious: meta.page > 1
                    ? () => ref
                          .read(saleReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(saleReportProvider.notifier)
                          .goToPage(meta.page + 1)
                    : null,
              ),
            ],
          );
        },
        skipLoadingOnReload: true,
      ),
    );
  }
}
class _SaleReportTableColumns {
  const _SaleReportTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required List<SaleInvoiceModel> rows,
  }) {
    final filters = ref.watch(saleReportColumnFiltersProvider);
    final filtersNotifier = ref.read(saleReportColumnFiltersProvider.notifier);
    final transactionOptions = _uniqueSortedValues([
      ..._defaultTransactionTypeOptions,
      ...rows.map((row) => row.transactionType),
    ]);
    final paymentOptions = _uniqueSortedValues([
      ...SaleDropdownOptions.paymentTypes,
      ...rows.map((row) => row.paymentType),
    ]);

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
        initialWidth: _invoiceColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'invoiceNo',
            title: 'Invoice no',
            type: FilterType.text,
            hintText: 'Invoice number',
          ),
          initialValue: filters.invoiceNoColumnFilter,
          onApply: (result) => filtersNotifier.setInvoiceNoColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Party Name',
            type: FilterType.text,
            hintText: 'Party name',
          ),
          initialValue: filters.partyNameColumnFilter,
          onApply: (result) => filtersNotifier.setPartyNameColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _transactionColWidth,
        header: TableColumnFilterTrigger(
          config: ColumnFilter(
            id: 'transaction',
            title: 'Transaction',
            type: FilterType.singleSelect,
            values: transactionOptions,
          ),
          initialValue: filters.transactionTypeColumnFilter != null
              ? SelectColumnFilter(
                  value: filters.transactionTypeColumnFilter!.value,
                )
              : null,
          onApply: (result) => filtersNotifier.setTransactionTypeColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _paymentColWidth,
        header: TableColumnFilterTrigger(
          config: ColumnFilter(
            id: 'paymentType',
            title: 'Payment Type',
            type: FilterType.singleSelect,
            values: paymentOptions,
          ),
          initialValue: filters.paymentTypeColumnFilter != null
              ? SelectColumnFilter(
                  value: filters.paymentTypeColumnFilter!.value,
                )
              : null,
          onApply: (result) => filtersNotifier.setPaymentTypeColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'status',
            title: 'Status',
            type: FilterType.singleSelect,
            values: _saleReportStatusFilterOptions,
          ),
          initialValue: filters.statusColumnFilter != null
              ? SelectColumnFilter(value: filters.statusColumnFilter!.value)
              : null,
          onApply: (result) => filtersNotifier.setStatusColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'amount',
            title: 'Amount',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.amountColumnFilter,
          onApply: (result) => filtersNotifier.setAmountColumnFilter(
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
      const ResizableDataColumn(
        initialWidth: _actionsColWidth,
        resizable: false,
        header: _HeaderCell(label: 'Actions'),
      ),
    ];
  }

  static List<String> _uniqueSortedValues(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}

class _SaleReportTableRows {
  const _SaleReportTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ResizableDataRow buildDataRow({
    required SaleInvoiceModel invoice,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(invoice.date))),
        _DataCell(child: Text(invoice.invoiceNo)),
        _DataCell(
          child: Text(
            invoice.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(invoice.transactionType)),
        _DataCell(child: Text(invoice.paymentType)),
        _DataCell(
          child: SaleInvoiceStatusBadge(status: invoice.status),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(invoice.amount),
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
            formatReportCurrencyCompact(invoice.balance),
            style: TextStyle(
              color: invoice.balance > 0 ? const Color(0xFFC62828) : null,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const _DataCell(child: SizedBox.shrink()),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: _headerStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final Alignment alignment;

  static const _dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: _dataStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: Align(
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}

