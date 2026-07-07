import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_return_actions.dart';
import 'package:billing_baba/features/purchases/providers/purchase_return_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_table_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _indexColWidth = 40.0;
const _dateColWidth = 132.0;
const _refColWidth = 80.0;
const _typeColWidth = 96.0;
const _amountColWidth = 112.0;
const _dueDateColWidth = 108.0;
const _statusColWidth = 100.0;
const _actionsColWidth = 132.0;
const _partyCategoryMinWidth = 280.0;

const double _minTableWidth =
    _indexColWidth +
    _dateColWidth +
    _refColWidth +
    _typeColWidth +
    _amountColWidth +
    _amountColWidth +
    _amountColWidth +
    _dueDateColWidth +
    _statusColWidth +
    _actionsColWidth +
    _partyCategoryMinWidth +
    salesTableColGap * 11;

class PurchaseReturnTable extends ConsumerWidget {
  const PurchaseReturnTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPurchaseReturnsProvider);
    final summary = ref.watch(purchaseReturnSummaryProvider);
    final filtersNotifier = ref.read(purchaseReturnFiltersProvider.notifier);
    final notifier = ref.read(purchaseReturnsProvider.notifier);

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
                SizedBox(
                  width: 200,
                  height: 36,
                  child: TextField(
                    onChanged: filtersNotifier.setSearchQuery,
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
                const Spacer(),
                SalesXlsChip(
                  onTap: () =>
                      ModuleExportActions.exportDebitNotes(context, ref),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use row actions to print a debit note'),
                      ),
                    );
                  },
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
          const Divider(height: 1, color: salesCardBorder),
          if (paginated.items.isEmpty)
            const SalesEmptyListState(message: 'No debit notes found')
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
                            const Divider(height: 1, color: salesCardBorder),
                          _buildRow(
                            context,
                            ref,
                            paginated.items[i],
                            (paginated.currentPage - 1) *
                                    purchaseReturnPageSize +
                                i +
                                1,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          const Divider(height: 1, color: salesCardBorder),
          _SummaryFooter(
            totalAmount: summary.totalAmount,
            balance: summary.balance,
          ),
          if (paginated.totalPages > 1) ...[
            const Divider(height: 1, color: salesCardBorder),
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
    PurchaseReturnModel item,
    int rowNumber,
  ) {
    return SalesTableDataRow(
      children: [
        SalesTableCell(
          width: _indexColWidth,
          child: Text('$rowNumber'),
        ),
        SalesTableCell(
          width: _dateColWidth,
          child: Text(
            _dateFormat.format(item.date),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SalesTableCell(
          width: _refColWidth,
          child: Text(
            item.debitNoteNo,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Expanded(
          flex: 3,
          child: _FlexTableCell(
            child: Text(
              item.partyName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _FlexTableCell(
            child: Text(
              item.categoryName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        SalesTableCell(
          width: _typeColWidth,
          child: Text(
            item.type,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SalesTableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.total),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        SalesTableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.receivedPaid),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        SalesTableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.balance),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        SalesTableCell(
          width: _dueDateColWidth,
          child: Text(
            _dueDateFormat.format(item.dueDate),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SalesTableCell(
          width: _statusColWidth,
          child: PurchaseBillStatusBadge(status: item.status),
        ),
        SalesTableCell(
          width: _actionsColWidth,
          gapAfter: 0,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  PrintRequest.debitNote(item.id),
                  filename: DocumentPrintActions.filenameFor(item.debitNoteNo),
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
                  PrintRequest.debitNote(item.id),
                  filename: DocumentPrintActions.filenameFor(item.debitNoteNo),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Share',
              ),
              SalesActionMenuButton(
                items: [
                  for (final action in purchaseReturnMenuActionsFor(item))
                    SalesActionMenuItem(
                      label: purchaseReturnMenuActionLabel(action),
                      onSelected: () => handlePurchaseReturnMenuAction(
                        context: context,
                        ref: ref,
                        action: action,
                        item: item,
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

/// Flexible column cell with right gap and clip so text cannot bleed into neighbors.
class _FlexTableCell extends StatelessWidget {
  const _FlexTableCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: salesTableColGap),
      child: ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: child,
        ),
      ),
    );
  }
}

class _SummaryFooter extends StatelessWidget {
  const _SummaryFooter({
    required this.totalAmount,
    required this.balance,
  });

  final double totalAmount;
  final double balance;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Total Amount: ${_currencyFormat.format(totalAmount)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            'Balance: ${_currencyFormat.format(balance)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
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
    final notifier = ref.read(purchaseReturnFiltersProvider.notifier);

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
            icon: const Icon(Icons.chevron_left, size: 20),
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
            icon: const Icon(Icons.chevron_right, size: 20),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: const Row(
        children: [
          SalesTableHeaderCell(label: '#', width: _indexColWidth),
          SalesTableHeaderCell(label: 'DATE', width: _dateColWidth),
          SalesTableHeaderCell(label: 'REF NO.', width: _refColWidth),
          Expanded(
            flex: 3,
            child: _FlexTableCell(
              child: Text('PARTY NAME', style: _TableHeaderRow._headerStyle),
            ),
          ),
          Expanded(
            flex: 2,
            child: _FlexTableCell(
              child: Text(
                'CATEGORY NAME',
                style: _TableHeaderRow._headerStyle,
              ),
            ),
          ),
          SalesTableHeaderCell(label: 'TYPE', width: _typeColWidth),
          SalesTableHeaderCell(
            label: 'TOTAL',
            width: _amountColWidth,
            alignment: Alignment.centerRight,
          ),
          SalesTableHeaderCell(
            label: 'RECEIVED/PAID',
            width: _amountColWidth,
            alignment: Alignment.centerRight,
          ),
          SalesTableHeaderCell(
            label: 'BALANCE',
            width: _amountColWidth,
            alignment: Alignment.centerRight,
          ),
          SalesTableHeaderCell(label: 'DUE DATE', width: _dueDateColWidth),
          SalesTableHeaderCell(label: 'STATUS', width: _statusColWidth),
          SalesTableHeaderCell(
            label: 'Actions',
            width: _actionsColWidth,
            gapAfter: 0,
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );
}
