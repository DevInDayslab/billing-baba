import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const salesCardBorder = Color(0xFFE0E0E0);
const salesTableColGap = 12.0;

class SalesLoadingState extends StatelessWidget {
  const SalesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class SalesErrorState extends StatelessWidget {
  const SalesErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class SalesEmptyListState extends StatelessWidget {
  const SalesEmptyListState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class SalesXlsChip extends StatelessWidget {
  const SalesXlsChip({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: salesCardBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 16,
              color: Color(0xFF2E7D32),
            ),
            SizedBox(width: 4),
            Text(
              'XLS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesPaginationRow extends ConsumerWidget {
  const SalesPaginationRow({
    required this.scope,
    super.key,
  });

  final SalesDocumentListScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedSalesDocumentsProvider(scope));
    final filters = ref.watch(salesDocumentFiltersProvider(scope));
    final filtersNotifier = ref.read(
      salesDocumentFiltersProvider(scope).notifier,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Page ${paginated.currentPage} of ${paginated.totalPages}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: filters.currentPage > 1
                ? () => filtersNotifier.setPage(filters.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
          ),
          IconButton(
            onPressed: filters.currentPage < paginated.totalPages
                ? () => filtersNotifier.setPage(filters.currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}

class SalesTableHeaderCell extends StatelessWidget {
  const SalesTableHeaderCell({
    required this.label,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.gapAfter = salesTableColGap,
    super.key,
  });

  final String label;
  final double? width;
  final Alignment alignment;
  final double gapAfter;

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  @override
  Widget build(BuildContext context) {
    return SalesTableCell(
      width: width,
      alignment: alignment,
      gapAfter: gapAfter,
      child: Text(label, style: _headerStyle),
    );
  }
}

class SalesTableDataRow extends StatelessWidget {
  const SalesTableDataRow({required this.children, super.key});

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

class SalesTableCell extends StatelessWidget {
  const SalesTableCell({
    required this.child,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.gapAfter = salesTableColGap,
    super.key,
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
