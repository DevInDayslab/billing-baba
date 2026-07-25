import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Online Store tab — flat grid matching the general information field style.
class OnlineStoreSection extends StatelessWidget {
  const OnlineStoreSection({
    required this.itemType,
    required this.priceController,
    required this.descriptionController,
    required this.onPriceChanged,
    required this.onDescriptionChanged,
    this.decimalInputFormatter,
    super.key,
  });

  final ItemType itemType;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final ValueChanged<double> onPriceChanged;
  final ValueChanged<String> onDescriptionChanged;
  final TextInputFormatter? decimalInputFormatter;

  static final _defaultDecimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  bool get _isProduct => itemType == ItemType.product;

  @override
  Widget build(BuildContext context) {
    final priceLabel = _isProduct
        ? 'Online Store Price'
        : 'Online Service Price';

    return FormGrid(
      cells: [
        FormGridCell(
          span: _isProduct ? 3 : 4,
          child: AppFormField(
            label: priceLabel,
            child: TextField(
              controller: priceController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(hint: priceLabel),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                decimalInputFormatter ?? _defaultDecimalFormatter,
              ],
              onChanged: (v) => onPriceChanged(double.tryParse(v) ?? 0),
            ),
          ),
        ),
        FormGridCell(
          span: _isProduct ? 9 : 8,
          child: AppFormField(
            label: 'Online Description',
            child: TextField(
              controller: descriptionController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(
                hint: 'Description shown on online store',
              ),
              onChanged: onDescriptionChanged,
            ),
          ),
        ),
      ],
    );
  }
}
