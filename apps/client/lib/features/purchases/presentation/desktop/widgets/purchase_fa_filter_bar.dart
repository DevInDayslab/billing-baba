import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/module_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseFaFilterBar extends ConsumerStatefulWidget {
  const PurchaseFaFilterBar({super.key});

  @override
  ConsumerState<PurchaseFaFilterBar> createState() =>
      _PurchaseFaFilterBarState();
}

class _PurchaseFaFilterBarState extends ConsumerState<PurchaseFaFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _timeDropdownKey = GlobalKey<SaleFilterDropdownState>();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(purchaseFaFiltersProvider);
    final filtersNotifier = ref.read(purchaseFaFiltersProvider.notifier);

    final customRange = filters.customDateRange;
    final dateRangeLabel = customRange != null
        ? formatSaleDateRangeLabel(customRange)
        : defaultSaleDateRangeLabel();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SaleFilterDropdown(
                key: _timeDropdownKey,
                label: filters.timeRangeLabel,
                options: const [
                  'All Time',
                  'Today',
                  'This Week',
                  'This Month',
                  'This Year',
                  'Custom',
                ],
                selected: filters.timeRangeLabel,
                onSelected: (option) {
                  filtersNotifier.setTimeRange(option);
                  if (option == 'Custom') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _datePickerKey.currentState?.showPicker();
                    });
                  } else {
                    _datePickerKey.currentState?.closePicker();
                  }
                },
              ),
              SaleDateRangePickerAnchor(
                key: _datePickerKey,
                initialRange: filters.customDateRange,
                onRangeSelected: (range) {
                  filtersNotifier.setCustomDateRange(
                    range,
                    autoSwitchToCustom: true,
                  );
                },
                child: SaleFilterChip(
                  label: dateRangeLabel,
                  onTap: () {
                    _timeDropdownKey.currentState?.closeMenu();
                    if (filters.timeRangeOption != TimeRangeOption.custom) {
                      filtersNotifier.setTimeRange('Custom');
                      if (filters.customDateRange == null) {
                        final now = DateTime.now();
                        filtersNotifier.setCustomDateRange(
                          DateTimeRange(
                            start: DateTime(now.year, now.month),
                            end: DateTime(now.year, now.month + 1, 0),
                          ),
                        );
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _datePickerKey.currentState?.showPicker();
                      });
                    } else {
                      _datePickerKey.currentState?.toggle();
                    }
                  },
                ),
              ),
              SaleFilterDropdown(
                label: filters.selectedFirm,
                options: const ['All Firms', 'Main Firm', 'Branch Firm'],
                selected: filters.selectedFirm,
                onSelected: filtersNotifier.setFirm,
              ),
              SaleFilterDropdown(
                label: filters.selectedGodown,
                options: const ['All Godown', 'Main Godown', 'Main Location'],
                selected: filters.selectedGodown,
                onSelected: filtersNotifier.setGodown,
              ),
              SaleFilterDropdown(
                label: filters.selectedUser,
                options: const ['All Users', 'Admin', 'Staff'],
                selected: filters.selectedUser,
                showSearchField: true,
                onSelected: filtersNotifier.setUser,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        TextButton.icon(
          onPressed: () => ModuleExportActions.exportFixedAssets(context, ref),
          icon: const Icon(Icons.table_chart_outlined, size: 18),
          label: const Text('Excel Report'),
        ),
        IconButton(
          onPressed: () => ModulePrintActions.printPurchaseFa(context, ref),
          icon: const Icon(Icons.print_outlined, size: 20),
          color: AppColors.textSecondary,
          tooltip: 'Print',
        ),
      ],
    );
  }
}
