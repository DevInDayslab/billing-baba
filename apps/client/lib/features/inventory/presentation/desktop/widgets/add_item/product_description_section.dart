import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';

/// Product Description tab — online catalog copy (separate from item description).
class ProductDescriptionSection extends StatelessWidget {
  const ProductDescriptionSection({
    required this.descriptionController,
    required this.onDescriptionChanged,
    super.key,
  });

  final TextEditingController descriptionController;
  final ValueChanged<String> onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    return FormGrid(
      rowGap: 12,
      cells: [
        FormGridCell(
          span: 12,
          child: AppFormField(
            label: 'Product Description',
            floatingLabel: true,
            child: TextField(
              controller: descriptionController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(
                labelText: 'Product Description',
                hint: 'Description shown on your online store',
              ),
              minLines: 4,
              maxLines: 8,
              onChanged: onDescriptionChanged,
            ),
          ),
        ),
      ],
    );
  }
}
