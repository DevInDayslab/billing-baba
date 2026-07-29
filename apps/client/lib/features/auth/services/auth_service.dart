import 'dart:async';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/session_cache_cleanup.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/models/auth_user.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/auth/repositories/auth_repository.dart';
import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:billing_baba/features/auth/utils/auth_debug_logger.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/shared/utils/jwt_utils.dart';
import 'package:dio/dio.dart';

class AuthService {
  AuthService({
    required this._repository,
    required this._storage,
  });

  /// Serializes every `/auth/refresh` call across Dio clients and business selection.
  static Future<void> _refreshMutexChain = Future<void>.value();

  static Future<T> _withRefreshLock<T>(Future<T> Function() action) {
    final operation = _refreshMutexChain.then((_) => action());
    _refreshMutexChain = operation.then((_) {}, onError: (_) {});
    return operation;
  }

  /// Local-only developer session — never sent to the API.
  static const devAccessToken = 'dev-offline-access-token';
  static const devRefreshToken = 'dev-offline-refresh-token';

  final AuthRepository _repository;
  final StorageService _storage;

  static bool isOfflineDevSession(AuthSession session) =>
      isOfflineDevToken(session.accessToken);

  static BusinessProfileModel offlineDevBusinessProfile(AuthSession session) {
    final business = session.businesses.first;
    return BusinessProfileModel(
      id: business.id,
      name: business.name,
      ownerName: session.user.name,
      phone: session.user.phone,
    );
  }

  static bool isOfflineDevToken(String accessToken) =>
      accessToken == devAccessToken ||
      accessToken == OtpService.mockAccessToken;

  static AuthSession offlineDevSession({String phone = '919999999999'}) {
    return AuthSession(
      accessToken: devAccessToken,
      refreshToken: devRefreshToken,
      expiresIn: 86400,
      user: AuthUser(
        id: 'dev-user',
        phone: phone,
        name: 'Developer',
        role: 'owner',
      ),
      businesses: const [
        BusinessSummary(
          id: 'dev-business',
          name: 'Dev Business',
          role: 'owner',
        ),
      ],
    );
  }

  Future<AuthSession?> loadStoredSession() async {
    final accessToken = await _storage.readSecure(StorageKeys.accessToken);
    final refreshToken = await _storage.readSecure(StorageKeys.refreshToken);
    if (accessToken == null ||
        refreshToken == null ||
        accessToken.isEmpty ||
        refreshToken.isEmpty) {
      return null;
    }

    // Offline developer / mock sessions — restore locally, never hit the API.
    if (isOfflineDevToken(accessToken)) {
      final phone = _storage.read(StorageKeys.accountPhone) ?? '919999999999';
      return offlineDevSession(phone: phone).copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    final selectedId = await _storage.readSecure(
      StorageKeys.selectedBusinessId,
    );

    if (JwtUtils.isExpired(accessToken)) {
      AuthDebugLogger.log(
        'loadStoredSession: access token expired — refreshing',
      );
      return refreshStoredSession(
        refreshToken: refreshToken,
        businessId: selectedId,
      );
    }

    try {
      final me = await _repository.me(accessToken);
      if (selectedId != null &&
          selectedId.isNotEmpty &&
          me.businesses.length > 1 &&
          me.user.role == null &&
          me.businesses.any((business) => business.id == selectedId)) {
        return refreshStoredSession(
          refreshToken: refreshToken,
          businessId: selectedId,
        );
      }
      return AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: 0,
        user: me.user,
        businesses: me.businesses,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        AuthDebugLogger.log(
          'loadStoredSession: /auth/me returned 401 — refreshing',
        );
        return refreshStoredSession(
          refreshToken: refreshToken,
          businessId: selectedId,
        );
      }
      await clearSession();
      return null;
    }
  }

  Future<AuthSession?> refreshStoredSession({
    String? refreshToken,
    String? businessId,
    bool preserveBusinessScope = true,
  }) async {
    final token =
        refreshToken ?? await _storage.readSecure(StorageKeys.refreshToken);
    if (token == null) {
      return null;
    }

    final accessToken = await _storage.readSecure(StorageKeys.accessToken);
    if (isOfflineDevToken(accessToken ?? '')) {
      final phone = _storage.read(StorageKeys.accountPhone) ?? '919999999999';
      return offlineDevSession(phone: phone).copyWith(
        accessToken: accessToken!,
        refreshToken: token,
      );
    }

    final storedBusinessId = preserveBusinessScope
        ? await _storage.readSecure(StorageKeys.selectedBusinessId)
        : null;
    final effectiveBusinessId =
        businessId ??
        ((storedBusinessId != null && storedBusinessId.isNotEmpty)
            ? storedBusinessId
            : null);

    return _withRefreshLock(() async {
      try {
        final session = await _repository.refresh(
          refreshToken: token,
          businessId: effectiveBusinessId,
        );
        final persistBusinessId = _businessIdForSession(
          session,
          explicitBusinessId: businessId ?? effectiveBusinessId,
        );
        await persistSession(session, businessId: persistBusinessId);
        return session;
      } on DioException catch (e) {
        // Only wipe local credentials on definitive auth failures. Clearing on
        // every Dio error (timeouts, 5xx) left Switch Company with Headers:{}
        // and endless "Could not load businesses" 401 loops.
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          await clearSession();
        }
        return null;
      }
    });
  }

  Future<AuthSession> loginWithMsg91Token({
    required String msg91AccessToken,
    required String phone,
  }) async {
    AuthDebugLogger.log(
      'AuthService.loginWithMsg91Token entered '
      'phone=${AuthDebugLogger.maskPhone(phone)}',
    );
    final session = await _repository.login(
      msg91AccessToken: msg91AccessToken,
      phone: phone,
    );
    AuthDebugLogger.backendLoginSuccess();
    AuthDebugLogger.jwtIssued(session.accessToken);
    await persistSession(session);
    return session;
  }

  Future<AuthSession> devLogin() async {
    AuthDebugLogger.log('AuthService.devLogin: POST /auth/dev-login');
    final session = await _repository.devLogin();
    AuthDebugLogger.backendLoginSuccess();
    AuthDebugLogger.jwtIssued(session.accessToken);
    await persistSession(session);
    return session;
  }

  Future<AuthSession> selectBusiness({
    required String businessId,
    required String refreshToken,
  }) async {
    return _withRefreshLock(() async {
      final session = await _repository.refresh(
        refreshToken: refreshToken,
        businessId: businessId,
      );
      await persistSession(session, businessId: businessId);
      return session;
    });
  }

  Future<void> logout() async {
    final accessToken = await _storage.readSecure(StorageKeys.accessToken);
    final refreshToken = await _storage.readSecure(StorageKeys.refreshToken);
    if (accessToken != null && refreshToken != null) {
      try {
        await _repository.logout(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } on DioException {
        // Clear local session even if remote logout fails.
      }
    }
    await clearSession();
  }

  Future<void> persistSession(
    AuthSession session, {
    String? businessId,
  }) async {
    final previousPhone = _storage.read(StorageKeys.accountPhone);
    if (previousPhone != null &&
        previousPhone.isNotEmpty &&
        previousPhone != session.user.phone) {
      await SessionCacheCleanup(_storage).clearAll();
    }

    await _storage.writeSecure(StorageKeys.accessToken, session.accessToken);
    await _storage.writeSecure(StorageKeys.refreshToken, session.refreshToken);
    await _storage.write(StorageKeys.accountPhone, session.user.phone);

    final selectedId = _businessIdForSession(
      session,
      explicitBusinessId: businessId,
    );
    if (selectedId != null) {
      await _storage.writeSecure(StorageKeys.selectedBusinessId, selectedId);
      await _storage.write(StorageKeys.lastOpenedBusinessId, selectedId);
    } else {
      await _storage.deleteSecure(StorageKeys.selectedBusinessId);
    }
  }

  String? _businessIdForSession(
    AuthSession session, {
    String? explicitBusinessId,
  }) {
    if (explicitBusinessId != null && explicitBusinessId.isNotEmpty) {
      return explicitBusinessId;
    }
    if (session.user.role != null && session.businesses.length == 1) {
      return session.businesses.first.id;
    }
    return null;
  }

  Future<void> clearSession() async {
    await _storage.deleteSecure(StorageKeys.accessToken);
    await _storage.deleteSecure(StorageKeys.refreshToken);
    await _storage.deleteSecure(StorageKeys.selectedBusinessId);
    await _storage.write(StorageKeys.accountPhone, '');
    await SessionCacheCleanup(_storage).clearAll();
  }

  Future<String?> getAccessToken() =>
      _storage.readSecure(StorageKeys.accessToken);
}
