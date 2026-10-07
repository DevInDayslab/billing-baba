import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Review and edit OCR fields before applying to Add Purchase.
Future<PurchaseDocumentParseDto?> showPurchaseDocumentReviewDialog(
  BuildContext context, {
  required PurchaseDocumentParseDto parsed,
}) {
  return showDialog<PurchaseDocumentParseDto>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PurchaseDocumentReviewDialog(parsed: parsed),
  );
}

class _PurchaseDocumentReviewDialog extends StatefulWidget {
  const _PurchaseDocumentReviewDialog({required this.parsed});

  final PurchaseDocumentParseDto parsed;

  @override
  State<_PurchaseDocumentReviewDialog> createState() =>
      _PurchaseDocumentReviewDialogState();
}

class _PurchaseDocumentReviewDialogState
    extends State<_PurchaseDocumentReviewDialog> {
  late final TextEditingController _vendorController;
  late final TextEditingController _invoiceController;
  late final TextEditingController _invoiceDateController;
  late final TextEditingController _gstinController;
  late final List<_ReviewLineState> _lines;

  @override
  void initState() {
    super.initState();
    final parsed = widget.parsed;
    _vendorController = TextEditingController(text: parsed.vendorName ?? '');
    _invoiceController = TextEditingController(
      text: parsed.invoiceNumber ?? parsed.supplierInvoiceNumber ?? '',
    );
    _invoiceDateController = TextEditingController(
      text: parsed.invoiceDate ?? '',
    );
    _gstinController = TextEditingController(text: parsed.gstin ?? '');
    _lines = [
      for (final line in parsed.lines) _ReviewLineState.fromDto(line),
    ];
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _invoiceController.dispose();
    _invoiceDateController.dispose();
    _gstinController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  PurchaseDocumentParseDto _buildResult() {
    return PurchaseDocumentParseDto(
      vendorName: _nullableText(_vendorController.text),
      gstin: _nullableText(_gstinController.text),
      invoiceNumber: _nullableText(_invoiceController.text),
      supplierInvoiceNumber: _nullableText(_invoiceController.text),
      invoiceDate: _nullableText(_invoiceDateController.text),
      dueDate: widget.parsed.dueDate,
      stateOfSupply: widget.parsed.stateOfSupply,
      eWayBillNumber: widget.parsed.eWayBillNumber,
      paymentMode: widget.parsed.paymentMode,
      paymentAmount: widget.parsed.paymentAmount,
      notes: widget.parsed.notes,
      termsNotes: widget.parsed.termsNotes,
      subtotal: widget.parsed.subtotal,
      discountTotal: widget.parsed.discountTotal,
      taxAmount: widget.parsed.taxAmount,
      totalAmount: widget.parsed.totalAmount,
      partyId: widget.parsed.partyId,
      lines: _lines.map((line) => line.toDto()).toList(),
    );
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.92;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth.clamp(360, 920),
          maxHeight: maxHeight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Review purchase bill',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Cancel',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Seller / party',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ReviewField(
                      label: 'Vendor name',
                      controller: _vendorController,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ReviewField(
                      label: 'GSTIN',
                      controller: _gstinController,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Invoice',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ReviewField(
                      label: 'Invoice number',
                      controller: _invoiceController,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ReviewField(
                      label: 'Invoice date (YYYY-MM-DD)',
                      controller: _invoiceDateController,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Line items',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_lines.isEmpty)
                      const Text(
                        'No line items were detected on this bill.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      ..._lines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _ReviewLineCard(line: line),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () {
                      if (_lines.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Add at least one line item or cancel import.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).pop(_buildResult());
                    },
                    child: const Text('Confirm & continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewLineState {
  _ReviewLineState({
    required this.nameController,
    required this.qtyController,
    required this.priceController,
    required this.taxRateController,
    required this.discountController,
    this.taxInclusive,
  });

  factory _ReviewLineState.fromDto(PurchaseDocumentParseLineDto line) {
    return _ReviewLineState(
      nameController: TextEditingController(text: line.itemName ?? ''),
      qtyController: TextEditingController(
        text: line.quantity?.toString() ?? '1',
      ),
      priceController: TextEditingController(
        text: line.unitPrice?.toString() ?? '',
      ),
      taxRateController: TextEditingController(
        text: line.taxRate?.toString() ?? '',
      ),
      discountController: TextEditingController(
        text: line.discountAmount?.toString() ?? '',
      ),
      taxInclusive: line.taxInclusive,
    );
  }

  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final TextEditingController taxRateController;
  final TextEditingController discountController;
  bool? taxInclusive;

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    priceController.dispose();
    taxRateController.dispose();
    discountController.dispose();
  }

  PurchaseDocumentParseLineDto toDto() {
    return PurchaseDocumentParseLineDto(
      itemName: nameController.text.trim().isEmpty
          ? null
          : nameController.text.trim(),
      quantity: double.tryParse(qtyController.text.trim()),
      unitPrice: double.tryParse(priceController.text.trim()),
      taxRate: double.tryParse(taxRateController.text.trim()),
      discountAmount: double.tryParse(discountController.text.trim()),
      taxInclusive: taxInclusive,
      description: null,
      unit: null,
      taxAmount: null,
    );
  }
}

class _ReviewLineCard extends StatefulWidget {
  const _ReviewLineCard({required this.line});

  final _ReviewLineState line;

  @override
  State<_ReviewLineCard> createState() => _ReviewLineCardState();
}

class _ReviewLineCardState extends State<_ReviewLineCard> {
  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReviewField(label: 'Item name', controller: line.nameController),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _ReviewField(
                    label: 'Qty',
                    controller: line.qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ReviewField(
                    label: 'Unit price',
                    controller: line.priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _ReviewField(
                    label: 'Tax %',
                    controller: line.taxRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ReviewField(
                    label: 'Discount (line)',
                    controller: line.discountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Price includes tax'),
              value: line.taxInclusive ?? false,
              onChanged: (value) {
                setState(() => line.taxInclusive = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == null
          ? null
          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
