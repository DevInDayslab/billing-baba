import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

const _fieldBorder = Color(0xFFE0E0E0);
const _creditGreen = Color(0xFF43A047);
const _saveBlue = AppColors.primary;
const _toggleTrack = Color(0xFFF0F0F0);

/// Credit / Cash segmented toggle in the sale form app bar.
class MobileSaleTypeToggle extends StatelessWidget {
  const MobileSaleTypeToggle({
    required this.saleType,
    required this.onChanged,
    super.key,
  });

  final SaleType saleType;
  final ValueChanged<SaleType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _toggleTrack,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TogglePill(
            label: 'Credit',
            isActive: saleType == SaleType.credit,
            activeColor: _creditGreen,
            onTap: () => onChanged(SaleType.credit),
          ),
          _TogglePill(
            label: 'Cash',
            isActive: saleType == SaleType.cash,
            activeColor: AppColors.primary,
            onTap: () => onChanged(SaleType.cash),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Labeled text field used across the mobile sale form.
class MobileSaleFormField extends StatelessWidget {
  const MobileSaleFormField({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.isRequired = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.hasError = false,
    this.errorText,
    this.minLines = 1,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final bool isRequired;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool hasError;
  final String? errorText;
  final int minLines;
  final int maxLines;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = hasError ? AppColors.error : _fieldBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          autofocus: autofocus,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          minLines: minLines,
          maxLines: maxLines,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.55),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(
                color: hasError ? AppColors.error : _saveBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

/// Tappable picker row with label and chevron (invoice no, date, time, etc.).
class MobileSalePickerField extends StatelessWidget {
  const MobileSalePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
    this.isPlaceholder = false,
    this.trailingIcon = LucideIcons.chevronDown,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isPlaceholder;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBorder,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdBorder,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdBorder,
                border: Border.all(color: _fieldBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isPlaceholder
                            ? AppColors.textSecondary.withValues(alpha: 0.55)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    trailingIcon,
                    size: AppIconSize.md,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Add Items row with optional scanner button.
class MobileSaleAddItemsRow extends StatelessWidget {
  const MobileSaleAddItemsRow({
    required this.onAddItems,
    required this.onScan,
    super.key,
  });

  final VoidCallback onAddItems;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Material(
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
                      'Add Items (Optional)',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Material(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBorder,
          child: InkWell(
            onTap: onScan,
            borderRadius: AppRadius.mdBorder,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdBorder,
                border: Border.all(color: _fieldBorder),
              ),
              child: const Icon(
                LucideIcons.scanBarcode,
                color: _saveBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Total amount display row.
class MobileSaleTotalRow extends StatelessWidget {
  const MobileSaleTotalRow({required this.amountLabel, super.key});

  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _fieldBorder),
      ),
      child: Row(
        children: [
          Text(
            'Total Amount',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '₹',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              amountLabel,
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: amountLabel == '—'
                    ? AppColors.textSecondary.withValues(alpha: 0.4)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom action bar: Save & New, Save, more options.
class MobileSaleBottomBar extends StatelessWidget {
  const MobileSaleBottomBar({
    required this.onSave,
    required this.onMore,
    super.key,
    this.onSaveAndNew,
    this.isSaving = false,
  });

  final VoidCallback? onSave;
  final VoidCallback? onSaveAndNew;
  final VoidCallback onMore;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (onSaveAndNew != null) ...[
              Expanded(
                child: TextButton(
                  onPressed: isSaving ? null : onSaveAndNew,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdBorder,
                    ),
                  ),
                  child: Text(
                    'Save & New',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: FilledButton(
                onPressed: isSaving ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: _saveBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
            IconButton(
              onPressed: isSaving ? null : onMore,
              icon: const Icon(LucideIcons.ellipsisVertical),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
