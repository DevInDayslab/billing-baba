import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Field visibility for the shared mobile line-item editor.
///
/// Only enable fields that exist on the document's desktop line model.
class MobileDocumentLineEditFields {
  const MobileDocumentLineEditFields({
    this.showUnit = true,
    this.showDiscountPercent = false,
    this.showTaxPercent = true,
    this.showSerial = false,
    this.showBatch = false,
    this.showMrp = false,
    this.showDescription = true,
  });

  /// Sale / credit note / sale order / challan / estimate-proforma.
  static const sale = MobileDocumentLineEditFields(
    showDiscountPercent: true,
    showSerial: true,
    showBatch: true,
    showMrp: true,
  );

  /// Purchase / debit note / purchase order.
  static const purchase = MobileDocumentLineEditFields();

  /// Expense lines (no unit on model).
  static const expense = MobileDocumentLineEditFields(
    showUnit: false,
  );

  final bool showUnit;
  final bool showDiscountPercent;
  final bool showTaxPercent;
  final bool showSerial;
  final bool showBatch;
  final bool showMrp;
  final bool showDescription;
}

/// Editable draft returned by [showMobileDocumentLineEditSheet].
class MobileDocumentLineEditDraft {
  const MobileDocumentLineEditDraft({
    required this.qty,
    required this.unit,
    required this.pricePerUnit,
    this.discountPercent = 0,
    this.taxPercent = 0,
    this.serialNo = '',
    this.batchNo = '',
    this.mrp = 0,
    this.description = '',
  });

  final double qty;
  final String unit;
  final double pricePerUnit;
  final double discountPercent;
  final double taxPercent;
  final String serialNo;
  final String batchNo;
  final double mrp;
  final String description;
}

/// Opens a bottom sheet to edit line fields; returns updated draft or null.
Future<MobileDocumentLineEditDraft?> showMobileDocumentLineEditSheet({
  required BuildContext context,
  required String itemName,
  required MobileDocumentLineEditDraft initial,
  required MobileDocumentLineEditFields fields,
}) {
  return showMobileBottomSheet<MobileDocumentLineEditDraft>(
    context: context,
    title: itemName.isEmpty ? 'Edit Item' : itemName,
    heightFraction: 0.85,
    builder: (sheetContext) => _MobileDocumentLineEditBody(
      initial: initial,
      fields: fields,
    ),
  );
}

class _MobileDocumentLineEditBody extends StatefulWidget {
  const _MobileDocumentLineEditBody({
    required this.initial,
    required this.fields,
  });

  final MobileDocumentLineEditDraft initial;
  final MobileDocumentLineEditFields fields;

  @override
  State<_MobileDocumentLineEditBody> createState() =>
      _MobileDocumentLineEditBodyState();
}

class _MobileDocumentLineEditBodyState
    extends State<_MobileDocumentLineEditBody> {
  late final TextEditingController _qtyController;
  late final TextEditingController _rateController;
  late final TextEditingController _discountController;
  late final TextEditingController _taxController;
  late final TextEditingController _serialController;
  late final TextEditingController _batchController;
  late final TextEditingController _mrpController;
  late final TextEditingController _descriptionController;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _qtyController = TextEditingController(text: _formatNum(initial.qty));
    _rateController =
        TextEditingController(text: _formatNum(initial.pricePerUnit));
    _discountController =
        TextEditingController(text: _formatNum(initial.discountPercent));
    _taxController =
        TextEditingController(text: _formatNum(initial.taxPercent));
    _serialController = TextEditingController(text: initial.serialNo);
    _batchController = TextEditingController(text: initial.batchNo);
    _mrpController = TextEditingController(text: _formatNum(initial.mrp));
    _descriptionController = TextEditingController(text: initial.description);
    _unit = initial.unit.isEmpty ? 'NONE' : initial.unit;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _serialController.dispose();
    _batchController.dispose();
    _mrpController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  static String _formatNum(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  double _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  void _apply() {
    Navigator.of(context).pop(
      MobileDocumentLineEditDraft(
        qty: _parse(_qtyController),
        unit: _unit,
        pricePerUnit: _parse(_rateController),
        discountPercent: _parse(_discountController),
        taxPercent: _parse(_taxController),
        serialNo: _serialController.text.trim(),
        batchNo: _batchController.text.trim(),
        mrp: _parse(_mrpController),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.fields;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileSaleFormField(
          label: 'Quantity',
          controller: _qtyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
          ],
        ),
        if (fields.showUnit) ...[
          const SizedBox(height: AppSpacing.md),
          MobileSalePickerField(
            label: 'Unit',
            value: _unit,
            onTap: () async {
              final selected = await showMobileOptionSheet<String>(
                context: context,
                title: 'Unit',
                selected: _unit,
                options: [
                  for (final unit in SaleDropdownOptions.units)
                    MobileOption(value: unit, label: unit),
                ],
              );
              if (selected != null) setState(() => _unit = selected);
            },
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        MobileSaleFormField(
          label: 'Rate',
          controller: _rateController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
          ],
        ),
        if (fields.showDiscountPercent) ...[
          const SizedBox(height: AppSpacing.md),
          MobileSaleFormField(
            label: 'Discount %',
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
            ],
          ),
        ],
        if (fields.showTaxPercent) ...[
          const SizedBox(height: AppSpacing.md),
          MobileSaleFormField(
            label: 'Tax %',
            controller: _taxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
            ],
          ),
        ],
        if (fields.showSerial) ...[
          const SizedBox(height: AppSpacing.md),
          MobileSaleFormField(
            label: 'Serial No',
            controller: _serialController,
          ),
        ],
        if (fields.showBatch) ...[
          const SizedBox(height: AppSpacing.md),
          MobileSaleFormField(
            label: 'Batch No',
            controller: _batchController,
          ),
        ],
        if (fields.showMrp) ...[
          const SizedBox(height: AppSpacing.md),
          MobileSaleFormField(
            label: 'MRP',
            controller: _mrpController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
            ],
          ),
        ],
        if (fields.showDescription) ...[
          const SizedBox(height: AppSpacing.md),
          MobileSaleFormField(
            label: 'Description',
            controller: _descriptionController,
            maxLines: 3,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: _apply,
          child: const Text('Apply'),
        ),
        SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
      ],
    );
  }
}
