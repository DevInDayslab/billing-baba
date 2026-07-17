import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/widgets/module_print_actions.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/providers/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _filterChipBg = Color(0xFFEAF2FB);
const _filterChipBorder = Color(0xFFD6E6F5);
const _filterBarBorder = Color(0xFFE0E0E0);

class DeliveryChallanFilterBar extends ConsumerStatefulWidget {
  const DeliveryChallanFilterBar({super.key});

  @override
  ConsumerState<DeliveryChallanFilterBar> createState() =>
      _DeliveryChallanFilterBarState();
}

class _DeliveryChallanFilterBarState
    extends ConsumerState<DeliveryChallanFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _timeDropdownKey = GlobalKey<SaleFilterDropdownState>();

  static const ({Color backgroundColor, Color borderColor}) _chipStyle = (
    backgroundColor: _filterChipBg,
    borderColor: _filterChipBorder,
  );

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(deliveryChallanFiltersProvider);
    final filtersNotifier = ref.read(deliveryChallanFiltersProvider.notifier);
    final firmOptions = ref.watch(deliveryChallanFirmFilterOptionsProvider);
    final userOptions = ref.watch(deliveryChallanUserFilterOptionsProvider);

    final customRange = filters.customDateRange;
    final dateRangeLabel = customRange != null
        ? formatSaleDateRangeLabel(customRange)
        : defaultSaleDateRangeLabel();

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _filterBarBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          children: [
            const Text(
              'Filter by :',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SaleFilterDropdown(
                    key: _timeDropdownKey,
                    label: filters.timeRangeLabel,
                    chipBackgroundColor: _chipStyle.backgroundColor,
                    chipBorderColor: _chipStyle.borderColor,
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
                        if (filters.customDateRange == null) {
                          final now = DateTime.now();
                          filtersNotifier.setCustomDateRange(
                            DateTimeRange(
                              start: DateTime(now.year, now.month),
                              end: DateTime(now.year, now.month + 1, 0),
                            ),
                          );
                        }
                        _datePickerKey.currentState?.showPicker();
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
                      backgroundColor: _chipStyle.backgroundColor,
                      borderColor: _chipStyle.borderColor,
                      leadingIcon: Icons.calendar_today_outlined,
                      showDropdownArrow: false,
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
                          _datePickerKey.currentState?.showPicker();
                        } else {
                          _datePickerKey.currentState?.toggle();
                        }
                      },
                    ),
                  ),
                  SaleFilterDropdown(
                    label: filters.selectedFirm,
                    chipBackgroundColor: _chipStyle.backgroundColor,
                    chipBorderColor: _chipStyle.borderColor,
                    options: firmOptions,
                    selected: filters.selectedFirm,
                    onSelected: filtersNotifier.setFirm,
                  ),
                  SaleFilterDropdown(
                    label: filters.selectedUser,
                    chipBackgroundColor: _chipStyle.backgroundColor,
                    chipBorderColor: _chipStyle.borderColor,
                    options: userOptions,
                    selected: filters.selectedUser,
                    showSearchField: true,
                    onSelected: filtersNotifier.setUser,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _XlsChip(
              onTap: () => ModuleExportActions.exportSalesDocuments(
                context,
                ref,
                deliveryChallanListScope(),
              ),
            ),
            IconButton(
              onPressed: () =>
                  ModulePrintActions.printDeliveryChallans(context, ref),
              icon: const Icon(Icons.print_outlined, size: 20),
              color: AppColors.textSecondary,
              tooltip: 'Print',
            ),
          ],
        ),
      ),
    );
  }
}

class _XlsChip extends StatelessWidget {
  const _XlsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Text(
          'xls',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }
}
