import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/payment_in_status_badge.dart';
import 'package:billing_baba/features/sales/providers/payment_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

const _dateColWidth = 140.0;
const _refColWidth = 140.0;
const _paymentColWidth = 130.0;
const _statusColWidth = 80.0;
const _amountColWidth = 140.0;
const _actionsColWidth = 48.0;
const _colGap = 12.0;

const double _minTableWidth =
    _dateColWidth +
    _refColWidth +
    _paymentColWidth +
    _statusColWidth +
    _amountColWidth * 2 +
    _actionsColWidth +
    _colGap * 6 +
    160;

class PaymentInTable extends ConsumerWidget {
  const PaymentInTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPaymentInRecordsProvider);

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
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          if (paginated.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No payment records found',
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
          const Divider(height: 1, color: _cardBorder),
          _PaginationRow(
            currentPage: paginated.currentPage,
            totalPages: paginated.totalPages,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(PaymentInModel record) {
    return _TableDataRow(
      children: [
        _TableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(record.date)),
        ),
        _TableCell(
          width: _refColWidth,
          child: Text(record.receiptNo),
        ),
        Expanded(
          child: _TableCell(
            child: Text(
              record.partyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.totalAmount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(record.receivedAmount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _paymentColWidth,
          child: Text(
            record.paymentType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _TableCell(
          width: _statusColWidth,
          child: PaymentInStatusBadge(status: record.status),
        ),
        _TableCell(
          width: _actionsColWidth,
          gapAfter: 0,
          child: IconButton(
            onPressed: () => debugPrint('More ${record.receiptNo}'),
            icon: const Icon(Icons.more_vert, size: 18),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'More',
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
            width: _refColWidth,
            child: Text('Ref. No.', style: _headerStyle),
          ),
          Expanded(
            child: _TableCell(child: Text('Party Name', style: _headerStyle)),
          ),
          _TableCell(
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            child: Text('Total Amount', style: _headerStyle),
          ),
          _TableCell(
            width: _amountColWidth,
            alignment: Alignment.centerRight,
            child: Text('Received', style: _headerStyle),
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
    final filtersNotifier = ref.read(paymentInFiltersProvider.notifier);
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
