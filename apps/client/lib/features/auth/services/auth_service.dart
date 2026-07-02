import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/repositories/auth_repository.dart';
import 'package:billing_baba/features/auth/utils/auth_debug_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService({
    required this._repository,
    required this._storage,
  });

  final AuthRepository _repository;
  final StorageService _storage;

  Future<AuthSession?> loadStoredSession() async {
    final accessToken = await _storage.readSecure(StorageKeys.accessToken);
    final refreshToken = await _storage.readSecure(StorageKeys.refreshToken);
    if (accessToken == null ||
        refreshToken == null ||
        accessToken.isEmpty ||
        refreshToken.isEmpty) {
      return null;
    }

    try {
      final me = await _repository.me(accessToken);
      final selectedId = await _storage.readSecure(
        StorageKeys.selectedBusinessId,
      );
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
        final selectedId = await _storage.readSecure(
          StorageKeys.selectedBusinessId,
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
  }) async {
    final token =
        refreshToken ?? await _storage.readSecure(StorageKeys.refreshToken);
    if (token == null) {
      return null;
    }

    try {
      final session = await _repository.refresh(
        refreshToken: token,
        businessId: businessId,
      );
      await persistSession(session, businessId: businessId);
      return session;
    } on DioException {
      await clearSession();
      return null;
    }
  }

  Future<AuthSession> loginWithMsg91Token({
    required String msg91AccessToken,
    required String phone,
  }) async {
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
    final session = await _repository.devLogin();
    debugPrint('[DEV_LOGIN] Response received');
    AuthDebugLogger.backendLoginSuccess();
    AuthDebugLogger.jwtIssued(session.accessToken);
    await persistSession(session);
    return session;
  }

  Future<AuthSession> selectBusiness({
    required String businessId,
    required String refreshToken,
  }) async {
    final session = await _repository.refresh(
      refreshToken: refreshToken,
      businessId: businessId,
    );
    await persistSession(session, businessId: businessId);
    return session;
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
    await _storage.writeSecure(StorageKeys.accessToken, session.accessToken);
    await _storage.writeSecure(StorageKeys.refreshToken, session.refreshToken);
    await _storage.write(StorageKeys.accountPhone, session.user.phone);
    if (businessId != null) {
      await _storage.writeSecure(StorageKeys.selectedBusinessId, businessId);
    }
  }

  Future<void> clearSession() async {
    await _storage.deleteSecure(StorageKeys.accessToken);
    await _storage.deleteSecure(StorageKeys.refreshToken);
    await _storage.deleteSecure(StorageKeys.selectedBusinessId);
    await _storage.write(StorageKeys.accountPhone, '');
  }

  Future<String?> getAccessToken() =>
      _storage.readSecure(StorageKeys.accessToken);
}
