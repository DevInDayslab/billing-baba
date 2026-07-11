import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/delivery_challan_convert_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/delivery_challan_status_badge.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_amount_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_date_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_text_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_empty_state_card.dart';
import 'package:billing_baba/features/sales/providers/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tableHeaderBg = Color(0xFFF5F7FA);
const _zebraRowBg = Color(0xFFFAFAFA);
const _bulkConvertColor = Color(0xFFD32F2F);
const _addButtonColor = Color(0xFF1565C0);

const _dateColWidth = 148.0;
const _partyColWidth = 160.0;
const _challanNoColWidth = 120.0;
const _dueDateColWidth = 148.0;
const _amountColWidth = 120.0;
const _statusColWidth = 100.0;
const _actionsColWidth = 180.0;
const _cellHorizontalPadding = AppSpacing.sm;
const _tableHeaderStyle = ListPanelStyles.listHeaderStyle;

class DeliveryChallanTable extends ConsumerWidget {
  const DeliveryChallanTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challansAsync = ref.watch(deliveryChallansProvider);
    final paginated = ref.watch(paginatedDeliveryChallansProvider);
    final notifier = ref.read(deliveryChallansProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  'TRANSACTIONS',
                  style: ListPanelStyles.listHeaderStyle.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                ExpandableTableSearchField(
                  hint: 'Search Data',
                  initialQuery: ref.read(deliveryChallanSearchQueryProvider),
                  onQueryChanged: (query) => ref
                      .read(deliveryChallanSearchQueryProvider.notifier)
                      .setQuery(query),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => _handleBulkConvert(context, ref, paginated.items),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ).copyWith(
                    foregroundColor: WidgetStatePropertyAll(_bulkConvertColor),
                    side: WidgetStatePropertyAll(
                      const BorderSide(color: _bulkConvertColor),
                    ),
                  ),
                  child: const Text(
                    'Bulk Convert To Sale',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.addDeliveryChallan),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Delivery Challan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _addButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          challansAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    SalesErrorMapper.messageFor(error),
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: notifier.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (_) => _ChallanTransactionsTable(
              items: paginated.items,
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          if (paginated.totalPages > 1)
            _PaginationRow(
              currentPage: paginated.currentPage,
              totalPages: paginated.totalPages,
            ),
        ],
      ),
    );
  }

  Future<void> _handleBulkConvert(
    BuildContext context,
    WidgetRef ref,
    List<SaleInvoiceModel> items,
  ) async {
    final openChallans = items
        .where(
          (challan) =>
              challan.documentStatus == SalesDocumentStatus.finalized,
        )
        .toList();

    if (openChallans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No open delivery challans available to convert'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk convert to sale?'),
        content: Text(
          'Convert ${openChallans.length} open delivery challan(s) to sale?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Convert'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final notifier = ref.read(deliveryChallansProvider.notifier);
    final error = await notifier.bulkConvertToSale(
      openChallans.map((challan) => challan.id).toSet(),
    );
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${openChallans.length} delivery challan(s) converted to sale',
        ),
      ),
    );
  }
}

class _ChallanTransactionsTable extends ConsumerStatefulWidget {
  const _ChallanTransactionsTable({required this.items});

  final List<SaleInvoiceModel> items;

  @override
  ConsumerState<_ChallanTransactionsTable> createState() =>
      _ChallanTransactionsTableState();
}

class _ChallanTransactionsTableState
    extends ConsumerState<_ChallanTransactionsTable> {
  @override
  Widget build(BuildContext context) {
    ref.watch(deliveryChallanFiltersProvider);

    if (widget.items.isEmpty) {
      return const _EmptyTransactionsState();
    }

    final rows = [
      for (var i = 0; i < widget.items.length; i++)
        DeliveryChallanTableRows.buildDataRow(
          challan: widget.items[i],
          isOdd: i.isOdd,
          onTap: () => context.push(
            '${AppRoutes.editDeliveryChallan}/${widget.items[i].id}',
          ),
        ),
    ];

    final columns = _ChallanTableColumns.build(
      context: context,
      ref: ref,
      onStatusFilter: (status) => ref
          .read(deliveryChallanFiltersProvider.notifier)
          .setStatus(status),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ResizableDataTable(
        columns: columns,
        rows: rows,
        headerBackgroundColor: _tableHeaderBg,
        rowBorderColor: _cardBorder,
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SaleGeometricIllustration(
            circleColor: Color(0xFFE8F5E9),
            shapeColor: Color(0xFF81C784),
            shapeIcon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No data is available for Delivery Challan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Please try again after making relevant changes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryChallanTableRows {
  const DeliveryChallanTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  static String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return '—';

    final formatted = _dueDateFormat.format(dueDate);
    final today = DateTime.now();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final diff = dueDay.difference(todayDay).inDays;

    final suffix = switch (diff) {
      0 => 'Due: Today',
      1 => 'Due: Tomorrow',
      -1 => 'Due: Yesterday',
      > 0 => 'Due: In $diff days',
      _ => 'Due: ${diff.abs()} days ago',
    };

    return '$formatted $suffix';
  }

  static ResizableDataRow buildDataRow({
    required SaleInvoiceModel challan,
    required bool isOdd,
    required VoidCallback onTap,
  }) {
    return ResizableDataRow(
      onTap: onTap,
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(challan.date))),
        _DataCell(
          child: Text(
            challan.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(challan.invoiceNo)),
        _DataCell(child: Text(_formatDueDate(challan.dueDate))),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(challan.amount)),
        ),
        _DataCell(
          child: DeliveryChallanStatusBadge(
            status: challan.documentStatus,
            plain: true,
          ),
        ),
        _DataCell(
          child: DeliveryChallanConvertButton(challan: challan),
        ),
      ],
    );
  }
}

class _ChallanTableColumns {
  const _ChallanTableColumns._();

  static List<ResizableDataColumn> build({
    required BuildContext context,
    required WidgetRef ref,
    required ValueChanged<String> onStatusFilter,
  }) {
    final filters = ref.watch(deliveryChallanFiltersProvider);
    final filtersNotifier = ref.read(deliveryChallanFiltersProvider.notifier);

    return [
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 96,
        maxWidth: 280,
        header: SaleColumnDateFilterTrigger(
          label: 'DATE',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.dateColumnFilter,
          onApply: filtersNotifier.setDateColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 100,
        maxWidth: 420,
        header: SaleColumnTextFilterTrigger(
          label: 'PARTY',
          hintText: 'Party name',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.partyNameColumnFilter,
          onApply: filtersNotifier.setPartyNameColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _challanNoColWidth,
        header: SaleColumnTextFilterTrigger(
          label: 'CHALLAN NO.',
          hintText: 'Challan number',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.challanNoColumnFilter,
          onApply: filtersNotifier.setChallanNoColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dueDateColWidth,
        header: SaleColumnDateFilterTrigger(
          label: 'DUE DATE',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.dueDateColumnFilter,
          onApply: filtersNotifier.setDueDateColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: SaleColumnAmountFilterTrigger(
          label: 'TOTAL AMOUNT',
          alignment: Alignment.centerRight,
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.amountColumnFilter,
          onApply: filtersNotifier.setAmountColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        header: _StatusColumnFilterHeader(
          headerStyle: _tableHeaderStyle,
          onStatusFilter: onStatusFilter,
          selectedStatus: filters.selectedStatus,
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _actionsColWidth,
        resizable: false,
        header: _HeaderCell(label: 'ACTION', headerStyle: _tableHeaderStyle),
      ),
    ];
  }
}

class _StatusColumnFilterHeader extends StatefulWidget {
  const _StatusColumnFilterHeader({
    required this.onStatusFilter,
    required this.selectedStatus,
    this.headerStyle,
  });

  final ValueChanged<String> onStatusFilter;
  final String selectedStatus;
  final TextStyle? headerStyle;

  @override
  State<_StatusColumnFilterHeader> createState() =>
      _StatusColumnFilterHeaderState();
}

class _StatusColumnFilterHeaderState extends State<_StatusColumnFilterHeader> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  static const _statusOptions = [
    'All Status',
    'Open',
    'Converted',
    'Cancelled',
    'Draft',
  ];

  TextStyle get _headerStyle =>
      widget.headerStyle ??
      const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showMenu();
  }

  void _showMenu() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              offset: const Offset(0, 4),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 160),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final option in _statusOptions)
                        _StatusFilterMenuItem(
                          label: option,
                          isSelected: option == widget.selectedStatus,
                          onTap: () {
                            _removeOverlay();
                            widget.onStatusFilter(option);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selectedStatus != 'All Status';

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'STATUS',
                style: _headerStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 2),
            InkWell(
              key: _triggerKey,
              onTap: _toggleMenu,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.filter_list,
                  size: 14,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterMenuItem extends StatelessWidget {
  const _StatusFilterMenuItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _hoverColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: _hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
  });

  static const _defaultHeaderStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  final String label;
  final Alignment alignment;
  final TextStyle? headerStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Align(
        alignment: alignment,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: headerStyle ?? _defaultHeaderStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final Alignment alignment;

  static const _dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: _dataStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: Align(
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}

class _PaginationRow extends ConsumerWidget {
  const _PaginationRow({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtersNotifier = ref.read(deliveryChallanFiltersProvider.notifier);
    final canGoPrevious = currentPage > 1;
    final canGoNext = currentPage < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: canGoPrevious
                ? () => filtersNotifier.setPage(currentPage - 1)
                : null,
            child: Text(
              'Previous',
              style: TextStyle(
                fontSize: 13,
                color: canGoPrevious
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          for (var page = 1; page <= totalPages; page++) ...[
            if (page > 1) const SizedBox(width: AppSpacing.xs),
            _PageNumber(
              page: page,
              isActive: page == currentPage,
              onTap: () => filtersNotifier.setPage(page),
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: canGoNext
                ? () => filtersNotifier.setPage(currentPage + 1)
                : null,
            child: Text(
              'Next',
              style: TextStyle(
                fontSize: 13,
                color: canGoNext
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEEEEE) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isActive ? null : Border.all(color: _cardBorder),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
