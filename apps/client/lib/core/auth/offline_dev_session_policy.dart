import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/services/auth_service.dart';

/// Rules for the mobile-only local developer session (fake JWTs).
abstract final class OfflineDevSessionPolicy {
  static Future<bool> isActive(StorageService storage) async {
    final token = await storage.readSecure(StorageKeys.accessToken);
    return AuthService.isOfflineDevToken(token ?? '');
  }
}
