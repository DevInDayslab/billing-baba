import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_column_filter_menu.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_actions.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_status_badge.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

const _dateColWidth = 120.0;
const _invoiceColWidth = 100.0;
const _paymentColWidth = 110.0;
const _statusColWidth = 90.0;
const _amountColWidth = 100.0;
const _balanceColWidth = 100.0;
const _dueDateColWidth = 100.0;
const _actionsColWidth = 120.0;
const _colGap = 12.0;

const double _minTableWidth =
    _dateColWidth +
    _invoiceColWidth +
    _paymentColWidth +
    _statusColWidth +
    _amountColWidth +
    _balanceColWidth +
    _dueDateColWidth +
    _actionsColWidth +
    _colGap * 8 +
    160;

class PurchaseBillTable extends ConsumerWidget {
  const PurchaseBillTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPurchaseBillsProvider);
    final filters = ref.watch(purchaseBillFiltersProvider);
    final searchQuery = ref.watch(purchaseBillSearchQueryProvider);
    final notifier = ref.read(purchaseBillsProvider.notifier);

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
                const _PurchaseBillSearchField(),
                if (filters.hasActiveFilters ||
                    searchQuery.trim().isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: ref
                        .read(purchaseBillFiltersProvider.notifier)
                        .clearAllFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
                const Spacer(),
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
                              'No purchase bills found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
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
    PurchaseBillModel bill,
  ) {
    return _TableDataRow(
      children: [
        _TableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(bill.date)),
        ),
        _TableCell(
          width: _invoiceColWidth,
          child: Text(bill.invoiceNo),
        ),
        Expanded(
          child: _TableCell(
            child: Text(
              bill.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _TableCell(
          width: _paymentColWidth,
          child: Text(bill.paymentType),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(bill.amount)),
        ),
        _TableCell(
          width: _balanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(bill.balanceDue)),
        ),
        _TableCell(
          width: _dueDateColWidth,
          child: Text(_dueDateFormat.format(bill.dueDate)),
        ),
        _TableCell(
          width: _statusColWidth,
          child: PurchaseBillStatusBadge(status: bill.status),
        ),
        _TableCell(
          width: _actionsColWidth,
          gapAfter: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  PrintRequest.purchaseBill(bill.id),
                  filename: DocumentPrintActions.filenameFor(bill.invoiceNo),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Print',
              ),
              IconButton(
                onPressed: () => DocumentPrintActions.share(
                  context,
                  ref,
                  PrintRequest.purchaseBill(bill.id),
                  filename: DocumentPrintActions.filenameFor(bill.invoiceNo),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Share',
              ),
              SalesActionMenuButton(
                items: [
                  for (final action in purchaseBillMenuActionsFor(bill))
                    SalesActionMenuItem(
                      label: purchaseBillMenuActionLabel(action),
                      onSelected: () => handlePurchaseBillMenuAction(
                        context: context,
                        ref: ref,
                        action: action,
                        bill: bill,
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

class _PurchaseBillSearchField extends ConsumerStatefulWidget {
  const _PurchaseBillSearchField();

  @override
  ConsumerState<_PurchaseBillSearchField> createState() =>
      _PurchaseBillSearchFieldState();
}

class _PurchaseBillSearchFieldState
    extends ConsumerState<_PurchaseBillSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(purchaseBillSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(purchaseBillSearchQueryProvider, (previous, next) {
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
            ref.read(purchaseBillSearchQueryProvider.notifier).setQuery(value),
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
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          PurchaseBillColumnFilterCell(
            width: _dateColWidth,
            label: 'Date',
            kind: PurchaseBillColumnFilterKind.date,
            headerStyle: _TableHeaderRow._headerStyle,
            gapAfter: _colGap,
          ),
          PurchaseBillColumnFilterCell(
            width: _invoiceColWidth,
            label: 'Invoice no',
            kind: PurchaseBillColumnFilterKind.invoiceNo,
            headerStyle: _TableHeaderRow._headerStyle,
            gapAfter: _colGap,
          ),
          Expanded(
            child: PurchaseBillColumnFilterCell(
              label: 'Party Name',
              kind: PurchaseBillColumnFilterKind.partyName,
              headerStyle: _TableHeaderRow._headerStyle,
              gapAfter: _colGap,
            ),
          ),
          PurchaseBillColumnFilterCell(
            width: _paymentColWidth,
            label: 'Payment Type',
            kind: PurchaseBillColumnFilterKind.paymentType,
            headerStyle: _TableHeaderRow._headerStyle,
            gapAfter: _colGap,
          ),
          PurchaseBillColumnFilterCell(
            width: _amountColWidth,
            label: 'Amount',
            kind: PurchaseBillColumnFilterKind.amount,
            headerStyle: _TableHeaderRow._headerStyle,
            alignment: Alignment.centerRight,
            gapAfter: _colGap,
          ),
          PurchaseBillColumnFilterCell(
            width: _balanceColWidth,
            label: 'Balance Due',
            kind: PurchaseBillColumnFilterKind.balanceDue,
            headerStyle: _TableHeaderRow._headerStyle,
            alignment: Alignment.centerRight,
            gapAfter: _colGap,
          ),
          PurchaseBillColumnFilterCell(
            width: _dueDateColWidth,
            label: 'Due Date',
            kind: PurchaseBillColumnFilterKind.dueDate,
            headerStyle: _TableHeaderRow._headerStyle,
            gapAfter: _colGap,
          ),
          PurchaseBillColumnFilterCell(
            width: _statusColWidth,
            label: 'Status',
            kind: PurchaseBillColumnFilterKind.status,
            headerStyle: _TableHeaderRow._headerStyle,
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
    final filtersNotifier = ref.read(purchaseBillFiltersProvider.notifier);
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
