import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';

bool canShowUpdateUi({
  required String location,
  required AuthStatus authStatus,
}) {
  if (location == AppRoutes.splash ||
      location == AppRoutes.login ||
      location == AppRoutes.verifyOtp) {
    return false;
  }

  return switch (authStatus) {
    AuthStatus.authenticated => true,
    AuthStatus.needsBusinessSelection ||
    AuthStatus.needsBusinessCreation => location == AppRoutes.businessList,
    AuthStatus.unauthenticated ||
    AuthStatus.otpSent ||
    AuthStatus.initializing => false,
  };
}
