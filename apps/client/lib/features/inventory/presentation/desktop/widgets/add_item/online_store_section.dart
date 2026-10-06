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
    required this.onPriceChanged,
    this.descriptionController,
    this.onDescriptionChanged,
    this.decimalInputFormatter,
    super.key,
  });

  final ItemType itemType;
  final TextEditingController priceController;
  final ValueChanged<double> onPriceChanged;
  final TextEditingController? descriptionController;
  final ValueChanged<String>? onDescriptionChanged;
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

    final cells = <FormGridCell>[
      FormGridCell(
        span: _isProduct ? 3 : 4,
        child: AppFormField(
          label: priceLabel,
          floatingLabel: true,
          child: TextField(
            controller: priceController,
            style: saleFieldTextStyle,
            decoration: buildFormControlDecoration(labelText: priceLabel),
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
    ];

    if (!_isProduct &&
        descriptionController != null &&
        onDescriptionChanged != null) {
      cells.add(
        FormGridCell(
          span: 8,
          child: AppFormField(
            label: 'Online Service Description',
            floatingLabel: true,
            child: TextField(
              controller: descriptionController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(
                labelText: 'Online Service Description',
                hint: 'Description shown on online store',
              ),
              minLines: 3,
              maxLines: 6,
              onChanged: onDescriptionChanged,
            ),
          ),
        ),
      );
    }

    return FormGrid(
      rowGap: 12,
      cells: cells,
    );
  }
}
