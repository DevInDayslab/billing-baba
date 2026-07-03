import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

const _dateColWidth = 100.0;
const _invoiceColWidth = 130.0;
const _transactionColWidth = 110.0;
const _paymentColWidth = 110.0;
const _statusColWidth = 100.0;
const _amountColWidth = 100.0;
const _balanceColWidth = 90.0;
const _actionsColWidth = 120.0;
const _partyColumnMinWidth = 140.0;
const double _fixedColumnsWidth =
    _dateColWidth +
    _invoiceColWidth +
    _transactionColWidth +
    _paymentColWidth +
    _statusColWidth +
    _amountColWidth +
    _balanceColWidth +
    _actionsColWidth;

class SaleReportTransactionsTable extends StatelessWidget {
  const SaleReportTransactionsTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Search',
                ),
                _XlsChip(onTap: () {}),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.print_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Print',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          const _TableHeaderRow(),
          const Divider(height: 1, color: _cardBorder),
          _TableDataRow(
            children: [
              _TableCell(
                width: _dateColWidth,
                child: Text(_dateFormat.format(DateTime(2026, 4, 4))),
              ),
              const _TableCell(
                width: _invoiceColWidth,
                child: Text('1773124034247'),
              ),
              const Expanded(
                child: _TableCell(child: Text('PartyAv')),
              ),
              const _TableCell(
                width: _transactionColWidth,
                child: Text('Sale'),
              ),
              const _TableCell(
                width: _paymentColWidth,
                child: Text('Cash'),
              ),
              const _TableCell(
                width: _statusColWidth,
                child: SaleInvoiceStatusBadge(
                  status: SaleInvoiceStatus.cancelled,
                ),
              ),
              _TableCell(
                width: _amountColWidth,
                alignment: Alignment.centerRight,
                child: Text(_currencyFormat.format(297)),
              ),
              _TableCell(
                width: _balanceColWidth,
                alignment: Alignment.centerRight,
                child: Text(_currencyFormat.format(297)),
              ),
              _TableCell(
                width: _actionsColWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.print_outlined, size: 18),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined, size: 18),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, size: 18),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    return Material(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'xls',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ),
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
      child: const _ScrollableTableRow(
        child: Row(
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
        child: _ScrollableTableRow(child: Row(children: children)),
      ),
    );
  }
}

class _ScrollableTableRow extends StatelessWidget {
  const _ScrollableTableRow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minTableWidth = _fixedColumnsWidth + _partyColumnMinWidth;
        final tableWidth = constraints.maxWidth.isFinite
            ? math.max(constraints.maxWidth, minTableWidth)
            : minTableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: child,
          ),
        );
      },
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
