import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/share_menu_button.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_fa_actions.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_fa_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _addPurchaseFaBlue = Color(0xFF1565C0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

class PurchaseFaTable extends ConsumerWidget {
  const PurchaseFaTable({super.key});

  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPurchaseFaRecordsProvider);
    final filters = ref.watch(purchaseFaFiltersProvider);
    final searchQuery = ref.watch(purchaseFaSearchQueryProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: purchaseTransactionTableCardBorder),
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
                  'TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 200,
                  height: 36,
                  child: TextField(
                    onChanged: (value) => ref
                        .read(purchaseFaSearchQueryProvider.notifier)
                        .setQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.smBorder,
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (filters.hasActiveFilters ||
                    searchQuery.trim().isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: ref
                        .read(purchaseFaFiltersProvider.notifier)
                        .clearAllFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.addPurchaseFa),
                  style: FilledButton.styleFrom(
                    backgroundColor: _addPurchaseFaBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Add Purchase FA',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: purchaseTransactionTableCardBorder),
          if (paginated.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No fixed asset purchases found',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            _PurchaseFaTransactionsTable(
              items: paginated.items,
              onBuildRow: (record, index) =>
                  _buildRow(context, ref, record, index),
            ),
          if (paginated.totalPages > 1) ...[
            const Divider(height: 1, color: purchaseTransactionTableCardBorder),
            _PaginationRow(
              currentPage: paginated.currentPage,
              totalPages: paginated.totalPages,
            ),
          ],
        ],
      ),
    );
  }

  ResizableDataRow _buildRow(
    BuildContext context,
    WidgetRef ref,
    PurchaseFaModel record,
    int index,
  ) {
    return ResizableDataRow(
      backgroundColor: index.isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(DateTimeUtils.formatDisplayDate(record.date))),
        _DataCell(child: Text(record.invoiceNo)),
        _DataCell(
          child: Text(
            record.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          child: Text(
            record.paymentType,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.amount),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.balanceDue),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(child: Text(_dueDateFormat.format(record.dueDate))),
        _DataCell(child: PurchaseFaStatusBadge(status: record.status)),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => VoucherPrintActions.previewFixedAssetPurchase(
                  context,
                  ref,
                  record.batchId,
                  filename: VoucherPrintActions.filenameFor(record.invoiceNo),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Print',
              ),
              Tooltip(
                message: 'Share',
                child: ShareMenuButton(
                  overlayOffset: const Offset(0, 4),
                  targetAnchor: Alignment.bottomRight,
                  followerAnchor: Alignment.topRight,
                  onChannelSelected: (_) =>
                      VoucherPrintActions.shareFixedAssetPurchase(
                        context,
                        ref,
                        record.batchId,
                        filename: VoucherPrintActions.filenameFor(
                          record.invoiceNo,
                        ),
                      ),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              SalesActionMenuButton(
                items: [
                  for (final action in purchaseFaMenuActionsFor(record))
                    SalesActionMenuItem(
                      label: purchaseFaMenuActionLabel(action),
                      onSelected: () => handlePurchaseFaMenuAction(
                        context: context,
                        ref: ref,
                        action: action,
                        record: record,
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

class _PurchaseFaTransactionsTable extends ConsumerWidget {
  const _PurchaseFaTransactionsTable({
    required this.items,
    required this.onBuildRow,
  });

  final List<PurchaseFaModel> items;
  final ResizableDataRow Function(PurchaseFaModel record, int index) onBuildRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = _PurchaseFaTableColumns.build(ref: ref);
    final rows = [
      for (var i = 0; i < items.length; i++) onBuildRow(items[i], i),
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
              headerBackgroundColor: purchaseTransactionTableHeaderBg,
              rowBorderColor: purchaseTransactionTableRowBorder,
            ),
          ),
        );
      },
    );
  }
}

class _PurchaseFaTableColumns {
  const _PurchaseFaTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(purchaseFaFiltersProvider);
    final filtersNotifier = ref.read(purchaseFaFiltersProvider.notifier);
    final partyOptions = ref.watch(purchaseFaPartyOptionsProvider);
    final columns = filters.columnFilters;

    final actions = PurchaseColumnFilterActions(
      onDocumentNo: filtersNotifier.setDocumentNoFilter,
      onParty: filtersNotifier.setParty,
      onTogglePaymentType: filtersNotifier.togglePaymentType,
      onClearPaymentTypes: filtersNotifier.clearPaymentTypes,
      onApplyAmountFilter: filtersNotifier.applyAmountFilter,
      onClearAmountFilter: filtersNotifier.clearAmountFilter,
      onApplyBalanceFilter: filtersNotifier.applyBalanceFilter,
      onClearBalanceFilter: filtersNotifier.clearBalanceFilter,
      onStatus: filtersNotifier.setStatus,
      onDateRange: filtersNotifier.setColumnDateRange,
      onDueDateRange: filtersNotifier.setDueDateRange,
      onClearDateRange: filtersNotifier.clearColumnDateRange,
      onClearDueDateRange: filtersNotifier.clearDueDateRange,
    );

    Widget filterHeader(
      String label,
      PurchaseColumnFilterKind kind, {
      Alignment alignment = Alignment.centerLeft,
      String documentNoHint = 'Search',
    }) {
      return purchaseColumnFilterCell(
        label: label,
        kind: kind,
        headerStyle: purchaseTransactionTableHeaderStyle,
        isActive: purchaseColumnFilterIsActive(
          kind,
          columns,
          selectedStatus: filters.selectedStatus,
        ),
        columns: columns,
        actions: actions,
        partyOptions: partyOptions,
        statusOptions: purchaseFaStatusOptions,
        selectedStatus: filters.selectedStatus,
        alignment: alignment,
        documentNoHint: documentNoHint,
      );
    }

    return [
      ResizableDataColumn(
        initialWidth: purchaseTransactionDateColWidth,
        minWidth: 120,
        maxWidth: 280,
        header: filterHeader('Date', PurchaseColumnFilterKind.date),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionInvoiceColWidth,
        minWidth: 96,
        header: filterHeader(
          'Invoice no',
          PurchaseColumnFilterKind.documentNo,
          documentNoHint: 'Search invoice no',
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionPartyColMinWidth,
        minWidth: 120,
        header: filterHeader('Party Name', PurchaseColumnFilterKind.partyName),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionPaymentColWidth,
        minWidth: 100,
        header: filterHeader(
          'Payment Type',
          PurchaseColumnFilterKind.paymentType,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionAmountColWidth,
        minWidth: 80,
        header: filterHeader(
          'Amount',
          PurchaseColumnFilterKind.amount,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionBalanceColWidth,
        minWidth: 96,
        header: filterHeader(
          'Balance Due',
          PurchaseColumnFilterKind.balanceDue,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionDueDateColWidth,
        minWidth: 96,
        header: filterHeader('Due Date', PurchaseColumnFilterKind.dueDate),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionStatusColWidth,
        minWidth: 88,
        header: filterHeader('Status', PurchaseColumnFilterKind.status),
      ),
      const ResizableDataColumn(
        initialWidth: purchaseTransactionActionsColWidth3,
        minWidth: purchaseTransactionActionsColWidth3,
        maxWidth: purchaseTransactionActionsColWidth3,
        resizable: false,
        header: _HeaderCell(label: 'Actions'),
      ),
    ];
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: purchaseTransactionTableHeaderStyle,
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

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: purchaseTransactionTableDataStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: Align(alignment: alignment, child: wrapEllipsisTooltipChild(child)),
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
    final notifier = ref.read(purchaseFaFiltersProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => notifier.setPage(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textSecondary,
          ),
          Text(
            '$currentPage / $totalPages',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => notifier.setPage(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
