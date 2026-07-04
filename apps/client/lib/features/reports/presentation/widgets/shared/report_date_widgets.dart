import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDateRangeBar extends StatefulWidget {
  const ReportDateRangeBar({
    this.fromLabel = 'From:',
    this.toLabel = 'To:',
    this.trailing,
    super.key,
  });

  final String fromLabel;
  final String toLabel;
  final Widget? trailing;

  @override
  State<ReportDateRangeBar> createState() => _ReportDateRangeBarState();
}

class _ReportDateRangeBarState extends State<ReportDateRangeBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7, 1),
    end: DateTime(2026, 7, 3),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Row(
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.fromLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _dateFormat.format(_dateRange.start),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      widget.toLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                        onTap: () => _datePickerKey.currentState?.toggle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          widget.trailing!,
        ],
      ],
    );
  }
}

class ReportPeriodFilterBar extends StatefulWidget {
  const ReportPeriodFilterBar({
    this.showFirmFilter = true,
    this.trailing,
    super.key,
  });

  final bool showFirmFilter;
  final Widget? trailing;

  @override
  State<ReportPeriodFilterBar> createState() => _ReportPeriodFilterBarState();
}

class _ReportPeriodFilterBarState extends State<ReportPeriodFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _period = 'This Month';
  String _firm = 'ALL FIRMS';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2025, 9, 1),
    end: DateTime(2025, 9, 30),
  );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SaleFilterDropdown(
          label: _period,
          options: const [
            'All Time',
            'Today',
            'This Week',
            'This Month',
            'This Year',
            'Custom',
          ],
          selected: _period,
          onSelected: (value) => setState(() => _period = value),
        ),
        const Text(
          'Between',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        SaleDateRangePickerAnchor(
          key: _datePickerKey,
          initialRange: _dateRange,
          onRangeSelected: (range) => setState(() => _dateRange = range),
          child: SaleFilterChip(
            label: formatSaleDateRangeLabel(_dateRange),
            onTap: () => _datePickerKey.currentState?.toggle(),
          ),
        ),
        if (widget.showFirmFilter)
          SaleFilterDropdown(
            label: _firm,
            options: const ['ALL FIRMS', 'Firm A', 'Firm B'],
            selected: _firm,
            onSelected: (value) => setState(() => _firm = value),
          ),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }
}

class ReportMoneySummaryFooter extends StatelessWidget {
  const ReportMoneySummaryFooter({
    required this.items,
    super.key,
  });

  final List<ReportMoneySummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: reportCardBorder)),
      ),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.sm,
        children: items.map((item) => _FooterItem(item: item)).toList(),
      ),
    );
  }
}

class ReportMoneySummaryItem {
  const ReportMoneySummaryItem({
    required this.label,
    required this.amount,
    this.color,
    this.bold = false,
  });

  final String label;
  final String amount;
  final Color? color;
  final bool bold;
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({required this.item});

  final ReportMoneySummaryItem item;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: item.bold ? FontWeight.w700 : FontWeight.w500,
      color: item.color ?? AppColors.textPrimary,
    );

    return Text('${item.label}: ${item.amount}', style: style);
  }
}
