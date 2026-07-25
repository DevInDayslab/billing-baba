import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/upload_purchase_bills_dialog.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _addPurchaseRed = Color(0xFFD32F2F);

class PurchaseBillFilterBar extends ConsumerStatefulWidget {
  const PurchaseBillFilterBar({super.key});

  @override
  ConsumerState<PurchaseBillFilterBar> createState() =>
      _PurchaseBillFilterBarState();
}

class _PurchaseBillFilterBarState extends ConsumerState<PurchaseBillFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _timeDropdownKey = GlobalKey<SaleFilterDropdownState>();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(purchaseBillFiltersProvider);
    final filtersNotifier = ref.read(purchaseBillFiltersProvider.notifier);

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
                label: filters.selectedFirm,
                options: const ['All Firms', 'Main Firm', 'Branch Firm'],
                selected: filters.selectedFirm,
                onSelected: filtersNotifier.setFirm,
              ),
              SaleFilterDropdown(
                label: filters.selectedUser,
                options: const ['All Users', 'Admin', 'Staff'],
                selected: filters.selectedUser,
                showSearchField: true,
                onSelected: filtersNotifier.setUser,
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
        const UploadPurchaseBillsButton(),
        const SizedBox(width: AppSpacing.sm),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.addPurchase),
          style: FilledButton.styleFrom(
            backgroundColor: _addPurchaseRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Purchase',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
