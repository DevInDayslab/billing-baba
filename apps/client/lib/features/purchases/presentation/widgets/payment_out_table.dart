import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/payment_out_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_column_filter_builder.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_column_filter_cell.dart';
import 'package:billing_baba/features/purchases/providers/payment_out_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _emptyStateRed = Color(0xFFD32F2F);

const _dateColWidth = 140.0;
const _refColWidth = 140.0;
const _paymentColWidth = 130.0;
const _statusColWidth = 80.0;
const _amountColWidth = 140.0;
const _actionsColWidth = 80.0;
const _colGap = 12.0;

const double _minTableWidth =
    _dateColWidth +
    _refColWidth +
    _paymentColWidth +
    _statusColWidth +
    _amountColWidth * 2 +
    _actionsColWidth +
    _colGap * 6 +
    160;

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
                const SizedBox(width: AppSpacing.md),
                const _PaymentOutSearchField(),
                if (filters.hasActiveFilters || searchQuery.trim().isNotEmpty) ...[
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
                  onPressed: () => debugPrint('Print tapped'),
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
          const Divider(height: 1, color: _cardBorder),
          if (paginated.items.isEmpty)
            const _EmptyState()
          else
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
                        for (var i = 0; i < paginated.items.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: _cardBorder),
                          _buildRow(context, ref, paginated.items[i]),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          if (paginated.totalPages > 1) ...[
            const Divider(height: 1, color: _cardBorder),
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
    PaymentOutModel record,
  ) {
    return _TableDataRow(
      children: [
        _TableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(record.date)),
        ),
        _TableCell(
          width: _refColWidth,
          child: Text(record.receiptNo),
        ),
        Expanded(
          child: _TableCell(
            child: Text(
              record.partyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.totalAmount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.paidAmount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _paymentColWidth,
          child: Text(
            record.paymentType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _statusColWidth,
          child: PaymentOutStatusBadge(status: record.status),
        ),
        _TableCell(
          width: _actionsColWidth,
          gapAfter: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Share',
              ),
            ],
          ),
        ),
      ],
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

class _PaymentOutSearchFieldState extends ConsumerState<_PaymentOutSearchField> {
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

class _TableHeaderRow extends ConsumerWidget {
  const _TableHeaderRow();

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(paymentOutFiltersProvider);
    final filtersNotifier = ref.read(paymentOutFiltersProvider.notifier);
    final partyOptions = ref.watch(paymentOutPartyOptionsProvider);
    final columns = filters.columnFilters;

    final actions = PurchaseColumnFilterActions(
      onDocumentNo: filtersNotifier.setDocumentNoFilter,
      onParty: filtersNotifier.setParty,
      onPaymentType: filtersNotifier.setPaymentType,
      onAmountRange: ({min, max}) {},
      onBalanceRange: ({min, max}) {},
      onStatus: filtersNotifier.setStatus,
      onTotalAmountRange: filtersNotifier.setTotalAmountRange,
      onPaidAmountRange: filtersNotifier.setPaidAmountRange,
      onDateRange: filtersNotifier.setColumnDateRange,
    );

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          purchaseColumnFilterCell(
            label: 'Date',
            kind: PurchaseColumnFilterKind.date,
            headerStyle: _headerStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.date,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: paymentOutStatusOptions,
            selectedStatus: filters.selectedStatus,
            width: _dateColWidth,
            gapAfter: _colGap,
          ),
          purchaseColumnFilterCell(
            label: 'Ref. no.',
            kind: PurchaseColumnFilterKind.documentNo,
            headerStyle: _headerStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.documentNo,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: paymentOutStatusOptions,
            selectedStatus: filters.selectedStatus,
            width: _refColWidth,
            gapAfter: _colGap,
            documentNoHint: 'Search ref no',
          ),
          Expanded(
            child: purchaseColumnFilterCell(
              label: 'Party Name',
              kind: PurchaseColumnFilterKind.partyName,
              headerStyle: _headerStyle,
              isActive: purchaseColumnFilterIsActive(
                PurchaseColumnFilterKind.partyName,
                columns,
              ),
              columns: columns,
              actions: actions,
              partyOptions: partyOptions,
              statusOptions: paymentOutStatusOptions,
              selectedStatus: filters.selectedStatus,
              gapAfter: _colGap,
            ),
          ),
          purchaseColumnFilterCell(
            label: 'Total Amount',
            kind: PurchaseColumnFilterKind.totalAmount,
            headerStyle: _headerStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.totalAmount,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: paymentOutStatusOptions,
            selectedStatus: filters.selectedStatus,
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            gapAfter: _colGap,
          ),
          purchaseColumnFilterCell(
            label: 'Paid',
            kind: PurchaseColumnFilterKind.paidAmount,
            headerStyle: _headerStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.paidAmount,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: paymentOutStatusOptions,
            selectedStatus: filters.selectedStatus,
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            gapAfter: _colGap,
          ),
          purchaseColumnFilterCell(
            label: 'Payment Type',
            kind: PurchaseColumnFilterKind.paymentType,
            headerStyle: _headerStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.paymentType,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: paymentOutStatusOptions,
            selectedStatus: filters.selectedStatus,
            paymentTypeOptions: PaymentOutDropdownOptions.paymentTypes,
            width: _paymentColWidth,
            gapAfter: _colGap,
          ),
          purchaseColumnFilterCell(
            label: 'Status',
            kind: PurchaseColumnFilterKind.status,
            headerStyle: _headerStyle,
            isActive: purchaseColumnStatusFilterIsActive(filters.selectedStatus),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: paymentOutStatusOptions,
            selectedStatus: filters.selectedStatus,
            width: _statusColWidth,
            gapAfter: _colGap,
          ),
          const _TableCell(
            width: _actionsColWidth,
            gapAfter: 0,
            child: Text('Actions', style: _headerStyle),
          ),
        ],
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({required this.children});

  final List<Widget> children;

  static const _dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: _dataStyle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(children: children),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.child,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.gapAfter = _colGap,
  });

  final Widget child;
  final double? width;
  final Alignment alignment;
  final double gapAfter;

  @override
  Widget build(BuildContext context) {
    final content = Align(
      alignment: alignment,
      widthFactor: 1,
      child: child,
    );

    if (width != null) {
      return Padding(
        padding: EdgeInsets.only(right: gapAfter),
        child: SizedBox(
          width: width,
          child: ClipRect(child: content),
        ),
      );
    }

    return ClipRect(child: content);
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
