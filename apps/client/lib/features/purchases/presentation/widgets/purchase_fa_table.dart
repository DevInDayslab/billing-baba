import 'package:billing_baba/features/export/presentation/widgets/module_export_actions.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/print/presentation/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_status_badge.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

const _partyColWidth = 160.0;
const _noColWidth = 90.0;
const _dateColWidth = 110.0;
const _dueDateColWidth = 100.0;
const _amountColWidth = 120.0;
const _balanceColWidth = 110.0;
const _paymentColWidth = 110.0;
const _statusColWidth = 90.0;
const _actionsColWidth = 100.0;

const double _minTableWidth =
    _partyColWidth +
    _noColWidth +
    _dateColWidth +
    _dueDateColWidth +
    _amountColWidth +
    _balanceColWidth +
    _paymentColWidth +
    _statusColWidth +
    _actionsColWidth +
    32;

class PurchaseFaTable extends ConsumerWidget {
  const PurchaseFaTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faAsync = ref.watch(purchaseFaProvider);
    final paginated = ref.watch(paginatedPurchaseFaRecordsProvider);
    final notifier = ref.read(purchaseFaProvider.notifier);

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
                const Spacer(),
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
                _XlsChip(
                  onTap: () =>
                      ModuleExportActions.exportFixedAssets(context, ref),
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
          faAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    PurchaseErrorMapper.messageFor(error),
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: notifier.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (_) => LayoutBuilder(
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
          width: _partyColWidth,
          child: Text(
            record.partyName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _noColWidth,
          child: Text(record.invoiceNo),
        ),
        _TableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(record.date)),
        ),
        _TableCell(
          width: _dueDateColWidth,
          child: Text(_dateFormat.format(record.dueDate)),
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
          width: _paymentColWidth,
          child: Text(record.paymentType),
        ),
        _TableCell(
          width: _statusColWidth,
          child: PurchaseFaStatusBadge(status: record.status),
        ),
        _TableCell(
          width: _actionsColWidth,
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
                tooltip: 'Print / Preview',
              ),
              Tooltip(
                message: 'Share',
                child: ShareMenuButton(
                  overlayOffset: const Offset(0, 4),
                  targetAnchor: Alignment.bottomRight,
                  followerAnchor: Alignment.topRight,
                  onChannelSelected: (_) => VoucherPrintActions.shareFixedAssetPurchase(
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
              IconButton(
                onPressed: () => _showRecordActions(context, ref, record),
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

  Future<void> _showRecordActions(
    BuildContext context,
    WidgetRef ref,
    PurchaseFaModel record,
  ) async {
    final action = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 400, 200, 0),
      items: const [
        PopupMenuItem(value: 'open', child: Text('Open')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );

    if (action == null || !context.mounted) return;
    final notifier = ref.read(purchaseFaProvider.notifier);

    switch (action) {
      case 'open':
        await context.push('${AppRoutes.editPurchaseFa}/${record.batchId}');
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete purchase?'),
            content: Text('Delete ${record.invoiceNo}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        final error = await notifier.deleteBatch(record.batchId);
        if (!context.mounted) return;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
    }
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  static const _headerStyle = TextStyle(
    fontSize: 12,
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
            width: _partyColWidth,
            child: Text('PARTY', style: _headerStyle),
          ),
          _TableCell(
            width: _noColWidth,
            child: Text('NO.', style: _headerStyle),
          ),
          _TableCell(
            width: _dateColWidth,
            child: Text('DATE', style: _headerStyle),
          ),
          _TableCell(
            width: _dueDateColWidth,
            child: Text('DUE DATE', style: _headerStyle),
          ),
          _TableCell(
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            child: Text('TOTAL AMOUNT', style: _headerStyle),
          ),
          _TableCell(
            width: _balanceColWidth,
            alignment: Alignment.centerRight,
            child: Text('BALANCE', style: _headerStyle),
          ),
          _TableCell(
            width: _paymentColWidth,
            child: Text('PAYMENT', style: _headerStyle),
          ),
          _TableCell(
            width: _statusColWidth,
            child: Text('STATUS', style: _headerStyle),
          ),
          _TableCell(
            width: _actionsColWidth,
            child: Text('ACTION', style: _headerStyle),
          ),
        ],
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(children: children),
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
    return Expanded(child: content);
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

class _XlsChip extends StatelessWidget {
  const _XlsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Text(
            'xls',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ),
    );
  }
}
