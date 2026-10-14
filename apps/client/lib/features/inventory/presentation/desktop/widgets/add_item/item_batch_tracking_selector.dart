import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:flutter/material.dart';

/// Batch tracking toggle on add/edit item (Vyapar-style), shown when configured in item settings.
class ItemBatchTrackingSelector extends StatelessWidget {
  const ItemBatchTrackingSelector({
    required this.enabled,
    required this.onEnabledChanged,
    required this.onClearTracking,
    super.key,
  });

  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onClearTracking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: enabled,
            onChanged: (_) => onEnabledChanged(true),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            'Batch Tracking',
            style: AppTypography.inter(
              fontSize: AppTypography.bodyMediumSize,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          SettingsInfoHoverIcon(
            heading: 'Batch Tracking',
            sections: ItemSettingsInfoCatalog.sectionsFor(
              ItemSettingsInfoKey.batchTracking,
            ),
          ),
          const Spacer(),
          if (enabled)
            TextButton(
              onPressed: onClearTracking,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Clear Tracking',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
