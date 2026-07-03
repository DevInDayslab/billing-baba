import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceSheetReportContent extends StatefulWidget {
  const BalanceSheetReportContent({super.key});

  @override
  State<BalanceSheetReportContent> createState() =>
      _BalanceSheetReportContentState();
}

class _BalanceSheetReportContentState extends State<BalanceSheetReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  bool _horizontalView = true;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 4),
    end: DateTime(2026, 7, 3),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _asOnFormat = DateFormat('MMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
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
                  const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _BalanceColumn(title: 'Assets')),
                        VerticalDivider(
                          width: 1,
                          color: reportCardBorder,
                        ),
                        Expanded(
                          child: _BalanceColumn(
                            title: 'Equities & Liabilities',
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
                    child: const IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _FooterTotal(
                              label: 'Total Assets',
                              amount: '0.00',
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            color: Colors.white54,
                          ),
                          Expanded(
                            child: _FooterTotal(
                              label: 'Total Equities & Liabilities',
                              amount: '0.00',
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
  const _BalanceColumn({required this.title});

  final String title;

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
        const SizedBox(height: 120),
      ],
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
