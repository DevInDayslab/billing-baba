import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/application/all_parties_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/utils/all_parties_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _indexColWidth = 48.0;
const _nameColWidth = 200.0;
const _emailColWidth = 160.0;
const _phoneColWidth = 120.0;
const _receivableColWidth = 140.0;
const _payableColWidth = 130.0;
const _creditLimitColWidth = 120.0;

class AllPartiesTransactionsTable extends ConsumerWidget {
  const AllPartiesTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(partyOutstandingReportProvider);
    final columnFilters = ref.watch(allPartiesColumnFiltersProvider);
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
          final filteredRows = applyAllPartiesColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;

          final columns = _AllPartiesTableColumns.build(ref: ref);
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _AllPartiesTableRows.buildDataRow(
                index: (meta.page - 1) * meta.limit + i,
                party: filteredRows[i],
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
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const ReportDisabledDateFilter(),
                            const ReportPartyTypeFilter(),
                            const ReportPartyGroupFilter(),
                            const ReportPartyStatusFilter(),
                            const ReportDisabledBusinessFilter(),
                            const ReportPageSizeFilter(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ReportSearchField(
                                onChanged: ref
                                    .read(reportFiltersProvider.notifier)
                                    .setSearchQuery,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
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
                      const Divider(height: 1, color: _cardBorder),
                      Expanded(
                        child: ReportTableArea(
                          child: filteredRows.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'No parties to display.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Add parties to see them here.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
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
                          .read(partyOutstandingReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(partyOutstandingReportProvider.notifier)
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

class _AllPartiesTableColumns {
  const _AllPartiesTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(allPartiesColumnFiltersProvider);
    final filtersNotifier = ref.read(allPartiesColumnFiltersProvider.notifier);

    return [
      const ResizableDataColumn(
        initialWidth: _indexColWidth,
        resizable: false,
        header: _HeaderCell(label: '#'),
      ),
      ResizableDataColumn(
        initialWidth: _nameColWidth,
        minWidth: 140,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Party name',
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
        initialWidth: _emailColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'email',
            title: 'Email',
            type: FilterType.text,
            hintText: 'Email',
          ),
          initialValue: filters.emailColumnFilter,
          onApply: (result) => filtersNotifier.setEmailColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _phoneColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'phone',
            title: 'Phone no.',
            type: FilterType.text,
            hintText: 'Phone number',
          ),
          initialValue: filters.phoneColumnFilter,
          onApply: (result) => filtersNotifier.setPhoneColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _receivableColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'receivable',
            title: 'Receivable balance',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.receivableColumnFilter,
          onApply: (result) => filtersNotifier.setReceivableColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _payableColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'payable',
            title: 'Payable balance',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.payableColumnFilter,
          onApply: (result) => filtersNotifier.setPayableColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _creditLimitColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'creditLimit',
            title: 'Credit limit',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.creditLimitColumnFilter,
          onApply: (result) => filtersNotifier.setCreditLimitColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _AllPartiesTableRows {
  const _AllPartiesTableRows._();

  static ResizableDataRow buildDataRow({
    required int index,
    required PartyModel party,
    required bool isOdd,
  }) {
    final email = party.email.isEmpty ? '—' : party.email;
    final receivable = party.balance > 0
        ? formatReportCurrencyCompact(party.balance)
        : '—';
    final payable = party.balance < 0
        ? formatReportCurrencyCompact(party.balance.abs())
        : '—';
    final creditLimit = party.creditLimit.isEmpty
        ? '—'
        : formatReportCurrencyCompact(
            double.tryParse(party.creditLimit) ?? 0,
          );

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text('${index + 1}')),
        _DataCell(
          child: Text(
            party.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          child: Text(
            email,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(party.phone)),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            receivable,
            style: receivable == '—'
                ? null
                : const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            payable,
            style: payable == '—'
                ? null
                : const TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            creditLimit,
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Align(alignment: alignment, child: child),
    );
  }
}
