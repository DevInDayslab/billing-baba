import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
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
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  bool _horizontalView = true;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 4, 1),
    end: DateTime(2026, 7, 3),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _asOnFormat = DateFormat('MMM dd, yyyy');

  static double _itemsTotal(List<ReportBalanceSheetItem> items) =>
      items.where((item) => !item.isHeader).fold(0.0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(reportBalanceSheetAssetsProvider);
    final liabilities = ref.watch(reportBalanceSheetLiabilitiesProvider);
    final assetsTotal = _itemsTotal(assets);
    final liabilitiesTotal = _itemsTotal(liabilities);

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Spacer(),
                const Text(
                  'Balance Sheet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const ReportPdfChip(),
                const SizedBox(width: AppSpacing.sm),
                const ReportXlsChip(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: reportCardBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(_dateFormat.format(_dateRange.start)),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: Text(
                              'To',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          SaleDateRangePickerAnchor(
                            key: _datePickerKey,
                            initialRange: _dateRange,
                            onRangeSelected: (range) =>
                                setState(() => _dateRange = range),
                            child: SaleFilterChip(
                              label: _dateFormat.format(_dateRange.end),
                              onTap: () =>
                                  _datePickerKey.currentState?.toggle(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
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
              'Balance Sheet as on ${_asOnFormat.format(_dateRange.end)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _BalanceColumn(
                            title: 'Assets',
                            items: assets,
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          color: reportCardBorder,
                        ),
                        Expanded(
                          child: _BalanceColumn(
                            title: 'Equities & Liabilities',
                            items: liabilities,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
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
                              amount: formatReportCurrency(assetsTotal),
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            color: Colors.white54,
                          ),
                          Expanded(
                            child: _FooterTotal(
                              label: 'Total Equities & Liabilities',
                              amount: formatReportCurrency(liabilitiesTotal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              Expanded(
                child: Text(
                  title,
                  style: reportTableHeaderStyle,
                ),
              ),
              const Text('AMOUNT', style: reportTableHeaderStyle),
            ],
          ),
        ),
        for (var i = 0; i < items.length; i++) _BalanceSheetItemRow(item: items[i]),
      ],
    );
  }
}

class _BalanceSheetItemRow extends StatelessWidget {
  const _BalanceSheetItemRow({required this.item});

  final ReportBalanceSheetItem item;

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

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: reportCardBorder)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          indentPadding,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(child: Text(item.name, style: textStyle)),
            Text(
              item.isHeader ? '' : formatReportCurrency(item.amount),
              style: textStyle,
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
