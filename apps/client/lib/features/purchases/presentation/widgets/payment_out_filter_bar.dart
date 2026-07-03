import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/payment_out_dialog.dart';
import 'package:billing_baba/features/purchases/providers/payment_out_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentOutFilterBar extends ConsumerStatefulWidget {
  const PaymentOutFilterBar({super.key});

  @override
  ConsumerState<PaymentOutFilterBar> createState() =>
      _PaymentOutFilterBarState();
}

const _addPaymentBlue = Color(0xFF1565C0);

class _PaymentOutFilterBarState extends ConsumerState<PaymentOutFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _timeDropdownKey = GlobalKey<SaleFilterDropdownState>();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(paymentOutFiltersProvider);
    final filtersNotifier = ref.read(paymentOutFiltersProvider.notifier);

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
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Filter by :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
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
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => showPaymentOutDialog(context),
          style: FilledButton.styleFrom(
            backgroundColor: _addPaymentBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Payment-Out',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
