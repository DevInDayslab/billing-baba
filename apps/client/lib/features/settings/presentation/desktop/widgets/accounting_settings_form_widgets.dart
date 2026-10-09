import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/models/accounting_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/party_settings_form_widgets.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:flutter/material.dart';

class AccountingSettingsCheckboxRow extends StatelessWidget {
  const AccountingSettingsCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.infoKey,
    this.muted = false,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final AccountingSettingsInfoKey? infoKey;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: PartySettingsRowMetrics.checkboxLeadingWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: AppTypography.bodyMediumSize,
                color: muted ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
          if (infoKey != null)
            SettingsInfoHoverIcon(
              heading: label,
              sections: AccountingSettingsInfoCatalog.sectionsFor(infoKey!),
            ),
        ],
      ),
    );
  }
}
