import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/models/transaction_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:flutter/material.dart';

class TransactionSettingsCheckboxRow extends StatelessWidget {
  const TransactionSettingsCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.infoKey,
    this.linkLabel,
    this.onLinkTap,
    this.showLink = true,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final TransactionSettingsInfoKey? infoKey;
  /// Optional action shown indented under this row (e.g. Set Payment Terms).
  final String? linkLabel;
  final VoidCallback? onLinkTap;
  /// When false, hides [linkLabel] even if set (e.g. gate on checkbox value).
  final bool showLink;

  static const _linkIndent = 40.0;

  @override
  Widget build(BuildContext context) {
    final showNestedLink =
        linkLabel != null && onLinkTap != null && showLink;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodyMediumSize,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (infoKey != null)
                SettingsInfoHoverIcon(
                  heading: label,
                  sections: TransactionSettingsInfoCatalog.sectionsFor(infoKey!),
                ),
            ],
          ),
          if (showNestedLink)
            Padding(
              padding: const EdgeInsets.only(left: _linkIndent, bottom: 2),
              child: TransactionSettingsLinkButton(
                label: linkLabel!,
                onTap: onLinkTap!,
              ),
            ),
        ],
      ),
    );
  }
}

class TransactionSettingsLinkButton extends StatelessWidget {
  const TransactionSettingsLinkButton({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySmallSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
