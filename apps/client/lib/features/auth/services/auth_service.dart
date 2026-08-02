import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/services/session_cache_cleanup.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/models/auth_user.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/auth/repositories/auth_repository.dart';
import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:billing_baba/features/auth/utils/auth_debug_logger.dart';
import 'package:billing_baba/features/business/data/business_cache.dart';
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

  static bool isMockOtpToken(String accessToken) =>
      accessToken == OtpService.mockAccessToken;

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
      accessToken == devAccessToken;

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

  /// Replaces mobile-only fake credentials with a real API session when the
  /// backend is reachable (e.g. API was down at Developer Login, now running).
  Future<AuthSession?> upgradeOfflineDevSessionIfApiAvailable() async {
    final accessToken = await _storage.readSecure(StorageKeys.accessToken);
    if (accessToken == null || !isOfflineDevToken(accessToken)) {
      return null;
    }

    try {
      final healthy = await _repository.checkHealth();
      if (!healthy) {
        return null;
      }

      AuthDebugLogger.log(
        'upgradeOfflineDevSession: API reachable — replacing local dev credentials',
      );
      final session = await _repository.devLogin();
      await persistSession(session);
      AuthDebugLogger.backendLoginSuccess();
      AuthDebugLogger.jwtIssued(session.accessToken);
      return session;
    } on DioException catch (error) {
      if (NetworkExceptionClassifier.isConnectivityError(error)) {
        return null;
      }
      rethrow;
    }
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

    if (isMockOtpToken(accessToken)) {
      await clearSession();
      return null;
    }

    // Offline developer session — upgrade when API is back, else local only.
    if (isOfflineDevToken(accessToken)) {
      final upgraded = await upgradeOfflineDevSessionIfApiAvailable();
      if (upgraded != null) {
        return upgraded;
      }

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
      final session = AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: 0,
        user: me.user,
        businesses: me.businesses,
      );
      await seedBusinessListCache(session);
      return session;
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
      if (NetworkExceptionClassifier.isConnectivityError(e)) {
        return reconstructSessionFromStoredTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          selectedBusinessId: selectedId,
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
    if (accessToken != null && isMockOtpToken(accessToken)) {
      await clearSession();
      return null;
    }
    if (accessToken != null && isOfflineDevToken(accessToken)) {
      final upgraded = await upgradeOfflineDevSessionIfApiAvailable();
      if (upgraded != null) {
        return upgraded;
      }

      final phone = _storage.read(StorageKeys.accountPhone) ?? '919999999999';
      return offlineDevSession(phone: phone).copyWith(
        accessToken: accessToken,
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
        if (NetworkExceptionClassifier.isConnectivityError(e)) {
          return reconstructSessionFromStoredTokens(
            accessToken: accessToken,
            refreshToken: token,
            selectedBusinessId: effectiveBusinessId,
          );
        }
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
    // Prefer the real API so desktop and mobile share the same cloud account,
    // business, parties, items, and documents. Fall back to a local-only
    // session only on mobile when the API host is unreachable (e.g. loopback).
    AuthDebugLogger.log(
      'AuthService.devLogin: POST /auth/dev-login',
    );
    try {
      final session = await _repository.devLogin();
      await persistSession(session);
      AuthDebugLogger.backendLoginSuccess();
      AuthDebugLogger.jwtIssued(session.accessToken);
      return session;
    } on DioException catch (error) {
      if (!NetworkExceptionClassifier.isConnectivityError(error)) {
        rethrow;
      }
      // Desktop expects a running local API — offline fallback hides empty catalog.
      if (AppPlatform.current.isDesktop) {
        AuthDebugLogger.log(
          'AuthService.devLogin: API unreachable on desktop — not using offline fallback',
        );
        rethrow;
      }
      final rawHost = Uri.tryParse(AppConfig.apiBaseUrl)?.host ?? '';
      final isLoopback =
          rawHost == '127.0.0.1' ||
          rawHost == 'localhost' ||
          rawHost == '0.0.0.0';
      if (AppPlatform.current.isAndroid &&
          AppPlatform.current.isMobile &&
          isLoopback) {
        AuthDebugLogger.log(
          'AuthService.devLogin: cannot reach $rawHost from Android. '
          'For USB devices run: adb reverse tcp:3000 tcp:3000 '
          '(or set API_BASE_URL to your PC LAN IP on the same Wi‑Fi). '
          'Using offline local fallback.',
        );
      }
      AuthDebugLogger.log(
        'AuthService.devLogin: API unreachable — offline local fallback '
        '(${error.type})',
      );
      final session = AuthService.offlineDevSession();
      await persistSession(session);
      AuthDebugLogger.backendLoginSuccess();
      AuthDebugLogger.jwtIssued(session.accessToken);
      return session;
    }
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

    await seedBusinessListCache(session);
  }

  /// Seeds SharedPreferences business-list cache from auth session summaries so
  /// company selection works offline even if GET /businesses was never called.
  Future<void> seedBusinessListCache(AuthSession session) async {
    if (session.businesses.isEmpty) return;
    if (isOfflineDevSession(session)) return;

    final accountId =
        JwtUtils.accountId(session.accessToken) ?? session.user.id;
    if (accountId.isEmpty || accountId == 'offline') return;

    final cache = BusinessCache(_storage);
    final existing = await cache.readBusinesses();
    final cachedAccountId = cache.readCachedBusinessesAccountId();
    if (existing.isNotEmpty &&
        cachedAccountId != null &&
        JwtUtils.isSameAccountCacheKey(
          cachedAccountId: cachedAccountId,
          sessionUserId: session.user.id,
          accessToken: session.accessToken,
        )) {
      // Keep a richer list from GET /businesses when already present.
      return;
    }

    await cache.saveBusinesses(
      session.businesses
          .map(
            (b) => <String, dynamic>{
              'id': b.id,
              'name': b.name,
              'role': b.role,
              'gstin': b.gstin,
            },
          )
          .toList(),
      accountId: accountId,
    );
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

  /// Rebuilds a session from secure storage when the API is unreachable.
  Future<AuthSession?> reconstructSessionFromStoredTokens({
    String? accessToken,
    String? refreshToken,
    String? selectedBusinessId,
  }) async {
    final token =
        accessToken ?? await _storage.readSecure(StorageKeys.accessToken);
    final refresh =
        refreshToken ?? await _storage.readSecure(StorageKeys.refreshToken);
    if (token == null || refresh == null || token.isEmpty || refresh.isEmpty) {
      return null;
    }

    if (isMockOtpToken(token)) {
      return null;
    }

    if (isOfflineDevToken(token)) {
      final phone = _storage.read(StorageKeys.accountPhone) ?? '919999999999';
      return offlineDevSession(phone: phone).copyWith(
        accessToken: token,
        refreshToken: refresh,
      );
    }

    final storedPhone = _storage.read(StorageKeys.accountPhone) ?? '';
    final phone = JwtUtils.phone(token) ?? storedPhone;
    final userId = JwtUtils.sessionUserId(token) ?? 'offline';
    final businesses = await _loadCachedBusinessSummaries();

    return AuthSession(
      accessToken: token,
      refreshToken: refresh,
      expiresIn: 0,
      user: AuthUser(
        id: userId,
        phone: phone,
        role: JwtUtils.role(token),
      ),
      businesses: businesses,
    );
  }

  Future<List<BusinessSummary>> _loadCachedBusinessSummaries() async {
    final cache = BusinessCache(_storage);
    final cached = await cache.readBusinesses();
    return cached
        .map(
          (business) => BusinessSummary(
            id: business['id']?.toString() ?? '',
            name: business['name']?.toString() ?? '',
            role: business['role']?.toString() ?? 'owner',
            gstin: business['gstin']?.toString(),
          ),
        )
        .where((business) => business.id.isNotEmpty)
        .toList();
  }
}
