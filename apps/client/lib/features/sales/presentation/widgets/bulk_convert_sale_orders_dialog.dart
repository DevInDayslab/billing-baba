import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _dialogMaxWidth = 720.0;
const _dialogMaxHeight = 560.0;
const _attachButtonColor = Color(0xFF1565C0);

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

DateTimeRange? _resolveBulkConvertTimeRange(
  TimeRangeOption option,
  DateTimeRange? custom,
) {
  final now = DateTime.now();
  final today = _startOfDay(now);

  return switch (option) {
    TimeRangeOption.allTime => null,
    TimeRangeOption.today => DateTimeRange(start: today, end: _endOfDay(today)),
    TimeRangeOption.thisWeek => DateTimeRange(
      start: today.subtract(Duration(days: today.weekday % 7)),
      end: _endOfDay(
        today.add(Duration(days: 6 - (today.weekday % 7))),
      ),
    ),
    TimeRangeOption.thisMonth => DateTimeRange(
      start: DateTime(now.year, now.month),
      end: _endOfDay(DateTime(now.year, now.month + 1, 0)),
    ),
    TimeRangeOption.thisYear => DateTimeRange(
      start: DateTime(now.year),
      end: _endOfDay(DateTime(now.year, 12, 31)),
    ),
    TimeRangeOption.custom => custom,
  };
}

/// Opens the Vyapar-style bulk convert dialog for selecting sale orders to attach.
Future<List<String>?> showBulkConvertSaleOrdersDialog(BuildContext context) {
  return showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: BulkConvertSaleOrdersDialog(),
    ),
  );
}

class BulkConvertSaleOrdersDialog extends ConsumerStatefulWidget {
  const BulkConvertSaleOrdersDialog({super.key});

  @override
  ConsumerState<BulkConvertSaleOrdersDialog> createState() =>
      _BulkConvertSaleOrdersDialogState();
}

class _BulkConvertSaleOrdersDialogState
    extends ConsumerState<BulkConvertSaleOrdersDialog> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _timeDropdownKey = GlobalKey<SaleFilterDropdownState>();

  String? _partyId;
  String _customerName = '';
  TimeRangeOption _timeRangeOption = TimeRangeOption.thisMonth;
  DateTimeRange? _customDateRange;
  final Set<String> _selectedOrderIds = {};
  List<SaleInvoiceModel> _orders = const [];
  bool _isLoadingOrders = false;
  String? _loadError;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  String get _timeRangeLabel => _timeRangeOption.label;

  String get _dateRangeLabel {
    final range = _resolveBulkConvertTimeRange(
      _timeRangeOption,
      _customDateRange,
    );
    if (range == null) return 'All Time';
    return formatSaleDateRangeLabel(range);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _customDateRange = DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  Future<void> _loadOrders() async {
    if (_partyId == null || _partyId!.isEmpty) {
      setState(() {
        _orders = const [];
        _selectedOrderIds.clear();
        _loadError = null;
      });
      return;
    }

    setState(() {
      _isLoadingOrders = true;
      _loadError = null;
      _selectedOrderIds.clear();
    });

    try {
      final service = await ref.read(salesServiceProvider.future);
      final dateRange = _resolveBulkConvertTimeRange(
        _timeRangeOption,
        _customDateRange,
      );

      final orders = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
        fetchPage: (page) async {
          final result = await service.fetchInvoicesPage(
            SalesDocumentListQuery(
              page: page,
              limit: PaginatedFetch.defaultPageSize,
              documentType: SalesDocumentType.saleOrder.apiValue,
              status: 'finalized',
              partyId: _partyId,
              from: dateRange?.start.toUtc().toIso8601String(),
              to: dateRange?.end.toUtc().toIso8601String(),
              order: 'asc',
            ),
          );
          return (
            items: result.items,
            totalPages: result.totalPages,
          );
        },
      );

      final convertible = orders
          .where(
            (order) => order.documentStatus == SalesDocumentStatus.finalized,
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _orders = convertible;
        _isLoadingOrders = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingOrders = false;
        _loadError = SalesErrorMapper.messageFor(error);
        _orders = const [];
      });
    }
  }

  void _onCustomerSelected(String partyId, String partyName) {
    setState(() {
      _partyId = partyId;
      _customerName = partyName;
    });
    _loadOrders();
  }

  void _onTimeRangeSelected(String label) {
    setState(() {
      _timeRangeOption = TimeRangeOptionX.fromLabel(label);
      if (label == 'Custom' && _customDateRange == null) {
        final now = DateTime.now();
        _customDateRange = DateTimeRange(
          start: DateTime(now.year, now.month),
          end: DateTime(now.year, now.month + 1, 0),
        );
      }
    });

    if (label == 'Custom') {
      _datePickerKey.currentState?.showPicker();
    } else {
      _datePickerKey.currentState?.closePicker();
      _timeDropdownKey.currentState?.closeMenu();
      _loadOrders();
    }
  }

  void _onCustomRangeSelected(DateTimeRange range) {
    setState(() {
      _customDateRange = range;
      _timeRangeOption = TimeRangeOption.custom;
    });
    _loadOrders();
  }

  void _toggleOrder(String orderId) {
    setState(() {
      if (_selectedOrderIds.contains(orderId)) {
        _selectedOrderIds.remove(orderId);
      } else {
        _selectedOrderIds.add(orderId);
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedOrderIds.addAll(_orders.map((order) => order.id));
      } else {
        _selectedOrderIds.clear();
      }
    });
  }

  void _handleAttach() {
    if (_selectedOrderIds.isEmpty) return;
    Navigator.of(context).pop(_selectedOrderIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final canAttach = _partyId != null && _selectedOrderIds.isNotEmpty;
    final allSelected =
        _orders.isNotEmpty && _selectedOrderIds.length == _orders.length;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: _dialogMaxWidth,
        maxHeight: _dialogMaxHeight,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FloatingLabelField(
                    label: 'Customer*',
                    hasError: false,
                    child: BillingNamePartySearchField(
                      value: _customerName,
                      emptyPlaceholder: 'Select Customer',
                      partyTypeFilter: PartyTypeFilter.customer,
                      onSelected: (name) {
                        if (name.trim().isEmpty) {
                          setState(() {
                            _customerName = '';
                            _partyId = null;
                            _orders = const [];
                            _selectedOrderIds.clear();
                          });
                        } else {
                          setState(() => _customerName = name);
                        }
                      },
                      onPartySelectedWithId: _onCustomerSelected,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Filter By :',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SaleFilterDropdown(
                        key: _timeDropdownKey,
                        label: _timeRangeLabel,
                        options: const [
                          'All Time',
                          'Today',
                          'This Week',
                          'This Month',
                          'This Year',
                          'Custom',
                        ],
                        selected: _timeRangeLabel,
                        onSelected: _onTimeRangeSelected,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'Between',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SaleDateRangePickerAnchor(
                        key: _datePickerKey,
                        initialRange: _customDateRange,
                        onRangeSelected: _onCustomRangeSelected,
                        child: SaleFilterChip(
                          label: _dateRangeLabel,
                          onTap: () {
                            _timeDropdownKey.currentState?.closeMenu();
                            if (_timeRangeOption != TimeRangeOption.custom) {
                              _onTimeRangeSelected('Custom');
                            } else {
                              _datePickerKey.currentState?.toggle();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            Expanded(
              child: _buildOrderList(allSelected),
            ),
            const Divider(height: 1, color: _cardBorder),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: canAttach ? _handleAttach : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _attachButtonColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      disabledForegroundColor: AppColors.textSecondary,
                    ),
                    child: Text(
                      'Attach ${_selectedOrderIds.length} Orders',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(bool allSelected) {
    if (_partyId == null || _partyId!.isEmpty) {
      return const Center(
        child: Text(
          'Select a customer to view pending sale orders.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _loadError!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text(
          'No pending sale orders found for this customer in the selected period.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: const Color(0xFFF5F7FA),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Checkbox(
                  value: allSelected,
                  tristate: true,
                  onChanged: (value) {
                    if (value == null) {
                      _toggleSelectAll(false);
                    } else {
                      _toggleSelectAll(value);
                    }
                  },
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'ORDER NO.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'DATE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'AMOUNT',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _orders.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: _cardBorder),
            itemBuilder: (context, index) {
              final order = _orders[index];
              final isSelected = _selectedOrderIds.contains(order.id);

              return InkWell(
                onTap: () => _toggleOrder(order.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleOrder(order.id),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          order.invoiceNo,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _dateFormat.format(order.date),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _currencyFormat.format(order.amount),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Select orders to attach',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _FloatingLabelField extends StatelessWidget {
  const _FloatingLabelField({
    required this.label,
    required this.child,
    required this.hasError,
  });

  final String label;
  final Widget child;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: saleFieldLabelStyle.copyWith(
            color: hasError ? saleFieldErrorColor : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
