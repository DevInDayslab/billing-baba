import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_receipt_printer.dart';
import 'package:billing_baba/features/pos/application/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/receipt_view_widget.dart';
import 'package:billing_baba/features/pos/presentation/pos_return_page.dart';
import 'package:billing_baba/shared/utils/output_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _posAccent = Color(0xFF00897B);
const _posCircle = Color(0xFFE0F2F1);
const _rowBorder = Color(0xFFE8E8E8);
const _expandedBackground = Color(0xFFF7F8FA);

/// Embedded sales history list (no [Scaffold] / app bar).
class PosSalesHistoryPanel extends ConsumerWidget {
  const PosSalesHistoryPanel({super.key});

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
        SnackBar(content: Text(OutputErrorMapper.printMessage(error))),
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

    return salesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            OfflineUiMessages.messageFor(error),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          itemCount: sales.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final sale = sales[index];
            return _PosSalesHistorySaleRow(
              sale: sale,
              dateFormat: _dateFormat,
              currencyFormat: _currencyFormat,
              onOpenReceipt: () => _showReceipt(context, sale),
              onPrint: () => _printReceipt(context, ref, sale),
              onReturn: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PosReturnPage(originalSale: sale),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PosSalesHistorySaleRow extends StatefulWidget {
  const _PosSalesHistorySaleRow({
    required this.sale,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onOpenReceipt,
    required this.onPrint,
    required this.onReturn,
  });

  final PosSale sale;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onOpenReceipt;
  final VoidCallback onPrint;
  final VoidCallback onReturn;

  @override
  State<_PosSalesHistorySaleRow> createState() => _PosSalesHistorySaleRowState();
}

class _PosSalesHistorySaleRowState extends State<_PosSalesHistorySaleRow> {
  var _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: _rowBorder),
          borderRadius: AppRadius.mdBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                right: AppSpacing.xs,
                top: AppSpacing.sm,
                bottom: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 22,
                    ),
                    color: AppColors.textSecondary,
                    tooltip: _expanded ? 'Hide items' : 'Show items',
                    onPressed: _toggleExpanded,
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onOpenReceipt,
                        borderRadius: AppRadius.smBorder,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                            horizontal: AppSpacing.xs,
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
                                      '${sale.itemCount} item${sale.itemCount == 1 ? '' : 's'} · ${widget.dateFormat.format(sale.completedAt)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                widget.currencyFormat.format(sale.finalAmount),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.print_outlined, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: 'Reprint',
                    onPressed: widget.onPrint,
                  ),
                  IconButton(
                    icon: const Icon(Icons.undo, size: 20),
                    color: _posAccent,
                    tooltip: 'Return',
                    onPressed: widget.onReturn,
                  ),
                ],
              ),
            ),
            if (_expanded)
              _PosSalesHistoryLineItemsTable(
                items: sale.items,
                currencyFormat: widget.currencyFormat,
              ),
          ],
        ),
      ),
    );
  }
}

class _PosSalesHistoryLineItemsTable extends StatelessWidget {
  const _PosSalesHistoryLineItemsTable({
    required this.items,
    required this.currencyFormat,
  });

  final List<PosSaleLineItem> items;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Text(
          'No line items recorded for this bill.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    return ColoredBox(
      color: _expandedBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _rowBorder)),
              ),
              children: [
                _headerCell('Item'),
                _headerCell('Qty', align: TextAlign.center),
                _headerCell('Rate', align: TextAlign.end),
                _headerCell('Amount', align: TextAlign.end),
              ],
            ),
            for (final line in items)
              TableRow(
                children: [
                  _bodyCell(line.name),
                  _bodyCell(
                    '${line.quantity}',
                    align: TextAlign.center,
                  ),
                  _bodyCell(
                    currencyFormat.format(_rateFor(line)),
                    align: TextAlign.end,
                  ),
                  _bodyCell(
                    currencyFormat.format(line.lineTotal),
                    align: TextAlign.end,
                    bold: true,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static double _rateFor(PosSaleLineItem line) {
    if (line.unitPrice != null) return line.unitPrice!;
    if (line.quantity <= 0) return line.lineTotal;
    return line.lineTotal / line.quantity;
  }

  static Widget _headerCell(String label, {TextAlign align = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  static Widget _bodyCell(
    String label, {
    TextAlign align = TextAlign.start,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm + 2,
      ),
      child: Text(
        label,
        textAlign: align,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
