import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/mobile_notifications_theme.dart';
import 'package:flutter/material.dart';

/// Rounded permission card: "Stay Updated! 🔔" + enable CTA.
class MobileStayUpdatedBanner extends StatelessWidget {
  const MobileStayUpdatedBanner({
    required this.onEnable,
    super.key,
  });

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MobileNotificationsTheme.bannerOuterPadding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            MobileNotificationsTheme.bannerRadius,
          ),
          boxShadow: MobileNotificationsTheme.bannerShadow,
        ),
        child: Padding(
          padding: MobileNotificationsTheme.bannerInnerPadding,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Stay Updated! 🔔',
                  style: AppTypography.inter(
                    fontSize: MobileNotificationsTheme.bannerTitleSize,
                    fontWeight: MobileNotificationsTheme.bannerTitleWeight,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: onEnable,
                style: FilledButton.styleFrom(
                  backgroundColor: MobileNotificationsTheme.accentRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  minimumSize: const Size(
                    0,
                    MobileNotificationsTheme.enableButtonMinHeight,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      MobileNotificationsTheme.enableButtonRadius,
                    ),
                  ),
                  textStyle: AppTypography.inter(
                    fontSize: MobileNotificationsTheme.enableButtonFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                child: const Text(
                  'Enable Notifications',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
