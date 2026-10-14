import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_line_items_list.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_document_visibility.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_item_picker_sheet.dart';
import 'package:billing_baba/shared/business/business_amount_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Display model for a confirmed line on mobile document forms.
class MobileDocumentLineDisplay {
  const MobileDocumentLineDisplay({
    required this.name,
    required this.qtyLabel,
    required this.amountLabel,
    this.subtitle,
  });

  final String name;
  final String qtyLabel;
  final String amountLabel;
  final String? subtitle;
}

/// Items add row + line list. Reuses [showMobileItemPickerSheet].
class MobileDocumentItemsSection extends StatelessWidget {
  const MobileDocumentItemsSection({
    required this.visibility,
    required this.lines,
    required this.onAddItems,
    required this.onRemoveLine,
    super.key,
    this.onScan,
    this.onLineTap,
  });

  final MobileDocumentVisibility visibility;
  final List<MobileDocumentLineDisplay> lines;
  final VoidCallback onAddItems;
  final ValueChanged<int> onRemoveLine;
  final VoidCallback? onScan;
  final ValueChanged<int>? onLineTap;

  static String formatAmount(WidgetRef ref, double amount) {
    return ref.read(businessAmountFormatterProvider).format(amount).trim();
  }

  @override
  Widget build(BuildContext context) {
    if (!visibility.showItems) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (visibility.showBarcodeScan && onScan != null)
          MobileSaleAddItemsRow(
            onAddItems: onAddItems,
            onScan: onScan!,
          )
        else
          _AddItemsOnlyButton(onAddItems: onAddItems),
        if (lines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: onLineTap == null ? null : () => onLineTap!(i),
              borderRadius: AppRadius.mdBorder,
              child: MobileTransactionLineTile(
                name: lines[i].name,
                qtyLabel: lines[i].qtyLabel,
                amountLabel: lines[i].amountLabel,
                subtitle: lines[i].subtitle,
                onRemove: () => onRemoveLine(i),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _AddItemsOnlyButton extends StatelessWidget {
  const _AddItemsOnlyButton({required this.onAddItems});

  final VoidCallback onAddItems;

  static const _fieldBorder = Color(0xFFE0E0E0);
  static const _saveBlue = Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        onTap: onAddItems,
        borderRadius: AppRadius.mdBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: _fieldBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _saveBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.plus,
                  color: _saveBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Add Items',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience wrapper that opens the shared item picker.
Future<MobileItemPickResult?> pickMobileDocumentItem(BuildContext context) {
  return showMobileItemPickerSheet(context);
}
