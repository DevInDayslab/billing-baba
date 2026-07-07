import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/print/presentation/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_actions.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_status_badge.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _addPurchaseFaBlue = Color(0xFF1565C0);

const _dateColWidth = 140.0;
const _invoiceColWidth = 100.0;
const _paymentColWidth = 110.0;
const _amountColWidth = 100.0;
const _balanceColWidth = 110.0;
const _dueDateColWidth = 100.0;
const _statusColWidth = 90.0;
const _actionsColWidth = 130.0;
const _colGap = 12.0;

const double _minTableWidth =
    _dateColWidth +
    _invoiceColWidth +
    _paymentColWidth +
    _amountColWidth +
    _balanceColWidth +
    _dueDateColWidth +
    _statusColWidth +
    _actionsColWidth +
    _colGap * 8 +
    160;

class PurchaseFaTable extends ConsumerWidget {
  const PurchaseFaTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPurchaseFaRecordsProvider);

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
                              'No fixed asset purchases found',
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
    PurchaseFaModel record,
  ) {
    return _TableDataRow(
      children: [
        _TableCell(
          width: _dateColWidth,
          child: Text(
            _dateFormat.format(record.date),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _invoiceColWidth,
          child: Text(
            record.invoiceNo,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: _TableCell(
            child: Text(
              record.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _TableCell(
          width: _paymentColWidth,
          child: Text(
            record.paymentType,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(record.amount)),
        ),
        _TableCell(
          width: _balanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(record.balanceDue)),
        ),
        _TableCell(
          width: _dueDateColWidth,
          child: Text(_dueDateFormat.format(record.dueDate)),
        ),
        _TableCell(
          width: _statusColWidth,
          child: PurchaseFaStatusBadge(status: record.status),
        ),
        _TableCell(
          width: _actionsColWidth,
          gapAfter: 0,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                    filename: VoucherPrintActions.filenameFor(record.invoiceNo),
                  ),
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

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
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
            width: _dateColWidth,
            child: Text('Date', style: _headerStyle),
          ),
          _TableCell(
            width: _invoiceColWidth,
            child: Text('Invoice no', style: _headerStyle),
          ),
          Expanded(
            child: _TableCell(child: Text('Party Name', style: _headerStyle)),
          ),
          _TableCell(
            width: _paymentColWidth,
            child: Text('Payment Type', style: _headerStyle),
          ),
          _TableCell(
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            child: Text('Amount', style: _headerStyle),
          ),
          _TableCell(
            width: _balanceColWidth,
            alignment: Alignment.centerRight,
            child: Text('Balance Due', style: _headerStyle),
          ),
          _TableCell(
            width: _dueDateColWidth,
            child: Text('Due Date', style: _headerStyle),
          ),
          _TableCell(
            width: _statusColWidth,
            child: Text('Status', style: _headerStyle),
          ),
          _TableCell(
            width: _actionsColWidth,
            gapAfter: 0,
            alignment: Alignment.centerRight,
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
