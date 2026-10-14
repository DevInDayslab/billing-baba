import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _profitLossExpandBlue = Color(0xFF1565C0);
const _profitLossPositiveGreen = Color(0xFF2E7D32);

bool _isProfitLossSummaryRow(ReportProfitLossItem item) {
  return item.particular.startsWith('Net Profit');
}

bool _profitLossRowHasChildren(
  List<ReportProfitLossItem> items,
  int index,
) {
  if (!items[index].isHeader || _isProfitLossSummaryRow(items[index])) {
    return false;
  }
  final indent = items[index].indent;
  if (index + 1 >= items.length) return false;
  final next = items[index + 1];
  if (_isProfitLossSummaryRow(next)) return false;
  return next.indent > indent;
}

bool _isProfitLossRowVisible(
  List<ReportProfitLossItem> items,
  int index,
  Set<int> collapsedHeaders,
) {
  if (_isProfitLossSummaryRow(items[index])) return true;

  var indent = items[index].indent;
  for (var i = index - 1; i >= 0; i--) {
    final row = items[i];
    if (!row.isHeader) continue;
    if (row.indent < indent) {
      if (collapsedHeaders.contains(i)) return false;
      indent = row.indent;
    }
  }
  return true;
}

List<int> _profitLossCollapsibleHeaderIndices(
  List<ReportProfitLossItem> items,
) {
  return [
    for (var i = 0; i < items.length; i++)
      if (_profitLossRowHasChildren(items, i)) i,
  ];
}

class ProfitLossReportContent extends ConsumerStatefulWidget {
  const ProfitLossReportContent({super.key});

  @override
  ConsumerState<ProfitLossReportContent> createState() =>
      _ProfitLossReportContentState();
}

class _ProfitLossReportContentState
    extends ConsumerState<ProfitLossReportContent> {
  final Set<int> _collapsedHeaders = <int>{};

  bool _areAllAccountsExpanded(List<ReportProfitLossItem> items) {
    final collapsible = _profitLossCollapsibleHeaderIndices(items);
    if (collapsible.isEmpty) return true;
    return collapsible.every((index) => !_collapsedHeaders.contains(index));
  }

  void _toggleAllAccounts(List<ReportProfitLossItem> items) {
    setState(() {
      if (_areAllAccountsExpanded(items)) {
        _collapsedHeaders.addAll(_profitLossCollapsibleHeaderIndices(items));
      } else {
        _collapsedHeaders.clear();
      }
    });
  }

  void _toggleHeader(int index) {
    setState(() {
      if (_collapsedHeaders.contains(index)) {
        _collapsedHeaders.remove(index);
      } else {
        _collapsedHeaders.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(profitLossReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(profitLossReportProvider.notifier).refresh(),
      data: (report) {
        final items = report.items;
        final visibleIndices = <int>[
          for (var i = 0; i < items.length; i++)
            if (_isProfitLossRowVisible(items, i, _collapsedHeaders)) i,
        ];
        final allExpanded = _areAllAccountsExpanded(items);

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ReportDateRangeBar(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReportIconActionButton(
                        icon: Icons.picture_as_pdf_outlined,
                        tooltip: 'Export PDF',
                      ),
                      ReportIconActionButton(
                        icon: Icons.print_outlined,
                        tooltip: 'Print',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ReportCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'PROFIT AND LOSS REPORT',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A237E),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => _toggleAllAccounts(items),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    allExpanded
                                        ? 'Collapse all accounts'
                                        : 'Expand all accounts',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _profitLossExpandBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    allExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: _profitLossExpandBlue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportSyncScrollTable(
                            minWidth: 480,
                            headerChildren: const [
                              Expanded(
                                child: ReportAlignedHeaderCell(
                                  label: 'Particulars',
                                  showFilter: false,
                                ),
                              ),
                              ReportAlignedHeaderCell(
                                label: 'Amount',
                                width: 120,
                                alignment: Alignment.centerRight,
                                showFilter: false,
                              ),
                            ],
                            rows: [
                              for (var rowIndex = 0;
                                  rowIndex < visibleIndices.length;
                                  rowIndex++)
                                ReportAlignedRowStrip(
                                  index: rowIndex,
                                  child: _ProfitLossRow(
                                    item: items[visibleIndices[rowIndex]],
                                    sourceIndex: visibleIndices[rowIndex],
                                    items: items,
                                    isCollapsed: _collapsedHeaders.contains(
                                      visibleIndices[rowIndex],
                                    ),
                                    onToggle: _profitLossRowHasChildren(
                                      items,
                                      visibleIndices[rowIndex],
                                    )
                                        ? () => _toggleHeader(
                                            visibleIndices[rowIndex],
                                          )
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfitLossRow extends StatelessWidget {
  const _ProfitLossRow({
    required this.item,
    required this.sourceIndex,
    required this.items,
    required this.isCollapsed,
    this.onToggle,
  });

  final ReportProfitLossItem item;
  final int sourceIndex;
  final List<ReportProfitLossItem> items;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final isSummary = _isProfitLossSummaryRow(item);
    final hasChildren = _profitLossRowHasChildren(items, sourceIndex);
    final indentPadding =
        AppSpacing.md + (item.indent * AppSpacing.lg) + (hasChildren ? 0 : 20);

    final textStyle = isSummary
        ? const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )
        : item.isHeader
        ? const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          )
        : const TextStyle(fontSize: 13, color: AppColors.textPrimary);

    final amountColor = isSummary
        ? (item.amount >= 0 ? _profitLossPositiveGreen : reportAddRed)
        : (item.amount < 0 ? reportAddRed : AppColors.textPrimary);

    return ReportAlignedDataRow(
      padding: EdgeInsets.fromLTRB(
        indentPadding,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      cells: [
        ReportAlignedCell.flex(
          child: Row(
            children: [
              if (hasChildren)
                InkWell(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      isCollapsed
                          ? Icons.arrow_right
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: _profitLossExpandBlue,
                    ),
                  ),
                ),
              Expanded(child: Text(item.particular, style: textStyle)),
            ],
          ),
        ),
        ReportAlignedCell.fixed(
          120,
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrency(item.amount),
            style: textStyle.copyWith(color: amountColor),
          ),
        ),
      ],
    );
  }
}
