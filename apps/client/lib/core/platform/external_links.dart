import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/platform/desktop_menu_actions.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a public website URL in the system browser.
Future<void> openAppExternalUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    _showLinkError(context);
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    _showLinkError(context);
  }
}

Future<void> openTermsOfService(BuildContext context) =>
    openAppExternalUrl(context, AppConfig.termsOfServiceUrl);

Future<void> openPrivacyPolicy(BuildContext context) =>
    openAppExternalUrl(context, AppConfig.privacyPolicyUrl);

void _showLinkError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Could not open link. Try again later.',
        style: AppTypography.inter(
          fontSize: AppTypography.bodySize,
          color: Colors.white,
        ),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Opens URLs without [BuildContext] (menus, desktop actions).
Future<void> openAppExternalUrlSilently(String url) =>
    DesktopMenuActions.openExternalUrl(url);
