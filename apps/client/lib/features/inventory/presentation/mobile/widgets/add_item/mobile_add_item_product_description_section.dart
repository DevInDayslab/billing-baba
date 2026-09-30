import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:flutter/material.dart';

/// Product Description tab for mobile Add Item (online store catalog copy).
class MobileAddItemProductDescriptionSection extends StatelessWidget {
  const MobileAddItemProductDescriptionSection({
    required this.descriptionController,
    required this.onDescriptionChanged,
    super.key,
  });

  final TextEditingController descriptionController;
  final ValueChanged<String> onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MobileAddItemTheme.horizontalPadding,
          16,
          MobileAddItemTheme.horizontalPadding,
          16,
        ),
        child: MobileAddItemField(
          controller: descriptionController,
          label: 'Product Description',
          hint: 'Description shown on your online store',
          maxLines: 6,
          onChanged: onDescriptionChanged,
          suffixIcon: Align(
            alignment: Alignment.bottomRight,
            widthFactor: 1,
            heightFactor: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 4),
              child: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
