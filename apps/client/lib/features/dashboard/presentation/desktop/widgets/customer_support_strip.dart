import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Customer support contact line for the desktop chrome.
///
/// [compact] embeds in the MenuBar row (Windows/Linux). When false, renders a
/// full-width strip (used under the native macOS menu).
class CustomerSupportStrip extends StatelessWidget {
  const CustomerSupportStrip({
    super.key,
    this.compact = false,
  });

  /// When true, content-sized only (no full-width border). For MenuBar row.
  final bool compact;

  static const supportPhone = '9584558455';
  static const _whatsAppUrl = 'https://wa.me/919584558455';
  static const _telUrl = 'tel:9584558455';
  static const _iconSize = 12.0;

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Widget get _content => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Contact Support',
        style: DashboardTypography.supportStrip,
      ),
      const SizedBox(width: AppSpacing.xs),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _openUrl(_telUrl),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.phone,
                size: _iconSize,
                color: AppColors.primary,
              ),
              Text(
                ' : ',
                style: DashboardTypography.supportStrip,
              ),
              Text(
                supportPhone,
                style: DashboardTypography.supportStripLink,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      const Text('|', style: DashboardTypography.supportStrip),
      const SizedBox(width: AppSpacing.sm),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _openUrl(_whatsAppUrl),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.whatsapp,
                size: _iconSize,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Get instant support',
                style: DashboardTypography.supportStripLink,
              ),
            ],
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: _content,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: DashboardSpacing.supportStripHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: _content,
      ),
    );
  }
}
