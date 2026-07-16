import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_receipt_printer.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/presentation/pages/pos_return_page.dart';
import 'package:billing_baba/features/pos/presentation/widgets/receipt_view_widget.dart';
import 'package:billing_baba/features/pos/providers/pos_sales_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _posAccent = Color(0xFF00897B);
const _posCircle = Color(0xFFE0F2F1);

/// Full-page list of completed POS sales from local SQLite.
class PosSalesHistoryPage extends ConsumerWidget {
  const PosSalesHistoryPage({super.key});

  static final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  Future<void> _printReceipt(
    BuildContext context,
    WidgetRef ref,
    PosSale sale,
  ) async {
    try {
      await ref
          .read(posReceiptPrinterProvider)
          .preview(
            context: context,
            sale: sale,
            ref: ref,
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $error')),
      );
    }
  }

  Future<void> _showReceipt(BuildContext context, PosSale sale) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: ReceiptViewWidget(sale: sale),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(posSalesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: salesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
        data: (sales) {
          if (sales.isEmpty) {
            return const Center(
              child: Text(
                'No sales yet',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sales.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final sale = sales[index];
              return Material(
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _showReceipt(context, sale),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _posCircle,
                            borderRadius: AppRadius.smBorder,
                          ),
                          child: const Icon(
                            Icons.receipt_outlined,
                            color: _posAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sale.docNumber,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${sale.itemCount} item${sale.itemCount == 1 ? '' : 's'} · ${_dateFormat.format(sale.completedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _currencyFormat.format(sale.finalAmount),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          icon: const Icon(Icons.print_outlined, size: 20),
                          color: AppColors.textSecondary,
                          tooltip: 'Reprint',
                          onPressed: () => _printReceipt(context, ref, sale),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo, size: 20),
                          color: _posAccent,
                          tooltip: 'Return',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    PosReturnPage(originalSale: sale),
                              ),
                            );
                          },
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
