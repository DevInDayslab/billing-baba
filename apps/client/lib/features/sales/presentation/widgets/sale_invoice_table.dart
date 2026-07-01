import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_status_badge.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
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
const _actionsColWidth = 120.0;

const _minTableWidth =
    _dateColWidth +
    _invoiceColWidth +
    _transactionColWidth +
    _paymentColWidth +
    _statusColWidth +
    _amountColWidth +
    _balanceColWidth +
    _actionsColWidth +
    160; // party name minimum

class SaleInvoiceTable extends ConsumerWidget {
  const SaleInvoiceTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedSaleInvoicesProvider);

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
                  onPressed: () => debugPrint('Search tapped'),
                  icon: const Icon(Icons.search, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Search',
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
                        if (i > 0) const Divider(height: 1, color: _cardBorder),
                        _buildRow(paginated.items[i]),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, color: _cardBorder),
          _PaginationRow(
            currentPage: paginated.currentPage,
            totalPages: paginated.totalPages,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(SaleInvoiceModel invoice) {
    return _TableDataRow(
      children: [
        _TableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(invoice.date)),
        ),
        _TableCell(
          width: _invoiceColWidth,
          child: Text(invoice.invoiceNo),
        ),
        Expanded(
          child: _TableCell(
            child: Text(
              invoice.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _TableCell(
          width: _transactionColWidth,
          child: _TransactionTypeLabel(type: invoice.transactionType),
        ),
        _TableCell(
          width: _paymentColWidth,
          child: Text(invoice.paymentType),
        ),
        _TableCell(
          width: _statusColWidth,
          child: SaleInvoiceStatusBadge(status: invoice.status),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(invoice.amount)),
        ),
        _TableCell(
          width: _balanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(invoice.balance)),
        ),
        _TableCell(
          width: _actionsColWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => debugPrint('Print ${invoice.invoiceNo}'),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Print',
              ),
              IconButton(
                onPressed: () => debugPrint('Share ${invoice.invoiceNo}'),
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Share',
              ),
              IconButton(
                onPressed: () => debugPrint('More ${invoice.invoiceNo}'),
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
            alignment: Alignment.centerRight,
            child: Text('Amount', style: _headerStyle),
          ),
          _TableCell(
            width: _balanceColWidth,
            alignment: Alignment.centerRight,
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

class _TransactionTypeLabel extends StatelessWidget {
  const _TransactionTypeLabel({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor) = switch (type.toLowerCase()) {
      'sale' => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      'purchase' => (const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      _ => (const Color(0xFFF5F5F5), AppColors.textPrimary),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
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

class _PaginationRow extends ConsumerWidget {
  const _PaginationRow({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtersNotifier = ref.read(saleInvoiceFiltersProvider.notifier);
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
