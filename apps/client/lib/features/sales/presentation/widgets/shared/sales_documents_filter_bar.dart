import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/permissions/permission_gate.dart';
import 'package:billing_baba/features/sales/application/sales_document_scope_permissions.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _addSaleOrange = Color(0xFFFF9800);

class SalesDocumentsFilterBar extends ConsumerStatefulWidget {
  const SalesDocumentsFilterBar({
    required this.scope,
    required this.onAdd,
    required this.addButtonLabel,
    this.statusOptions = const [
      'All Status',
      'Cancelled',
      'Draft',
      'Finalized',
    ],
    super.key,
  });

  final SalesDocumentListScope scope;
  final VoidCallback onAdd;
  final String addButtonLabel;
  final List<String> statusOptions;

  @override
  ConsumerState<SalesDocumentsFilterBar> createState() =>
      _SalesDocumentsFilterBarState();
}

class _SalesDocumentsFilterBarState
    extends ConsumerState<SalesDocumentsFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _timeDropdownKey = GlobalKey<SaleFilterDropdownState>();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(salesDocumentFiltersProvider(widget.scope));
    final filtersNotifier = ref.read(
      salesDocumentFiltersProvider(widget.scope).notifier,
    );

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
                label: filters.selectedStatus,
                options: widget.statusOptions,
                selected: filters.selectedStatus,
                onSelected: filtersNotifier.setStatus,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        PermissionGate(
          module: permissionModuleForScope(widget.scope),
          action: PermissionAction.create,
          child: FilledButton.icon(
            onPressed: widget.onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text(widget.addButtonLabel),
            style: FilledButton.styleFrom(
              backgroundColor: _addSaleOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
