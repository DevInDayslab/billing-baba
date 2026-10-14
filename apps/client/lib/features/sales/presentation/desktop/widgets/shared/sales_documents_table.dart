import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/application/sales_document_scope_permissions.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_document_actions.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_table_shared.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _dateColWidth = 148.0;
const _docNoColWidth = 120.0;
const _partyColWidth = 180.0;
const _statusColWidth = 108.0;
const _amountColWidth = 108.0;
const _actionsColWidth = 96.0;

class SalesDocumentsTable extends ConsumerWidget {
  const SalesDocumentsTable({
    required this.config,
    this.title = 'Transactions',
    this.statusOptions = const [
      'All Status',
      'Cancelled',
      'Draft',
      'Finalized',
    ],
    super.key,
  });

  final SalesDocumentTableConfig config;
  final String title;
  final List<String> statusOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(salesDocumentsListProvider(config.scope));
    final paginated = ref.watch(paginatedSalesDocumentsProvider(config.scope));
    final filters = ref.watch(salesDocumentFiltersProvider(config.scope));
    final notifier = ref.read(
      salesDocumentsListProvider(config.scope).notifier,
    );
    final isFiltered =
        filters.hasColumnFilters ||
        filters.selectedStatus != 'All Status' ||
        ref.watch(salesDocumentSearchQueryProvider(config.scope)).isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: salesCardBorder),
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
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                ExpandableTableSearchField(
                  hint: 'Search Data',
                  initialQuery: ref.read(
                    salesDocumentSearchQueryProvider(config.scope),
                  ),
                  onQueryChanged: (query) => ref
                      .read(
                        salesDocumentSearchQueryProvider(config.scope).notifier,
                      )
                      .setQuery(query),
                ),
                SalesXlsChip(
                  onTap: () => ModuleExportActions.exportSalesDocuments(
                    context,
                    ref,
                    config.scope,
                  ),
                ),
                IconButton(
                  onPressed: notifier.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: salesCardBorder),
          SalesPaginatedListAsyncBody(
            listAsync: documentsAsync,
            onRetry: notifier.refresh,
            hasStaleRows: paginated.items.isNotEmpty,
            table: _SalesDocumentsTableBody(
              config: config,
              items: paginated.items,
              statusOptions: statusOptions,
              isFiltered: isFiltered,
            ),
          ),
          const Divider(height: 1, color: salesCardBorder),
          SalesPaginationRow(scope: config.scope),
        ],
      ),
    );
  }
}

class _SalesDocumentsTableBody extends ConsumerWidget {
  const _SalesDocumentsTableBody({
    required this.config,
    required this.items,
    required this.statusOptions,
    required this.isFiltered,
  });

  final SalesDocumentTableConfig config;
  final List<SaleInvoiceModel> items;
  final List<String> statusOptions;
  final bool isFiltered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return SalesEmptyListState(
        message: isFiltered ? 'No matching transactions' : config.emptyMessage,
      );
    }

    final columns = _SalesDocumentsTableColumns.build(
      ref: ref,
      scope: config.scope,
      statusOptions: statusOptions,
    );

    final rows = [
      for (var i = 0; i < items.length; i++)
        SalesDocumentsTableRows.buildDataRow(
          context: context,
          ref: ref,
          config: config,
          document: items[i],
          isOdd: i.isOdd,
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

class SalesDocumentsTableRows {
  const SalesDocumentsTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required WidgetRef ref,
    required SalesDocumentTableConfig config,
    required SaleInvoiceModel document,
    required bool isOdd,
  }) {
    final module = permissionModuleForScope(config.scope);
    final permissions = ref.watch(permissionServiceProvider);
    final general = ref.watch(generalSettingsProvider).value;
    final menuActions = config.actions.where((action) {
      return switch (action) {
        SalesDocumentMenuAction.view => permissions.canView(module),
        SalesDocumentMenuAction.edit => permissions.canEdit(module),
        SalesDocumentMenuAction.duplicate => permissions.canCreate(module),
        SalesDocumentMenuAction.delete => permissions.canDelete(module),
        SalesDocumentMenuAction.convertToSaleOrder =>
          permissions.canCreate(module) &&
              (general?.enableSalePurchaseOrder ?? true),
        SalesDocumentMenuAction.convertToDeliveryChallan =>
          permissions.canCreate(module) &&
              (general?.enableDeliveryChallan ?? true),
        SalesDocumentMenuAction.convertToInvoice => permissions.canCreate(
          module,
        ),
      };
    }).toList();

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(document.date))),
        _DataCell(child: Text(document.invoiceNo)),
        _DataCell(
          child: Text(
            document.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          child: SalesDocumentLifecycleBadge(status: document.documentStatus),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(document.amount)),
        ),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  salesDocumentPrintRequest(config, document.id),
                  filename: DocumentPrintActions.filenameFor(
                    document.invoiceNo,
                  ),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Print',
              ),
              SalesActionMenuButton(
                items: [
                  for (final action in menuActions)
                    SalesActionMenuItem(
                      label: salesDocumentMenuActionLabel(action),
                      onSelected: () => handleSalesDocumentMenuAction(
                        context: context,
                        ref: ref,
                        config: config,
                        action: action,
                        document: document,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SalesDocumentsTableColumns {
  const _SalesDocumentsTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required SalesDocumentListScope scope,
    required List<String> statusOptions,
  }) {
    final filters = ref.watch(salesDocumentFiltersProvider(scope));
    final filtersNotifier = ref.read(
      salesDocumentFiltersProvider(scope).notifier,
    );

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
        initialWidth: _docNoColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'documentNo',
            title: 'Document No',
            type: FilterType.text,
            hintText: 'Document number',
          ),
          initialValue: filters.documentNoColumnFilter,
          onApply: (result) => filtersNotifier.setDocumentNoColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Party Name',
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
        initialWidth: _statusColWidth,
        header: _StatusColumnFilterHeader(
          statusOptions: statusOptions,
          selectedStatus: filters.selectedStatus,
          onStatusFilter: filtersNotifier.setStatus,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'amount',
            title: 'Amount',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.amountColumnFilter,
          onApply: (result) => filtersNotifier.setAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
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
    required this.statusOptions,
    required this.selectedStatus,
    required this.onStatusFilter,
  });

  final List<String> statusOptions;
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
                      for (final option in widget.statusOptions)
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
          child: wrapEllipsisTooltipChild(child),
        ),
      ),
    );
  }
}

class SalesDocumentLifecycleBadge extends StatelessWidget {
  const SalesDocumentLifecycleBadge({required this.status, super.key});

  final SalesDocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      SalesDocumentStatus.draft => (
        'Draft',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      SalesDocumentStatus.finalized => (
        'Finalized',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      SalesDocumentStatus.cancelled => (
        'Cancelled',
        const Color(0xFFF5F5F5),
        const Color(0xFF616161),
      ),
      SalesDocumentStatus.converted => (
        'Converted',
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
