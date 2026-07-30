import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/routing/app_router.dart';
import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/utils/switch_company_debug_log.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

/// Shared handlers for the desktop application menu.
abstract final class DesktopMenuActions {
  static bool canUseBusinessActions(AuthState auth) =>
      auth.status == AuthStatus.authenticated;

  static bool canLogout(AuthState auth) =>
      auth.status == AuthStatus.authenticated ||
      auth.status == AuthStatus.needsBusinessSelection ||
      auth.status == AuthStatus.needsBusinessCreation;

  static Future<void> openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      LoggingService.instance.warn('Failed to open URL: $url');
    }
  }

  static Future<void> openMailto({
    required String email,
    String? subject,
    String? body,
  }) async {
    // Build query with %20 (not +) so mail clients don't show literal pluses.
    final parts = <String>[
      if (subject != null && subject.isNotEmpty)
        'subject=${Uri.encodeComponent(subject)}',
      if (body != null && body.isNotEmpty)
        'body=${Uri.encodeComponent(body)}',
    ];
    final uri = Uri.parse(
      parts.isEmpty
          ? 'mailto:$email'
          : 'mailto:$email?${parts.join('&')}',
    );
    final launched = await launchUrl(uri);
    if (!launched) {
      LoggingService.instance.warn('Failed to open mailto: $email');
    }
  }

  static void go(WidgetRef ref, String location) {
    ref.read(appRouterProvider).go(location);
  }

  static Future<void> switchBusiness(WidgetRef ref) async {
    SwitchCompanyDebugLog.action('DesktopMenu.switchBusiness');
    await switchToBusinessSelection(
      ref,
      navigateToBusinessList: () async {
        SwitchCompanyDebugLog.nav('DesktopMenu go(businessList)');
        go(ref, AppRoutes.businessList);
      },
    );
  }

  static void renameBusiness(WidgetRef ref) {
    go(ref, AppRoutes.editProfile);
  }

  static void openSettings(WidgetRef ref) {
    go(ref, AppRoutes.settingsPreferences);
  }

  static void openAbout(WidgetRef ref) {
    go(ref, AppRoutes.settingsTab(SettingsTab.about.id));
  }

  static Future<void> logout(WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    go(ref, AppRoutes.login);
  }

  static Future<void> quit() async {
    if (kIsWeb) return;
    if (!AppPlatform.current.isDesktop) {
      await SystemNavigator.pop();
      return;
    }
    await windowManager.close();
  }

  static Future<void> openDocumentation() =>
      openExternalUrl(AppConfig.documentationUrl);

  static Future<void> openContactSupport() =>
      openExternalUrl(AppConfig.contactSupportUrl);

  static Future<void> reportIssue() => openMailto(
        email: AppConfig.supportEmail,
        subject: 'Billing Baba — Issue Report',
      );

  static Future<void> openPrivacyPolicy() =>
      openExternalUrl(AppConfig.privacyPolicyUrl);

  /// Refreshes in-memory app state (not Flutter hot reload).
  static Future<void> reload(WidgetRef ref) async {
    final auth = ref.read(authProvider);
    if (canUseBusinessActions(auth)) {
      invalidateAllBusinessScopedProvidersOn(ref.container);
      return;
    }
    if (canLogout(auth)) {
      invalidateAllBusinessScopedProvidersOn(
        ref.container,
        includeBusinessList: true,
      );
    }
  }

  static Future<DesktopVersionInfo> loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    return DesktopVersionInfo(
      applicationVersion: info.version,
      buildVersion: info.buildNumber,
      databaseSchemaVersion: '${AppDatabase.currentSchemaVersion}',
      offlineSyncVersion: SyncApi.defaultProtocolVersion,
    );
  }
}

/// Display-only version metadata for the Versions menu.
class DesktopVersionInfo {
  const DesktopVersionInfo({
    required this.applicationVersion,
    required this.buildVersion,
    required this.databaseSchemaVersion,
    required this.offlineSyncVersion,
  });

  static const empty = DesktopVersionInfo(
    applicationVersion: '—',
    buildVersion: '—',
    databaseSchemaVersion: '—',
    offlineSyncVersion: '—',
  );

  final String applicationVersion;
  final String buildVersion;
  final String databaseSchemaVersion;
  final String offlineSyncVersion;
}
