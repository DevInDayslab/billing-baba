import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/providers/debit_note_form_provider.dart';
import 'package:billing_baba/features/purchases/providers/purchase_return_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _addDebitNoteBlue = Color(0xFF1565C0);

class PurchaseReturnFilterBar extends ConsumerStatefulWidget {
  const PurchaseReturnFilterBar({super.key});

  @override
  ConsumerState<PurchaseReturnFilterBar> createState() =>
      _PurchaseReturnFilterBarState();
}

class _PurchaseReturnFilterBarState
    extends ConsumerState<PurchaseReturnFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _timeDropdownKey = GlobalKey<SaleFilterDropdownState>();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(purchaseReturnFiltersProvider);
    final filtersNotifier = ref.read(purchaseReturnFiltersProvider.notifier);

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
                label: filters.selectedUser,
                options: const ['All Users', 'Admin', 'Staff'],
                selected: filters.selectedUser,
                showSearchField: true,
                onSelected: filtersNotifier.setUser,
              ),
              SaleFilterDropdown(
                label: filters.selectedTransaction,
                options: const [
                  'Debit Note',
                  'Sale',
                  'Purchase',
                  'Payment-In',
                  'Credit Note',
                  'Expense',
                ],
                selected: filters.selectedTransaction,
                onSelected: filtersNotifier.setTransaction,
              ),
              SaleFilterDropdown(
                label: filters.selectedGodown,
                options: const ['All Godown', 'Main Godown', 'Main Location'],
                selected: filters.selectedGodown,
                onSelected: filtersNotifier.setGodown,
              ),
              SaleFilterDropdown(
                label: filters.selectedPayment,
                options: const [
                  'All Payment',
                  'Cash',
                  'Credit',
                  'UPI',
                  'Cheque',
                ],
                selected: filters.selectedPayment,
                onSelected: filtersNotifier.setPayment,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton.icon(
          onPressed: () {
            ref.read(debitNoteFormProvider().notifier).resetForm();
            unawaited(context.push(AppRoutes.addDebitNote));
          },
          style: FilledButton.styleFrom(
            backgroundColor: _addDebitNoteBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Debit Note',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
