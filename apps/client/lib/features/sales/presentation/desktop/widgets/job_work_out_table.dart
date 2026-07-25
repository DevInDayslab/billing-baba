import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/module_export_actions.dart';
import 'package:billing_baba/features/sales/application/job_work_orders_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/job_work_out_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/job_work_out_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/job_work_out_status_badge.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_table_shared.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const _convertLinkColor = Color(0xFF1565C0);
const double _cellHorizontalPadding = AppSpacing.sm;

const _dateColWidth = 148.0;
const _partyColWidth = 180.0;
const _jobIdColWidth = 120.0;
const _deliveryColWidth = 148.0;
const _statusColWidth = 160.0;
const _actionsColWidth = 180.0;

class JobWorkOutTable extends ConsumerWidget {
  const JobWorkOutTable({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    String? orderId,
  }) async {
    final saved = await showJobWorkOutDialog(context, orderId: orderId);
    if (saved == true) {
      await ref.read(jobWorkOrdersListProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(jobWorkOrdersListProvider);
    final items = ref.watch(filteredJobWorkOrdersProvider);
    final filters = ref.watch(jobWorkOutFiltersProvider);
    final listNotifier = ref.read(jobWorkOrdersListProvider.notifier);
    final isFiltered =
        filters.hasColumnFilters ||
        filters.selectedStatus != 'All Status' ||
        ref.watch(jobWorkOutSearchQueryProvider).isNotEmpty;

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
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                ExpandableTableSearchField(
                  hint: 'Search Data',
                  initialQuery: ref.read(jobWorkOutSearchQueryProvider),
                  onQueryChanged: (query) => ref
                      .read(jobWorkOutSearchQueryProvider.notifier)
                      .setQuery(query),
                ),
                SalesXlsChip(
                  onTap: () => ModuleExportActions.exportJobWork(context, ref),
                ),
                IconButton(
                  onPressed: listNotifier.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          ordersAsync.when(
            skipLoadingOnReload: true,
            loading: () => const SalesLoadingState(),
            error: (error, _) => SalesErrorState(
              message: SalesErrorMapper.messageFor(error),
              onRetry: listNotifier.refresh,
            ),
            data: (_) => _JobWorkOutTransactionsTable(
              items: items,
              isFiltered: isFiltered,
              onEdit: (item) => _openForm(context, ref, orderId: item.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobWorkOutTransactionsTable extends ConsumerWidget {
  const _JobWorkOutTransactionsTable({
    required this.items,
    required this.isFiltered,
    required this.onEdit,
  });

  final List<JobWorkOrderListItem> items;
  final bool isFiltered;
  final void Function(JobWorkOrderListItem item) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(jobWorkOutFiltersProvider);

    if (items.isEmpty) {
      return SalesEmptyListState(
        message: isFiltered
            ? 'No matching transactions'
            : 'No transactions found',
      );
    }

    final columns = _JobWorkOutTableColumns.build(
      ref: ref,
      onStatusFilter: (status) =>
          ref.read(jobWorkOutFiltersProvider.notifier).setStatus(status),
    );

    final rows = [
      for (var i = 0; i < items.length; i++)
        JobWorkOutTableRows.buildDataRow(
          item: items[i],
          isOdd: i.isOdd,
          onTap: () => onEdit(items[i]),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: SizedBox(
            width: constraints.maxWidth,
            child: ResizableDataTable(
              columns: columns,
              rows: rows,
            ),
          ),
        );
      },
    );
  }
}

class JobWorkOutTableRows {
  const JobWorkOutTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ResizableDataRow buildDataRow({
    required JobWorkOrderListItem item,
    required bool isOdd,
    required VoidCallback onTap,
  }) {
    final closedDate = item.closedAt;

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      onTap: onTap,
      cells: [
        _DataCell(
          child: Text(
            item.invoiceDate != null
                ? _dateFormat.format(item.invoiceDate!)
                : '—',
          ),
        ),
        _DataCell(
          child: Text(
            item.party,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(item.jobId.isEmpty ? '—' : item.jobId)),
        _DataCell(
          child: Text(
            item.deliveryDate != null
                ? _dateFormat.format(item.deliveryDate!)
                : '—',
          ),
        ),
        _DataCell(
          child: Row(
            children: [
              JobWorkOutStatusBadge(status: item.status),
              if (closedDate != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _dateFormat.format(closedDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.convertedInvoiceNumber != null)
                Flexible(
                  child: Text(
                    'Converted to invoice No.${item.convertedInvoiceNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _convertLinkColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              JobWorkOutActionsMenuButton(item: item),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobWorkOutTableColumns {
  const _JobWorkOutTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required ValueChanged<String> onStatusFilter,
  }) {
    final filters = ref.watch(jobWorkOutFiltersProvider);
    final filtersNotifier = ref.read(jobWorkOutFiltersProvider.notifier);

    return [
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 96,
        maxWidth: 280,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'date',
            title: 'Date',
            type: FilterType.date,
          ),
          initialValue: filters.dateColumnFilter,
          onApply: (result) => filtersNotifier.setDateColumnFilter(
            FilterUtils.fromResult(result) as DateColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Party',
            type: FilterType.text,
            hintText: 'Party name',
          ),
          initialValue: filters.partyNameColumnFilter,
          onApply: (result) => filtersNotifier.setPartyNameColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _jobIdColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'jobId',
            title: 'Job ID',
            type: FilterType.text,
            hintText: 'Job ID',
          ),
          initialValue: filters.jobIdColumnFilter,
          onApply: (result) => filtersNotifier.setJobIdColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _deliveryColWidth,
        minWidth: 96,
        maxWidth: 280,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'deliveryDate',
            title: 'Delivery Date',
            type: FilterType.date,
          ),
          initialValue: filters.deliveryDateColumnFilter,
          onApply: (result) => filtersNotifier.setDeliveryDateColumnFilter(
            FilterUtils.fromResult(result) as DateColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        header: _StatusColumnFilterHeader(
          selectedStatus: filters.selectedStatus,
          onStatusFilter: onStatusFilter,
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _actionsColWidth,
        minWidth: _actionsColWidth,
        maxWidth: _actionsColWidth,
        resizable: false,
        header: _HeaderCell(label: 'Actions'),
      ),
    ];
  }
}

class _StatusColumnFilterHeader extends StatefulWidget {
  const _StatusColumnFilterHeader({
    required this.selectedStatus,
    required this.onStatusFilter,
  });

  final String selectedStatus;
  final ValueChanged<String> onStatusFilter;

  @override
  State<_StatusColumnFilterHeader> createState() =>
      _StatusColumnFilterHeaderState();
}

class _StatusColumnFilterHeaderState extends State<_StatusColumnFilterHeader> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const _statusOptions = [
    'All Status',
    'Open',
    'Closed',
    'Cancelled',
  ];

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
            const Expanded(
              child: Text(
                'Status',
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
  const _HeaderCell({required this.label});

  final String label;

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: _headerStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({required this.child});

  final Widget child;

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
        child: wrapEllipsisTooltipChild(child),
      ),
    );
  }
}
