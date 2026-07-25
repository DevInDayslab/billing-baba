import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfitLossReportContent extends ConsumerStatefulWidget {
  const ProfitLossReportContent({super.key});

  @override
  ConsumerState<ProfitLossReportContent> createState() =>
      _ProfitLossReportContentState();
}

class _ProfitLossReportContentState
    extends ConsumerState<ProfitLossReportContent> {
  String _viewMode = 'Vyapar';

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(profitLossReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(profitLossReportProvider.notifier).refresh(),
      data: (report) {
        final items = report.items;
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'View :',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Radio<String>(
                                value: 'Vyapar',
                                groupValue: _viewMode,
                                onChanged: (v) => setState(() => _viewMode = v!),
                                visualDensity: VisualDensity.compact,
                              ),
                              const Text(
                                'Vyapar',
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Radio<String>(
                                value: 'Accounting',
                                groupValue: _viewMode,
                                onChanged: (v) => setState(() => _viewMode = v!),
                                visualDensity: VisualDensity.compact,
                              ),
                              const Text(
                                'Accounting',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
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
                              for (var i = 0; i < items.length; i++)
                                ReportAlignedRowStrip(
                                  index: i,
                                  child: _ProfitLossRow(item: items[i], index: i),
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
  const _ProfitLossRow({required this.item, required this.index});

  final ReportProfitLossItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final indentPadding = AppSpacing.md + (item.indent * AppSpacing.lg);
    final textStyle = item.isHeader
        ? const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )
        : const TextStyle(fontSize: 13, color: AppColors.textPrimary);

    return ReportAlignedDataRow(
      padding: EdgeInsets.fromLTRB(
        indentPadding,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      cells: [
        ReportAlignedCell.flex(
          child: Text(item.particular, style: textStyle),
        ),
        ReportAlignedCell.fixed(
          120,
          alignment: Alignment.centerRight,
          child: Text(
            item.isHeader && item.amount == 0
                ? ''
                : formatReportCurrency(item.amount),
            style: textStyle.copyWith(
              color: item.amount < 0 ? reportAddRed : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
