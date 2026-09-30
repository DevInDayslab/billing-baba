import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vyapar-style text link — camera / image-plus icon + label (no pill border).
class AddItemImageLinkButton extends StatelessWidget {
  const AddItemImageLinkButton({
    required this.itemType,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final ItemType itemType;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final label = itemType == ItemType.product
        ? 'Add Item Image'
        : 'Add Service Image';

    return TextButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(LucideIcons.imagePlus, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.primary.withValues(alpha: 0.45),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
