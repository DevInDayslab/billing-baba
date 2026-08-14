import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/services/session_cache_cleanup.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/models/auth_user.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/auth/models/device_trust_credential.dart';
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

  /// Coalesces concurrent [refreshStoredSession] callers onto one in-flight refresh
  /// so rotated refresh tokens are not reused (which would clear the session).
  static Future<AuthSession?>? _inflightRefreshStoredSession;

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

    await _storage.write(StorageKeys.hasLoggedInBefore, 'true');

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
        final storedPhone = _storage.read(StorageKeys.accountPhone) ?? '';
        final phone = JwtUtils.phone(accessToken) ?? storedPhone;
        // API JWTs use account_id / user_id — never `sub`.
        final userId = JwtUtils.sessionUserId(accessToken) ?? 'offline';
        return AuthSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: 0,
          user: AuthUser(
            id: userId,
            phone: phone,
            role: JwtUtils.role(accessToken),
          ),
          businesses: const [],
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

    final inflight = _inflightRefreshStoredSession;
    if (inflight != null) {
      return inflight;
    }

    late final Future<AuthSession?> operation;
    operation = _withRefreshLock(() async {
      // Another refresh may have completed (e.g. selectBusiness) while we waited.
      final latestAccess = await _storage.readSecure(StorageKeys.accessToken);
      final latestRefresh = await _storage.readSecure(StorageKeys.refreshToken);
      if (latestAccess != null &&
          latestAccess.isNotEmpty &&
          latestAccess != accessToken &&
          latestRefresh != null &&
          latestRefresh.isNotEmpty) {
        return AuthSession(
          accessToken: latestAccess,
          refreshToken: latestRefresh,
          expiresIn: 0,
          user: AuthUser(
            id: JwtUtils.sessionUserId(latestAccess) ?? 'unknown',
            phone: JwtUtils.phone(latestAccess) ??
                _storage.read(StorageKeys.accountPhone) ??
                '',
            role: JwtUtils.role(latestAccess),
          ),
          businesses: const [],
        );
      }

      final tokenToUse = latestRefresh ?? token;
      if (tokenToUse.isEmpty) return null;

      try {
        final session = await _repository.refresh(
          refreshToken: tokenToUse,
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
          // Keep stored tokens when the backend is unreachable.
          return null;
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
    }).whenComplete(() {
      if (identical(_inflightRefreshStoredSession, operation)) {
        _inflightRefreshStoredSession = null;
      }
    });

    _inflightRefreshStoredSession = operation;
    return operation;
  }

  Future<AuthSession> loginWithMsg91Token({
    required String msg91AccessToken,
    required String phone,
    bool rememberFor30Days = false,
  }) async {
    AuthDebugLogger.log(
      'AuthService.loginWithMsg91Token entered '
      'phone=${AuthDebugLogger.maskPhone(phone)} '
      'remember=$rememberFor30Days',
    );
    final deviceId = await ensureAuthDeviceId();
    final session = await _repository.login(
      msg91AccessToken: msg91AccessToken,
      phone: phone,
      rememberFor30Days: rememberFor30Days,
      deviceId: deviceId,
    );
    AuthDebugLogger.backendLoginSuccess();
    AuthDebugLogger.jwtIssued(session.accessToken);
    await persistSession(session);
    await _syncDeviceTrustFromLogin(session, rememberFor30Days: rememberFor30Days);
    return session;
  }

  Future<AuthSession> loginWithDeviceTrust({required String phone}) async {
    final trust = await loadDeviceTrust();
    if (trust == null) {
      throw StateError('No valid device trust stored');
    }

    final normalizedPhone = _normalizePhoneForTrust(phone);
    if (trust.phone != normalizedPhone) {
      throw StateError('Phone does not match trusted device');
    }

    AuthDebugLogger.log(
      'AuthService.loginWithDeviceTrust entered '
      'phone=${AuthDebugLogger.maskPhone(phone)}',
    );

    final deviceId = await ensureAuthDeviceId();
    final session = await _repository.loginWithDeviceTrust(
      phone: phone,
      deviceId: deviceId,
      deviceTrustToken: trust.token,
    );
    AuthDebugLogger.backendLoginSuccess();
    AuthDebugLogger.jwtIssued(session.accessToken);
    await persistSession(session);
    return session;
  }

  /// Returns install-lifetime device id (same as sync transport).
  Future<String> ensureAuthDeviceId() async {
    return SyncDeviceIdentity(_storage).deviceId();
  }

  Future<DeviceTrustCredential?> loadDeviceTrust() async {
    final token = await _storage.readSecure(StorageKeys.deviceTrustToken);
    final phone = await _storage.readSecure(StorageKeys.deviceTrustPhone);
    final expiresAtRaw = await _storage.readSecure(
      StorageKeys.deviceTrustExpiresAt,
    );
    if (token == null ||
        token.isEmpty ||
        phone == null ||
        phone.isEmpty ||
        expiresAtRaw == null ||
        expiresAtRaw.isEmpty) {
      return null;
    }

    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null || !expiresAt.isAfter(DateTime.now())) {
      await clearDeviceTrust();
      return null;
    }

    return DeviceTrustCredential(token: token, phone: phone, expiresAt: expiresAt);
  }

  bool isDeviceTrustValidForPhone(DeviceTrustCredential trust, String phone) {
    return trust.phone == _normalizePhoneForTrust(phone);
  }

  Future<void> clearDeviceTrust() async {
    await _storage.deleteSecure(StorageKeys.deviceTrustToken);
    await _storage.deleteSecure(StorageKeys.deviceTrustPhone);
    await _storage.deleteSecure(StorageKeys.deviceTrustExpiresAt);
  }

  Future<void> _syncDeviceTrustFromLogin(
    AuthSession session, {
    required bool rememberFor30Days,
  }) async {
    if (rememberFor30Days &&
        session.deviceTrustToken != null &&
        session.deviceTrustToken!.isNotEmpty &&
        session.deviceTrustExpiresAt != null &&
        session.deviceTrustExpiresAt!.isNotEmpty) {
      await _storage.writeSecure(
        StorageKeys.deviceTrustToken,
        session.deviceTrustToken!,
      );
      await _storage.writeSecure(
        StorageKeys.deviceTrustPhone,
        _normalizePhoneForTrust(session.user.phone),
      );
      await _storage.writeSecure(
        StorageKeys.deviceTrustExpiresAt,
        session.deviceTrustExpiresAt!,
      );
      return;
    }

    if (!rememberFor30Days) {
      await clearDeviceTrust();
    }
  }

  String _normalizePhoneForTrust(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    return digits;
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
      // Prefer the latest stored refresh token — a concurrent access-token
      // refresh may have already rotated the one passed by the caller.
      final latestRefresh =
          await _storage.readSecure(StorageKeys.refreshToken) ?? refreshToken;
      final session = await _repository.refresh(
        refreshToken: latestRefresh,
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
    await _storage.write(StorageKeys.hasLoggedInBefore, 'true');

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
}
