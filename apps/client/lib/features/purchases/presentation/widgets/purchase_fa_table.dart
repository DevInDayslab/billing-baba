import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/date_time_utils.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/print/presentation/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_actions.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _addPurchaseFaBlue = Color(0xFF1565C0);

const double _minTableWidth =
    purchaseTransactionDateColWidth +
    purchaseTransactionInvoiceColWidth +
    purchaseTransactionPartyColMinWidth +
    purchaseTransactionPaymentColWidth +
    purchaseTransactionAmountColWidth +
    purchaseTransactionBalanceColWidth +
    purchaseTransactionDueDateColWidth +
    purchaseTransactionStatusColWidth +
    purchaseTransactionActionsColWidth3;

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
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth.clamp(
                _minTableWidth,
                double.infinity,
              );

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TableHeaderRow(),
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
                        for (final record in paginated.items)
                          _buildRow(context, ref, record),
                    ],
                  ),
                ),
              );
            },
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

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    PurchaseFaModel record,
  ) {
    return PurchaseTransactionTableDataRow(
      children: [
        PurchaseTransactionTableCell(
          width: purchaseTransactionDateColWidth,
          child: Text(
            DateTimeUtils.formatDisplayDate(record.date),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionInvoiceColWidth,
          child: Text(
            record.invoiceNo,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: PurchaseTransactionTableCell(
            child: Text(
              record.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionPaymentColWidth,
          child: Text(
            record.paymentType,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.amount),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionBalanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.balanceDue),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDueDateColWidth,
          child: Text(_dueDateFormat.format(record.dueDate)),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionStatusColWidth,
          child: PurchaseFaStatusBadge(status: record.status),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionActionsColWidth3,
          showDivider: false,
          alignment: Alignment.center,
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

class _TableHeaderRow extends ConsumerWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return PurchaseTransactionTableHeaderRow(
      children: [
        PurchaseTransactionTableCell(
          width: purchaseTransactionDateColWidth,
          child: purchaseColumnFilterCell(
            label: 'Date',
            kind: PurchaseColumnFilterKind.date,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.date,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseFaStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionInvoiceColWidth,
          child: purchaseColumnFilterCell(
            label: 'Invoice no',
            kind: PurchaseColumnFilterKind.documentNo,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.documentNo,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseFaStatusOptions,
            selectedStatus: filters.selectedStatus,
            documentNoHint: 'Search invoice no',
          ),
        ),
        Expanded(
          child: PurchaseTransactionTableCell(
            child: purchaseColumnFilterCell(
              label: 'Party Name',
              kind: PurchaseColumnFilterKind.partyName,
              headerStyle: purchaseTransactionTableHeaderStyle,
              isActive: purchaseColumnFilterIsActive(
                PurchaseColumnFilterKind.partyName,
                columns,
              ),
              columns: columns,
              actions: actions,
              partyOptions: partyOptions,
              statusOptions: purchaseFaStatusOptions,
              selectedStatus: filters.selectedStatus,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionPaymentColWidth,
          child: purchaseColumnFilterCell(
            label: 'Payment Type',
            kind: PurchaseColumnFilterKind.paymentType,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.paymentType,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseFaStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'Amount',
            kind: PurchaseColumnFilterKind.amount,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.amount,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseFaStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionBalanceColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'Balance Due',
            kind: PurchaseColumnFilterKind.balanceDue,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.balanceDue,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseFaStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDueDateColWidth,
          child: purchaseColumnFilterCell(
            label: 'Due Date',
            kind: PurchaseColumnFilterKind.dueDate,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.dueDate,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseFaStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionStatusColWidth,
          child: purchaseColumnFilterCell(
            label: 'Status',
            kind: PurchaseColumnFilterKind.status,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnStatusFilterIsActive(
              filters.selectedStatus,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseFaStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        const PurchaseTransactionTableCell(
          width: purchaseTransactionActionsColWidth3,
          showDivider: false,
          alignment: Alignment.center,
          child: Text('Actions', style: purchaseTransactionTableHeaderStyle),
        ),
      ],
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
