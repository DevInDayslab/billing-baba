import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/module_print_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/payment_out_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _emptyStateRed = Color(0xFFD32F2F);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

class PaymentOutTable extends ConsumerWidget {
  const PaymentOutTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPaymentOutRecordsProvider);
    final filters = ref.watch(paymentOutFiltersProvider);
    final searchQuery = ref.watch(paymentOutSearchQueryProvider);
    final filtersNotifier = ref.read(paymentOutFiltersProvider.notifier);
    final notifier = ref.read(paymentOutRecordsProvider.notifier);

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
                  'Transactions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const _PaymentOutSearchField(),
                if (filters.hasActiveFilters ||
                    searchQuery.trim().isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: filtersNotifier.clearAllFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      ModuleExportActions.exportPaymentOut(context, ref),
                  icon: const Icon(Icons.table_chart_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Excel Report',
                ),
                IconButton(
                  onPressed: () =>
                      ModulePrintActions.printPaymentOut(context, ref),
                  icon: const Icon(Icons.print_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Print',
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
          const Divider(height: 1, color: purchaseTransactionTableCardBorder),
          if (paginated.items.isEmpty)
            const _EmptyState()
          else
            _PaymentOutTransactionsTable(
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
    PaymentOutModel record,
    int index,
  ) {
    return ResizableDataRow(
      backgroundColor: index.isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(record.date))),
        _DataCell(child: Text(record.receiptNo)),
        _DataCell(
          child: Text(
            record.partyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.totalAmount),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.paidAmount),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(
          child: Text(
            record.paymentType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DataCell(child: PaymentOutStatusBadge(status: record.status)),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => VoucherPrintActions.previewPaymentOut(
                  context,
                  ref,
                  record.id,
                  filename: VoucherPrintActions.filenameFor(record.receiptNo),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Print / Preview',
              ),
              IconButton(
                onPressed: () => VoucherPrintActions.sharePaymentOut(
                  context,
                  ref,
                  record.id,
                  filename: VoucherPrintActions.filenameFor(record.receiptNo),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Share',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentOutTransactionsTable extends ConsumerWidget {
  const _PaymentOutTransactionsTable({
    required this.items,
    required this.onBuildRow,
  });

  final List<PaymentOutModel> items;
  final ResizableDataRow Function(PaymentOutModel record, int index) onBuildRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = _PaymentOutTableColumns.build(ref: ref);
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

class _PaymentOutTableColumns {
  const _PaymentOutTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(paymentOutFiltersProvider);
    final filtersNotifier = ref.read(paymentOutFiltersProvider.notifier);
    final partyOptions = ref.watch(paymentOutPartyOptionsProvider);
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
      onApplyTotalAmountFilter: filtersNotifier.applyTotalAmountFilter,
      onClearTotalAmountFilter: filtersNotifier.clearTotalAmountFilter,
      onApplyPaidAmountFilter: filtersNotifier.applyPaidAmountFilter,
      onClearPaidAmountFilter: filtersNotifier.clearPaidAmountFilter,
      onDateRange: filtersNotifier.setColumnDateRange,
      onClearDateRange: filtersNotifier.clearColumnDateRange,
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
        statusOptions: paymentOutStatusOptions,
        selectedStatus: filters.selectedStatus,
        alignment: alignment,
        documentNoHint: documentNoHint,
        paymentTypeOptions: PaymentOutDropdownOptions.paymentTypes,
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
        initialWidth: purchaseTransactionRefColWidth,
        minWidth: 96,
        header: filterHeader(
          'Ref. no.',
          PurchaseColumnFilterKind.documentNo,
          documentNoHint: 'Search ref no',
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionPartyColMinWidth,
        minWidth: 120,
        header: filterHeader('Party Name', PurchaseColumnFilterKind.partyName),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionAmountColWidth,
        minWidth: 100,
        header: filterHeader(
          'Total Amount',
          PurchaseColumnFilterKind.totalAmount,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionAmountColWidth,
        minWidth: 80,
        header: filterHeader(
          'Paid',
          PurchaseColumnFilterKind.paidAmount,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionPaymentColWidth,
        minWidth: 96,
        header: filterHeader(
          'Payment Type',
          PurchaseColumnFilterKind.paymentType,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionStatusColWidth,
        minWidth: 88,
        header: filterHeader('Status', PurchaseColumnFilterKind.status),
      ),
      const ResizableDataColumn(
        initialWidth: purchaseTransactionActionsColWidth2,
        minWidth: purchaseTransactionActionsColWidth2,
        maxWidth: purchaseTransactionActionsColWidth2,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl * 2,
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 40,
            color: _emptyStateRed.withValues(alpha: 0.85),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No Transaction Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'We could not find any transactions.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOutSearchField extends ConsumerStatefulWidget {
  const _PaymentOutSearchField();

  @override
  ConsumerState<_PaymentOutSearchField> createState() =>
      _PaymentOutSearchFieldState();
}

class _PaymentOutSearchFieldState
    extends ConsumerState<_PaymentOutSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(paymentOutSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(paymentOutSearchQueryProvider, (previous, next) {
      if (next != _controller.text) {
        _controller.text = next;
      }
    });

    return SizedBox(
      width: 200,
      height: 36,
      child: TextField(
        controller: _controller,
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
        onChanged: (value) =>
            ref.read(paymentOutSearchQueryProvider.notifier).setQuery(value),
        style: const TextStyle(fontSize: 13),
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
    final filtersNotifier = ref.read(paymentOutFiltersProvider.notifier);
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
          border: isActive
              ? null
              : Border.all(color: purchaseTransactionTableCardBorder),
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
