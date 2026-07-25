import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class GstrMonthFilterBar extends ConsumerStatefulWidget {
  const GstrMonthFilterBar({super.key});

  @override
  ConsumerState<GstrMonthFilterBar> createState() => _GstrMonthFilterBarState();
}

class _GstrMonthFilterBarState extends ConsumerState<GstrMonthFilterBar> {
  late DateTime _fromMonth;
  late DateTime _toMonth;

  static final _monthFormat = DateFormat('MM/yyyy');

  @override
  void initState() {
    super.initState();
    _syncFromFilters();
  }

  void _syncFromFilters() {
    final range = ref.read(reportFiltersProvider).customDateRange;
    final now = DateTime.now();
    if (range != null) {
      _fromMonth = DateTime(range.start.year, range.start.month);
      _toMonth = DateTime(range.end.year, range.end.month);
    } else {
      _fromMonth = DateTime(now.year, now.month);
      _toMonth = DateTime(now.year, now.month);
    }
  }

  void _applyRange() {
    ref
        .read(reportFiltersProvider.notifier)
        .setCustomDateRange(
          DateTimeRange(
            start: DateTime(_fromMonth.year, _fromMonth.month),
            end: DateTime(_toMonth.year, _toMonth.month + 1, 0),
          ),
        );
  }

  Future<void> _pickMonth({required bool isFrom}) async {
    final initial = isFrom ? _fromMonth : _toMonth;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final month = DateTime(picked.year, picked.month);
      if (isFrom) {
        _fromMonth = month;
      } else {
        _toMonth = month;
      }
    });
    _applyRange();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reportFiltersProvider, (_, __) {
      if (!mounted) return;
      setState(_syncFromFilters);
    });

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _MonthField(
          label: 'From:',
          value: _monthFormat.format(_fromMonth),
          onTap: () => _pickMonth(isFrom: true),
        ),
        _MonthField(
          label: 'To:',
          value: _monthFormat.format(_toMonth),
          onTap: () => _pickMonth(isFrom: false),
        ),
      ],
    );
  }
}

class _MonthField extends StatelessWidget {
  const _MonthField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: reportCardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
