import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/payment_out_status_badge.dart';
import 'package:billing_baba/features/purchases/providers/payment_out_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _emptyStateRed = Color(0xFFD32F2F);

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

class PaymentOutTable extends ConsumerWidget {
  const PaymentOutTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentOutRecordsProvider);
    final paginated = ref.watch(paginatedPaymentOutRecordsProvider);
    final notifier = ref.read(paymentOutRecordsProvider.notifier);

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
                IconButton(
                  onPressed: () => debugPrint('Export xls tapped'),
                  icon: const Icon(Icons.table_chart_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Excel Report',
                ),
                IconButton(
                  onPressed: () => debugPrint('Print tapped'),
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
          const Divider(height: 1, color: _cardBorder),
          paymentsAsync.when(
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
            data: (_) {
              if (paginated.items.isEmpty) {
                return const _EmptyState();
              }
              return LayoutBuilder(
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

  Widget _buildRow(PaymentOutModel record) {
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
            _currencyFormat.format(record.paidAmount),
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
          child: PaymentOutStatusBadge(status: record.status),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl * 2,
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 40,
            color: _emptyStateRed.withValues(alpha: 0.85),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No Transaction Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'We could not find any transactions.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
      child: const Row(
        children: [
          _TableCell(
            width: _dateColWidth,
            child: Text('Date', style: _headerStyle),
          ),
          _TableCell(
            width: _refColWidth,
            child: Text('Ref. no.', style: _headerStyle),
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
            child: Text('Paid', style: _headerStyle),
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
    final filtersNotifier = ref.read(paymentOutFiltersProvider.notifier);
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
