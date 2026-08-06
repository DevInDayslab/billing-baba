import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

enum _MobileReportFilterSection {
  partyType,
  paymentMode,
  status,
}

extension on _MobileReportFilterSection {
  String get label => switch (this) {
    _MobileReportFilterSection.partyType => 'Party type',
    _MobileReportFilterSection.paymentMode => 'Payment mode',
    _MobileReportFilterSection.status => 'Status',
  };
}

/// Result applied from the mobile report filters sheet.
class MobileReportFilterDraft {
  const MobileReportFilterDraft({
    this.partyType,
    this.paymentMode,
    this.status,
  });

  factory MobileReportFilterDraft.fromState(ReportFiltersState state) {
    return MobileReportFilterDraft(
      partyType: state.partyType,
      paymentMode: state.paymentMode,
      status: state.status,
    );
  }

  final String? partyType;
  final String? paymentMode;
  final String? status;
}

/// Opens the common mobile report filters bottom sheet.
Future<MobileReportFilterDraft?> showMobileReportFilterSheet({
  required BuildContext context,
  required ReportFiltersState initial,
}) {
  return showMobileBottomSheet<MobileReportFilterDraft>(
    context: context,
    maxHeightFraction: 0.72,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filters',
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          _MobileReportFilterBody(
            initial: MobileReportFilterDraft.fromState(initial),
            sheetContext: sheetContext,
          ),
        ],
      );
    },
  );
}

/// Applies [draft] to [reportFiltersProvider] and returns whether anything changed.
bool applyMobileReportFilterDraft(
  WidgetRef ref,
  MobileReportFilterDraft draft,
) {
  final notifier = ref.read(reportFiltersProvider.notifier);
  final current = ref.read(reportFiltersProvider);
  final changed =
      current.partyType != draft.partyType ||
      current.paymentMode != draft.paymentMode ||
      current.status != draft.status;

  notifier
    ..setPartyType(draft.partyType)
    ..setPaymentMode(draft.paymentMode)
    ..setStatus(draft.status);
  return changed;
}

/// Builds live filter chips from [reportFiltersProvider] (+ optional extras).
List<String> buildMobileReportFilterChips(
  ReportFiltersState filters, {
  List<String> extraChips = const [],
}) {
  final chips = <String>[
    switch (filters.partyType) {
      'customer' => 'Party - Customers',
      'supplier' => 'Party - Suppliers',
      _ => 'Party - All',
    },
    _paymentModeChip(filters.paymentMode),
    switch (filters.status) {
      'active' => 'Status - Active',
      'inactive' => 'Status - Inactive',
      _ => 'Status - All',
    },
    if (filters.partyGroup != null && filters.partyGroup!.isNotEmpty)
      'Group - ${filters.partyGroup}',
    ...extraChips,
  ];
  return chips;
}

String _paymentModeChip(String? paymentMode) {
  return switch (paymentMode) {
    'cash' => 'Payment - Cash',
    'upi' => 'Payment - UPI',
    'card' => 'Payment - Card',
    'bank_transfer' => 'Payment - Bank',
    null || '' => 'Payment - All',
    _ => 'Payment - $paymentMode',
  };
}

class _MobileReportFilterBody extends StatefulWidget {
  const _MobileReportFilterBody({
    required this.initial,
    required this.sheetContext,
  });

  final MobileReportFilterDraft initial;
  final BuildContext sheetContext;

  @override
  State<_MobileReportFilterBody> createState() =>
      _MobileReportFilterBodyState();
}

class _MobileReportFilterBodyState extends State<_MobileReportFilterBody> {
  late _MobileReportFilterSection _section;
  late String? _partyType;
  late String? _paymentMode;
  late String? _status;

  @override
  void initState() {
    super.initState();
    _section = _MobileReportFilterSection.partyType;
    _partyType = widget.initial.partyType;
    _paymentMode = widget.initial.paymentMode;
    _status = widget.initial.status;
  }

  void _reset() {
    setState(() {
      _section = _MobileReportFilterSection.partyType;
      _partyType = null;
      _paymentMode = null;
      _status = null;
    });
  }

  void _apply() {
    Navigator.of(widget.sheetContext).pop(
      MobileReportFilterDraft(
        partyType: _partyType,
        paymentMode: _paymentMode,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 280,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilterSectionNav(
                selected: _section,
                onSelected: (section) => setState(() => _section = section),
              ),
              Expanded(child: _buildOptions()),
            ],
          ),
        ),
        _FilterFooter(onReset: _reset, onApply: _apply),
      ],
    );
  }

  Widget _buildOptions() {
    return switch (_section) {
      _MobileReportFilterSection.partyType => _RadioOptionList<String?>(
        options: const [
          _RadioOption(value: null, label: 'All parties'),
          _RadioOption(value: 'customer', label: 'Customers'),
          _RadioOption(value: 'supplier', label: 'Suppliers'),
        ],
        selected: _partyType,
        onSelected: (value) => setState(() => _partyType = value),
      ),
      _MobileReportFilterSection.paymentMode => _RadioOptionList<String?>(
        options: const [
          _RadioOption(value: null, label: 'All modes'),
          _RadioOption(value: 'cash', label: 'Cash'),
          _RadioOption(value: 'upi', label: 'UPI'),
          _RadioOption(value: 'card', label: 'Card'),
          _RadioOption(value: 'bank_transfer', label: 'Bank transfer'),
        ],
        selected: _paymentMode,
        onSelected: (value) => setState(() => _paymentMode = value),
      ),
      _MobileReportFilterSection.status => _RadioOptionList<String?>(
        options: const [
          _RadioOption(value: null, label: 'All status'),
          _RadioOption(value: 'active', label: 'Active'),
          _RadioOption(value: 'inactive', label: 'Inactive'),
        ],
        selected: _status,
        onSelected: (value) => setState(() => _status = value),
      ),
    };
  }
}

class _FilterSectionNav extends StatelessWidget {
  const _FilterSectionNav({
    required this.selected,
    required this.onSelected,
  });

  final _MobileReportFilterSection selected;
  final ValueChanged<_MobileReportFilterSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 132,
      decoration: BoxDecoration(
        color: MobileReportTheme.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in _MobileReportFilterSection.values)
            InkWell(
              onTap: () => onSelected(section),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: selected == section
                      ? AppColors.surface
                      : Colors.transparent,
                  border: selected == section
                      ? const Border(
                          left: BorderSide(
                            color: MobileReportTheme.accent,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Text(
                  section.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected == section
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected == section
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadioOption<T> {
  const _RadioOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _RadioOptionList<T> extends StatelessWidget {
  const _RadioOptionList({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_RadioOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: options.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: MobileReportTheme.divider),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.value == selected;

        return InkWell(
          onTap: () => onSelected(option.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? MobileReportTheme.accent
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterFooter extends StatelessWidget {
  const _FilterFooter({
    required this.onReset,
    required this.onApply,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: MobileReportTheme.accentSoft,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              child: const Text('Reset'),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: MobileReportTheme.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
