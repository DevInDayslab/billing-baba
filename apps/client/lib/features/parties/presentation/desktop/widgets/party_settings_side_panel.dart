import 'dart:async';
import 'dart:math' as math;

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/presentation/desktop/desktop_party_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _panelBorder = Color(0xFFE0E0E0);
const _footerBg = Color(0xFFFAFAFA);

/// Vyapar-style slide-in panel for party settings (desktop).
Future<void> showPartySettingsSidePanel({
  required BuildContext context,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Party settings',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, _) {
      return Align(
        alignment: Alignment.centerRight,
        child: _PartySettingsSidePanel(
          onClose: () => Navigator.of(dialogContext).pop(),
          onMoreSettings: () {
            Navigator.of(dialogContext).pop();
            unawaited(context.push(AppRoutes.settingsParty));
          },
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: offset, child: child);
    },
  );
}

class _PartySettingsSidePanel extends StatelessWidget {
  const _PartySettingsSidePanel({
    required this.onClose,
    required this.onMoreSettings,
  });

  final VoidCallback onClose;
  final VoidCallback onMoreSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = math.min(420.0, math.max(300.0, screenWidth * 0.36));

    return Material(
      color: AppColors.surface,
      elevation: 12,
      shadowColor: Colors.black26,
      child: SafeArea(
        child: SizedBox(
          width: panelWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Party Settings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _panelBorder),
              const Expanded(child: DesktopPartySettingsScreen()),
              const Divider(height: 1, color: _panelBorder),
              Material(
                color: _footerBg,
                child: SafeArea(
                  top: false,
                  child: InkWell(
                    onTap: onMoreSettings,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.settings,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              'More Settings',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
