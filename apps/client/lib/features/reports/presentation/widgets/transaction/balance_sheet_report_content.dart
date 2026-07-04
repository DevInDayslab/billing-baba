import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BalanceSheetReportContent extends ConsumerStatefulWidget {
  const BalanceSheetReportContent({super.key});

  @override
  ConsumerState<BalanceSheetReportContent> createState() =>
      _BalanceSheetReportContentState();
}

class _BalanceSheetReportContentState
    extends ConsumerState<BalanceSheetReportContent> {
  bool _horizontalView = true;

  static final _asOnFormat = DateFormat('MMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(balanceSheetReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(balanceSheetReportProvider.notifier).refresh(),
      data: (report) => ColoredBox(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Spacer(),
                  Text(
                    'Balance Sheet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  ReportPdfChip(),
                  SizedBox(width: AppSpacing.sm),
                  ReportXlsChip(),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const ReportCard(
                padding: EdgeInsets.all(AppSpacing.md),
                child: ReportPeriodFilterBar(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Text('Horizontal', style: TextStyle(fontSize: 13)),
                  Switch(
                    value: !_horizontalView,
                    onChanged: (v) => setState(() => _horizontalView = !v),
                  ),
                  const Text('Vertical', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Balance Sheet as on ${_asOnFormat.format(report.asOn)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ReportCard(
                child: _horizontalView
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _BalanceColumn(
                                    title: 'Assets',
                                    items: report.assets,
                                  ),
                                ),
                                const VerticalDivider(
                                  width: 1,
                                  color: reportCardBorder,
                                ),
                                Expanded(
                                  child: _BalanceColumn(
                                    title: 'Equities & Liabilities',
                                    items: report.liabilities,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _BalanceFooter(
                            assetsTotal: report.assetsTotal,
                            liabilitiesTotal: report.liabilitiesTotal,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BalanceColumn(
                            title: 'Assets',
                            items: report.assets,
                          ),
                          const Divider(height: 1, color: reportCardBorder),
                          _BalanceColumn(
                            title: 'Equities & Liabilities',
                            items: report.liabilities,
                          ),
                          _BalanceFooter(
                            assetsTotal: report.assetsTotal,
                            liabilitiesTotal: report.liabilitiesTotal,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceColumn extends StatelessWidget {
  const _BalanceColumn({required this.title, required this.items});

  final String title;
  final List<ReportBalanceSheetItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: reportTableHeaderBg,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(child: Text(title, style: reportTableHeaderStyle)),
              const Text('AMOUNT', style: reportTableHeaderStyle),
            ],
          ),
        ),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md + (item.indent * 12),
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          item.isHeader ? FontWeight.w700 : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (!item.isHeader)
                  Text(
                    formatReportCurrencyCompact(item.amount),
                    style: const TextStyle(fontSize: 13),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceFooter extends StatelessWidget {
  const _BalanceFooter({
    required this.assetsTotal,
    required this.liabilitiesTotal,
  });

  final double assetsTotal;
  final double liabilitiesTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: reportFooterBlue,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _FooterTotal(
                label: 'Total Assets',
                amount: formatReportCurrencyCompact(assetsTotal),
              ),
            ),
            const VerticalDivider(width: 1, color: Colors.white54),
            Expanded(
              child: _FooterTotal(
                label: 'Total Equities & Liabilities',
                amount: formatReportCurrencyCompact(liabilitiesTotal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterTotal extends StatelessWidget {
  const _FooterTotal({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
