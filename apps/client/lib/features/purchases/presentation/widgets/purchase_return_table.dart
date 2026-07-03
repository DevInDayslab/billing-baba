import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_status_badge.dart';
import 'package:billing_baba/features/purchases/providers/purchase_return_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

const _indexColWidth = 36.0;
const _dateColWidth = 120.0;
const _refColWidth = 72.0;
const _typeColWidth = 100.0;
const _amountColWidth = 100.0;
const _statusColWidth = 90.0;
const _dueDateColWidth = 100.0;
const _actionsColWidth = 120.0;

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
    200;

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
                _XlsChip(onTap: () => debugPrint('Export xls tapped')),
                IconButton(
                  onPressed: () => debugPrint('Print tapped'),
                  icon: const Icon(Icons.print_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Print',
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
                              'No debit notes found',
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
                          _buildRow(
                            context,
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
          const Divider(height: 1, color: _cardBorder),
          _SummaryFooter(
            totalAmount: summary.totalAmount,
            balance: summary.balance,
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
    PurchaseReturnModel item,
    int rowNumber,
  ) {
    return _TableDataRow(
      children: [
        _TableCell(
          width: _indexColWidth,
          child: Text('$rowNumber'),
        ),
        _TableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(item.date)),
        ),
        _TableCell(
          width: _refColWidth,
          child: Text(item.debitNoteNo),
        ),
        Expanded(
          child: _TableCell(
            child: Text(
              item.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          child: _TableCell(
            child: Text(
              item.categoryName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _TableCell(
          width: _typeColWidth,
          child: Text(item.type),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(item.total)),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(item.receivedPaid)),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(item.balance)),
        ),
        _TableCell(
          width: _dueDateColWidth,
          child: Text(_dueDateFormat.format(item.dueDate)),
        ),
        _TableCell(
          width: _statusColWidth,
          child: PurchaseBillStatusBadge(status: item.status),
        ),
        _TableCell(
          width: _actionsColWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => debugPrint('Print ${item.debitNoteNo}'),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Print',
              ),
              Tooltip(
                message: 'Share',
                child: ShareMenuButton(
                  overlayOffset: const Offset(0, 4),
                  targetAnchor: Alignment.bottomRight,
                  followerAnchor: Alignment.topRight,
                  onChannelSelected: (channel) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${channel.label} ${item.debitNoteNo} coming soon',
                        ),
                      ),
                    );
                  },
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => debugPrint('More ${item.debitNoteNo}'),
                icon: const Icon(Icons.more_vert, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'More',
              ),
            ],
          ),
        ),
      ],
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
  });

  final Widget child;
  final double? width;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final content = Align(alignment: alignment, child: child);

    if (width != null) {
      return SizedBox(width: width, child: content);
    }

    return content;
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

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
          _TableCell(
            width: _indexColWidth,
            child: Text('#', style: _headerStyle),
          ),
          _TableCell(
            width: _dateColWidth,
            child: Text('DATE', style: _headerStyle),
          ),
          _TableCell(
            width: _refColWidth,
            child: Text('REF NO.', style: _headerStyle),
          ),
          Expanded(
            child: _TableCell(child: Text('PARTY NAME', style: _headerStyle)),
          ),
          Expanded(
            child: _TableCell(
              child: Text('CATEGORY NAME', style: _headerStyle),
            ),
          ),
          _TableCell(
            width: _typeColWidth,
            child: Text('TYPE', style: _headerStyle),
          ),
          _TableCell(
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            child: Text('TOTAL', style: _headerStyle),
          ),
          _TableCell(
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            child: Text('RECEIVED/PAID', style: _headerStyle),
          ),
          _TableCell(
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            child: Text('BALANCE', style: _headerStyle),
          ),
          _TableCell(
            width: _dueDateColWidth,
            child: Text('DUE DATE', style: _headerStyle),
          ),
          _TableCell(
            width: _statusColWidth,
            child: Text('STATUS', style: _headerStyle),
          ),
          _TableCell(
            width: _actionsColWidth,
            child: Text('PRINT / SHARE', style: _headerStyle),
          ),
        ],
      ),
    );
  }
}

class _XlsChip extends StatelessWidget {
  const _XlsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4CAF50)),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Text(
          'Excel Report',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4CAF50),
          ),
        ),
      ),
    );
  }
}
