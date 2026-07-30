import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_movement_indicator.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _tableBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const _cellHorizontalPadding = 8.0;

const _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.3,
  color: AppColors.textSecondary,
);

const _indicatorColWidth = 28.0;
const _typeColWidth = 132.0;
const _dateColWidth = 148.0;
const _userColWidth = 120.0;
const _changeColWidth = 88.0;
const _balanceColWidth = 88.0;
const _godownColWidth = 108.0;
const _referenceColWidth = 108.0;
const _notesColWidth = 160.0;

/// Immutable stock movement ledger for product item details.
class InventoryStockHistoryTable extends ConsumerWidget {
  const InventoryStockHistoryTable({
    required this.itemId,
    required this.unitLabel,
    super.key,
  });

  final String itemId;
  final String unitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(productTransactionsProvider(itemId));
    final paginated = ref.watch(paginatedProductTransactionsProvider(itemId));
    final stockAfter = ref.watch(productStockAfterProvider(itemId));
    final hasSearch = ref
        .watch(productTransactionSearchQueryProvider)
        .isNotEmpty;

    ref.listen(productTransactionSearchQueryProvider, (previous, next) {
      if (previous != next) {
        ref.read(productTransactionFiltersProvider.notifier).setPage(0);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          child: Row(
            children: [
              const Text(
                'STOCK HISTORY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              ExpandableTableSearchField(
                hint: 'Search stock history',
                initialQuery: ref.read(productTransactionSearchQueryProvider),
                onQueryChanged: (query) =>
                    ref
                            .read(
                              productTransactionSearchQueryProvider.notifier,
                            )
                            .query =
                        query,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _tableBorder),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: transactionsAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) => _StockHistoryTableShell(
                rows: const [],
                unitLabel: unitLabel,
                stockAfter: const {},
                showEmpty: true,
                isFiltered: false,
              ),
              data: (_) => _StockHistoryTableShell(
                rows: paginated.items,
                unitLabel: unitLabel,
                stockAfter: stockAfter,
                showEmpty: paginated.totalItems == 0,
                isFiltered: hasSearch,
              ),
            ),
          ),
        ),
        if (paginated.totalPages > 1) ...[
          const Divider(height: 1, color: _tableBorder),
          _StockHistoryPaginationRow(
            currentPage: paginated.currentPage,
            totalPages: paginated.totalPages,
          ),
        ],
      ],
    );
  }
}

class _StockHistoryTableShell extends StatelessWidget {
  const _StockHistoryTableShell({
    required this.rows,
    required this.unitLabel,
    required this.stockAfter,
    required this.showEmpty,
    required this.isFiltered,
  });

  final List<ProductTransaction> rows;
  final String unitLabel;
  final Map<String, double> stockAfter;
  final bool showEmpty;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final columns = _StockHistoryTableColumns.build();
    final dataRows = [
      for (var index = 0; index < rows.length; index++)
        _StockHistoryTableColumns.buildDataRow(
          transaction: rows[index],
          unitLabel: unitLabel,
          balance: stockAfter[rows[index].id],
          isOdd: index.isOdd,
        ),
    ];

    if (showEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StockHistoryTableFrame(
            child: ResizableDataTable(
              columns: columns,
              rows: const [],
              headerBackgroundColor: const Color(0xFFF5F5F5),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                isFiltered
                    ? 'No matching stock updates'
                    : 'No stock history yet',
                style: InventoryStyles.emptyStateStyle,
              ),
            ),
          ),
        ],
      );
    }

    return _StockHistoryTableFrame(
      child: SizedBox.expand(
        child: ResizableDataTable(
          columns: columns,
          rows: dataRows,
          headerBackgroundColor: const Color(0xFFF5F5F5),
        ),
      ),
    );
  }
}

class _StockHistoryTableFrame extends StatelessWidget {
  const _StockHistoryTableFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: _tableBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: child,
      ),
    );
  }
}

class _StockHistoryTableColumns {
  const _StockHistoryTableColumns._();

  static List<ResizableDataColumn> build() {
    return [
      const ResizableDataColumn(
        initialWidth: _indicatorColWidth,
        minWidth: _indicatorColWidth,
        maxWidth: _indicatorColWidth,
        resizable: false,
        header: SizedBox.shrink(),
      ),
      const ResizableDataColumn(
        initialWidth: _typeColWidth,
        header: _HeaderCell(label: 'Type'),
      ),
      const ResizableDataColumn(
        initialWidth: _dateColWidth,
        header: _HeaderCell(label: 'Date & Time'),
      ),
      const ResizableDataColumn(
        initialWidth: _userColWidth,
        header: _HeaderCell(label: 'Updated By'),
      ),
      const ResizableDataColumn(
        initialWidth: _changeColWidth,
        header: _HeaderCell(label: 'Change', alignment: Alignment.centerRight),
      ),
      const ResizableDataColumn(
        initialWidth: _balanceColWidth,
        header: _HeaderCell(label: 'Balance', alignment: Alignment.centerRight),
      ),
      const ResizableDataColumn(
        initialWidth: _godownColWidth,
        header: _HeaderCell(label: 'Godown'),
      ),
      const ResizableDataColumn(
        initialWidth: _referenceColWidth,
        header: _HeaderCell(label: 'Reference'),
      ),
      const ResizableDataColumn(
        initialWidth: _notesColWidth,
        header: _HeaderCell(label: 'Notes'),
      ),
    ];
  }

  static ResizableDataRow buildDataRow({
    required ProductTransaction transaction,
    required String unitLabel,
    required double? balance,
    required bool isOdd,
  }) {
    final quantityColor = transaction.isInbound
        ? inventoryPositiveColor
        : inventoryNegativeColor;
    final signedPrefix = transaction.isInbound ? '+' : '-';
    final unit = transaction.unit ?? unitLabel;
    final changeText =
        '$signedPrefix${formatQuantityValue(transaction.quantity)} $unit';
    final balanceText = balance == null
        ? inventoryEmDash
        : formatQuantityValue(balance);
    final userName = transaction.createdByName?.trim();
    final notes = transaction.notes?.trim();
    final reference = transaction.referenceNo.trim().isNotEmpty
        ? transaction.referenceNo
        : inventoryEmDash;

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(
          alignment: Alignment.center,
          child: InventoryMovementIndicator(
            movementType: transaction.movementType,
          ),
        ),
        _DataCell(
          child: Text(
            transaction.typeLabel,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DataCell(
          child: Text(
            DateTimeUtils.formatDisplayDateTime(transaction.date),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DataCell(
          child: AppEllipsisText(
            userName == null || userName.isEmpty ? inventoryEmDash : userName,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            changeText,
            style: TextStyle(
              color: quantityColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(balanceText),
        ),
        _DataCell(
          child: AppEllipsisText(
            transaction.godownName?.trim().isNotEmpty == true
                ? transaction.godownName!
                : inventoryEmDash,
          ),
        ),
        _DataCell(
          child: AppEllipsisText(reference),
        ),
        _DataCell(
          child: AppEllipsisText(
            notes == null || notes.isEmpty ? inventoryEmDash : notes,
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: 2,
      ),
      child: Align(
        alignment: alignment,
        child: Text(
          label.toUpperCase(),
          style: _headerStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
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
    fontSize: 12,
    color: AppColors.textPrimary,
    height: 1.35,
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
          vertical: 4,
        ),
        child: Align(
          alignment: alignment,
          child: wrapEllipsisTooltipChild(child),
        ),
      ),
    );
  }
}

class _StockHistoryPaginationRow extends ConsumerWidget {
  const _StockHistoryPaginationRow({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productTransactionFiltersProvider.notifier);
    final canGoPrevious = currentPage > 0;
    final canGoNext = currentPage < totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: canGoPrevious
                ? () => notifier.setPage(currentPage - 1)
                : null,
            child: const Text('Previous', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Page ${currentPage + 1} of $totalPages',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: canGoNext
                ? () => notifier.setPage(currentPage + 1)
                : null,
            child: const Text('Next', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
