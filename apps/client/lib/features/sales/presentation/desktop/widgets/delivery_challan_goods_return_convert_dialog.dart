import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bill quantities per item when converting a delivery challan to sale.
typedef ChallanBillQtyByItemId = Map<String, double>;

Future<ChallanBillQtyByItemId?> showDeliveryChallanGoodsReturnConvertDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String challanDocumentId,
}) async {
  final service = await ref.read(salesServiceProvider.future);
  SalesDocumentDto document;
  try {
    document = await service.fetchDocument(challanDocumentId);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load challan: $error')),
      );
    }
    return null;
  }

  if (!context.mounted) return null;
  return showDialog<ChallanBillQtyByItemId>(
    context: context,
    builder: (context) => _DeliveryChallanGoodsReturnConvertDialog(
      document: document,
    ),
  );
}

class _DeliveryChallanGoodsReturnConvertDialog extends StatefulWidget {
  const _DeliveryChallanGoodsReturnConvertDialog({required this.document});

  final SalesDocumentDto document;

  @override
  State<_DeliveryChallanGoodsReturnConvertDialog> createState() =>
      _DeliveryChallanGoodsReturnConvertDialogState();
}

class _DeliveryChallanGoodsReturnConvertDialogState
    extends State<_DeliveryChallanGoodsReturnConvertDialog> {
  late final List<_LineRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.document.lines.map((line) {
      final qty = double.tryParse(line.quantity) ?? 0;
      return _LineRow(
        itemId: line.itemId,
        challanQty: qty,
        billQty: qty,
      );
    }).toList();
  }

  void _submit() {
    final result = <String, double>{};
    for (final row in _rows) {
      if (row.billQty < 0 || row.billQty > row.challanQty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bill quantity must be between 0 and challan quantity',
            ),
          ),
        );
        return;
      }
      result[row.itemId] = row.billQty;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convert to Sale'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter quantity to bill. Reduce for returned or undelivered items.',
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySmallSize,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < _rows.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Line ${i + 1}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _rows[i].challanQty.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 88,
                        child: TextFormField(
                          initialValue: _rows[i].billQty.toString(),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Bill qty',
                          ),
                          onChanged: (value) {
                            _rows[i].billQty = double.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Convert'),
        ),
      ],
    );
  }
}

class _LineRow {
  _LineRow({
    required this.itemId,
    required this.challanQty,
    required this.billQty,
  });

  final String itemId;
  final double challanQty;
  double billQty;
}
