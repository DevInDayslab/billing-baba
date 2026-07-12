import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_fa_status_badge.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/providers/sale_fa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

const _transactionTypeColWidth = 108.0;
const _noColWidth = 96.0;
const _dateColWidth = 120.0;
const _dueDateColWidth = 100.0;
const _amountColWidth = 100.0;
const _balanceColWidth = 100.0;
const _paymentColWidth = 110.0;
const _statusColWidth = 90.0;
const _actionsColWidth = 120.0;

const double _minTableWidth =
    _dateColWidth +
    _noColWidth +
    _transactionTypeColWidth +
    _paymentColWidth +
    _amountColWidth +
    _balanceColWidth +
    _dueDateColWidth +
    _statusColWidth +
    _actionsColWidth +
    160;

class SaleFaTable extends ConsumerWidget {
  const SaleFaTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faAsync = ref.watch(saleFaProvider);
    final paginated = ref.watch(paginatedSaleFaRecordsProvider);
    final notifier = ref.read(saleFaProvider.notifier);

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
                        .read(saleFaSearchQueryProvider.notifier)
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
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.addSaleFa),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Add Sale FA',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          faAsync.when(
            skipLoadingOnReload: true,
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    SalesErrorMapper.messageFor(error),
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
                                'No transactions to show',
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
    SaleFaModel record,
  ) {
    return _TableDataRow(
      children: [
        _TableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(record.createdAt)),
        ),
        _TableCell(
          width: _noColWidth,
          child: Text(record.invoiceNo),
        ),
        Expanded(
          child: _TableCell(
            child: Text(
              record.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const _TableCell(
          width: _transactionTypeColWidth,
          child: Text('Sale FA'),
        ),
        _TableCell(
          width: _paymentColWidth,
          child: Text(record.paymentType),
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
          child: SaleFaStatusBadge(status: record.status),
        ),
        _TableCell(
          width: _actionsColWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Print coming soon')),
                  );
                },
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
                  onChannelSelected: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share coming soon')),
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
              SalesActionMenuButton(
                items: [
                  SalesActionMenuItem(
                    label: 'Open',
                    onSelected: () async {
                      await context.push(
                        '${AppRoutes.editSaleFa}/${record.batchId}',
                      );
                    },
                  ),
                  SalesActionMenuItem(
                    label: 'Delete',
                    onSelected: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete sale?'),
                          content: Text('Delete ${record.invoiceNo}?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true || !context.mounted) return;
                      final error = await ref
                          .read(saleFaProvider.notifier)
                          .deleteBatch(record.batchId);
                      if (!context.mounted) return;
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    },
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
            width: _dateColWidth,
            child: Text('DATE', style: _headerStyle),
          ),
          _TableCell(
            width: _noColWidth,
            child: Text('INVOICE NO.', style: _headerStyle),
          ),
          Expanded(
            child: _TableCell(child: Text('PARTY NAME', style: _headerStyle)),
          ),
          _TableCell(
            width: _transactionTypeColWidth,
            child: Text('TRANSACTION TYPE', style: _headerStyle),
          ),
          _TableCell(
            width: _paymentColWidth,
            child: Text('PAYMENT TYPE', style: _headerStyle),
          ),
          _TableCell(
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            child: Text('AMOUNT', style: _headerStyle),
          ),
          _TableCell(
            width: _balanceColWidth,
            alignment: Alignment.centerRight,
            child: Text('BALANCE DUE', style: _headerStyle),
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
            child: SizedBox.shrink(),
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

class _PaginationRow extends ConsumerWidget {
  const _PaginationRow({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(saleFaFiltersProvider.notifier);

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
