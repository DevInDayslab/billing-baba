import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';

/// Placeholder body for settings screens that are not yet implemented on mobile.
class MobileSettingsPlaceholderBody extends StatelessWidget {
  const MobileSettingsPlaceholderBody({
    required this.title,
    super.key,
    this.message,
  });

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return MobileEmptyState(
      title: '$title coming soon',
      message: message ?? 'This setting will be available in a future update.',
      icon: Icons.construction_outlined,
    );
  }
}

/// Simple grouped switch row used inside settings detail pages.
class MobileSettingsSwitchTile extends StatelessWidget {
  const MobileSettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MobileCard(
      padding: EdgeInsets.zero,
      child: SwitchListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
