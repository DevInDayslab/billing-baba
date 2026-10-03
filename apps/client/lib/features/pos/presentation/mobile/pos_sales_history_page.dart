import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/presentation/pos_return_page.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class MobilePosSalesHistoryPage extends ConsumerWidget {
  const MobilePosSalesHistoryPage({super.key});

  static final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(posSalesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'POS sales history',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: salesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppError(
          message: OfflineUiMessages.messageFor(error),
          onRetry: () => ref.invalidate(posSalesListProvider),
        ),
        data: (sales) {
          if (sales.isEmpty) {
            return const Center(
              child: Text(
                'No POS sales yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(posSalesListProvider);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: sales.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final sale = sales[index];
                return _SaleTile(
                  sale: sale,
                  onTap: () => _openSaleActions(context, sale),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openSaleActions(BuildContext context, PosSale sale) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.undo2),
              title: const Text('Process return'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PosReturnPage(originalSale: sale),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  const _SaleTile({required this.sale, required this.onTap});

  final PosSale sale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          sale.docNumber,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          MobilePosSalesHistoryPage._dateFormat.format(sale.completedAt),
          style: AppTypography.inter(
            fontSize: AppTypography.captionSize,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          MobilePosSalesHistoryPage._currencyFormat.format(sale.finalAmount),
          style: AppTypography.inter(
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
