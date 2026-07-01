import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _addSaleOrange = Color(0xFFFF9800);

class SaleInvoiceFilterBar extends ConsumerStatefulWidget {
  const SaleInvoiceFilterBar({super.key});

  @override
  ConsumerState<SaleInvoiceFilterBar> createState() =>
      _SaleInvoiceFilterBarState();
}

class _SaleInvoiceFilterBarState extends ConsumerState<SaleInvoiceFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _timeDropdownKey = GlobalKey<SaleFilterDropdownState>();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(saleInvoiceFiltersProvider);
    final filtersNotifier = ref.read(saleInvoiceFiltersProvider.notifier);

    final customRange = filters.customDateRange;
    final dateRangeLabel = customRange != null
        ? formatSaleDateRangeLabel(customRange)
        : defaultSaleDateRangeLabel();

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
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
                label: filters.selectedUser,
                options: const ['All Users', 'Admin'],
                selected: filters.selectedUser,
                showSearchField: true,
                onSelected: filtersNotifier.setUser,
              ),
              SaleFilterDropdown(
                label: filters.selectedGodown,
                options: const ['All Godown', 'Main Location'],
                selected: filters.selectedGodown,
                onSelected: filtersNotifier.setGodown,
              ),
              SaleFilterDropdown(
                label: filters.selectedStatus,
                options: const [
                  'All Status',
                  'Cancelled',
                  'Paid',
                  'Overdue',
                  'Unpaid',
                  'Partial',
                ],
                selected: filters.selectedStatus,
                onSelected: filtersNotifier.setStatus,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.addSale),
          style: FilledButton.styleFrom(
            backgroundColor: _addSaleOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Sale',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
