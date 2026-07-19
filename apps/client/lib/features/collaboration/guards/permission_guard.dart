import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/collaboration/application/permission_service.dart';

/// GoRouter redirect helper for route-level permission checks.
abstract final class PermissionGuard {
  static String? redirect(String location, PermissionService service) {
    if (location == AppRoutes.businessList ||
        location == AppRoutes.login ||
        location == AppRoutes.verifyOtp ||
        location == AppRoutes.splash) {
      return null;
    }

    if (location == AppRoutes.accessDenied) return null;

    if (!service.hasSession) return null;

    if (service.canAccessRoute(location)) return null;

    final from = Uri.encodeComponent(location);
    return '${AppRoutes.accessDenied}?from=$from';
  }
}
