import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/features/collaboration/application/navigation_permission_registry.dart';
import 'package:billing_baba/features/collaboration/application/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationPermissionRegistry', () {
    test('shows standard nav when company session is not seeded yet', () {
      final service = PermissionService(null);

      expect(
        NavigationPermissionRegistry.isVisible(AppRoutes.home, service),
        isTrue,
      );
      expect(
        NavigationPermissionRegistry.isVisible(AppRoutes.parties, service),
        isTrue,
      );
      expect(
        NavigationPermissionRegistry.isVisible(AppRoutes.saleInvoices, service),
        isTrue,
      );
      expect(
        NavigationPermissionRegistry.isPurchaseNavVisible(service),
        isTrue,
      );
    });

    test('hides owner-only routes when session is not seeded', () {
      final service = PermissionService(null);

      expect(
        NavigationPermissionRegistry.isVisible(AppRoutes.utilities, service),
        isFalse,
      );
      expect(
        NavigationPermissionRegistry.isVisible(AppRoutes.developer, service),
        isFalse,
      );
      expect(
        NavigationPermissionRegistry.isVisible(AppRoutes.plansPricing, service),
        isFalse,
      );
    });
  });
}
