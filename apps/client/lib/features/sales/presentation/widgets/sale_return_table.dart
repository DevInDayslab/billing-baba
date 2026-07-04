import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/providers/sale_return_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

const _dateColWidth = 100.0;
const _invoiceColWidth = 100.0;
const _transactionColWidth = 110.0;
const _paymentColWidth = 110.0;
const _statusColWidth = 100.0;
const _amountColWidth = 100.0;
const _balanceColWidth = 90.0;
const _actionsColWidth = 48.0;

const double _minTableWidth =
    _dateColWidth +
    _invoiceColWidth +
    _transactionColWidth +
    _paymentColWidth +
    _statusColWidth +
    _amountColWidth +
    _balanceColWidth +
    _actionsColWidth +
    160;

class SaleReturnTable extends ConsumerWidget {
  const SaleReturnTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedSaleReturnsProvider);
    final listNotifier = ref.read(
      salesDocumentsListProvider(salesReturnListScope()).notifier,
    );

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
                const Spacer(),
                IconButton(
                  onPressed: listNotifier.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Refresh',
                ),
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
          if (paginated.isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (paginated.error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      paginated.error.toString(),
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: listNotifier.refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (paginated.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No credit notes found',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
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
                          _buildRow(paginated.items[i]),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRow(SaleReturnRecord record) {
    return _TableDataRow(
      children: [
        _TableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(record.date)),
        ),
        _TableCell(
          width: _invoiceColWidth,
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
        _TableCell(
          width: _transactionColWidth,
          child: Text(record.transaction),
        ),
        _TableCell(
          width: _paymentColWidth,
          child: Text(record.paymentType),
        ),
        _TableCell(
          width: _statusColWidth,
          child: Text(record.status),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(record.amount)),
        ),
        _TableCell(
          width: _balanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(record.balance)),
        ),
        _TableCell(
          width: _actionsColWidth,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 20),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
      ],
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
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
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
            width: _transactionColWidth,
            child: Text('Transaction', style: _headerStyle),
          ),
          _TableCell(
            width: _paymentColWidth,
            child: Text('Payment Type', style: _headerStyle),
          ),
          _TableCell(
            width: _statusColWidth,
            child: Text('Status', style: _headerStyle),
          ),
          _TableCell(
            width: _amountColWidth,
            child: Text('Amount', style: _headerStyle),
          ),
          _TableCell(
            width: _balanceColWidth,
            child: Text('Balance', style: _headerStyle),
          ),
          _TableCell(
            width: _actionsColWidth,
            child: Text('Actions', style: _headerStyle),
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
          'xls',
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
