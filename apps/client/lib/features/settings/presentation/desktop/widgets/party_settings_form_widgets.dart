import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/models/party_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:flutter/material.dart';

/// Shared layout for party settings rows (checkbox + label + info).
abstract final class PartySettingsRowMetrics {
  static const double checkboxLeadingWidth = 42;
}

class PartySettingsCheckboxRow extends StatelessWidget {
  const PartySettingsCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.infoKey,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final PartySettingsInfoKey? infoKey;

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
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (infoKey != null)
            SettingsInfoHoverIcon(
              heading: label,
              sections: PartySettingsInfoCatalog.sectionsFor(infoKey!),
            ),
        ],
      ),
    );
  }
}

class PartySettingsSectionInfoIcon extends StatelessWidget {
  const PartySettingsSectionInfoIcon({
    required this.heading,
    required this.infoKey,
    super.key,
  });

  final String heading;
  final PartySettingsInfoKey infoKey;

  @override
  Widget build(BuildContext context) {
    return SettingsInfoHoverIcon(
      heading: heading,
      sections: PartySettingsInfoCatalog.sectionsFor(infoKey),
    );
  }
}
