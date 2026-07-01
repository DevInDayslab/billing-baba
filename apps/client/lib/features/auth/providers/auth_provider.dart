import 'dart:async';

import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/repositories/auth_repository.dart';
import 'package:billing_baba/features/auth/services/auth_service.dart';
import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

enum AuthStatus {
  initializing,
  unauthenticated,
  otpSent,
  authenticated,
  needsBusinessSelection,
  needsBusinessCreation,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initializing,
    this.phone = '',
    this.reqId = '',
    this.isLoading = false,
    this.error,
    this.session,
  });

  final AuthStatus status;
  final String phone;
  final String reqId;
  final bool isLoading;
  final String? error;
  final AuthSession? session;

  AuthState copyWith({
    AuthStatus? status,
    String? phone,
    String? reqId,
    bool? isLoading,
    String? error,
    AuthSession? session,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      reqId: reqId ?? this.reqId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      session: clearSession ? null : session ?? this.session,
    );
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository();

@Riverpod(keepAlive: true)
OtpService otpService(Ref ref) => OtpService();

@Riverpod(keepAlive: true)
Future<AuthService> authService(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final repository = ref.watch(authRepositoryProvider);
  return AuthService(repository: repository, storage: storage);
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  var _autoLoginStarted = false;

  /// Preserved across loading/error so resend still has MSG91 reqId.
  String? _otpReqId;

  @override
  AuthState build() {
    if (!_autoLoginStarted) {
      _autoLoginStarted = true;
      Future.microtask(tryAutoLogin);
    }
    return const AuthState();
  }

  Future<AuthService> _service() => ref.read(authServiceProvider.future);
  OtpService get _otp => ref.read(otpServiceProvider);

  AuthStatus _statusForSession(AuthSession session) {
    if (session.businesses.isEmpty) {
      return AuthStatus.needsBusinessCreation;
    }
    if (session.businesses.length > 1) {
      final hasBusinessScope = session.user.role != null;
      return hasBusinessScope
          ? AuthStatus.authenticated
          : AuthStatus.needsBusinessSelection;
    }
    return AuthStatus.authenticated;
  }

  Future<void> tryAutoLogin() async {
    state = state.copyWith(
      status: AuthStatus.initializing,
      isLoading: true,
      clearError: true,
    );

    try {
      final service = await _service().timeout(const Duration(seconds: 8));
      final session = await service
          .loadStoredSession()
          .timeout(const Duration(seconds: 8));
      if (session == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          clearSession: true,
        );
        return;
      }

      state = state.copyWith(
        status: _statusForSession(session),
        isLoading: false,
        session: session,
        phone: session.user.phone,
      );
    } on TimeoutException {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        clearSession: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: _messageFromError(e),
        clearSession: true,
      );
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true, phone: phone);

    try {
      final reqId = await _otp
          .sendOtp(phone)
          .timeout(const Duration(seconds: 20));

      _otpReqId = reqId;
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.otpSent,
        reqId: reqId,
      );
    } on TimeoutException {
      state = state.copyWith(
        isLoading: false,
        error: 'OTP request timed out. Check your connection and try again.',
      );
    } on OtpException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromError(e),
      );
    }
  }

  Future<bool> verifyOtp(String otp) async {
    final reqId = _otpReqId ?? state.reqId;
    if (reqId.isEmpty) {
      state = state.copyWith(
        error: 'Session expired. Go back and request a new OTP.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final msg91Token = await _otp.verifyOtp(reqId: reqId, otp: otp);

      final service = await _service();
      final session = await service.loginWithMsg91Token(
        msg91AccessToken: msg91Token,
        phone: state.phone,
      );

      _otpReqId = null;
      state = state.copyWith(
        isLoading: false,
        status: _statusForSession(session),
        session: session,
        phone: session.user.phone,
      );
      return true;
    } on OtpException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromError(e),
      );
      return false;
    }
  }

  Future<void> devLogin() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final service = await _service();
      final session = await service.devLogin();

      state = state.copyWith(
        isLoading: false,
        status: _statusForSession(session),
        session: session,
        phone: session.user.phone,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromError(e),
      );
    }
  }

  Future<void> resendOtp() async {
    final reqId = _otpReqId ?? state.reqId;
    if (reqId.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _otp.retryOtp(reqId);
      state = state.copyWith(isLoading: false, status: AuthStatus.otpSent);
    } on OtpException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromError(e),
      );
    }
  }

  void resetToLogin() {
    _otpReqId = null;
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      reqId: '',
      clearError: true,
    );
  }

  Future<void> selectBusiness(String businessId) async {
    final refreshToken = state.session?.refreshToken;
    if (refreshToken == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = await _service();
      final session = await service.selectBusiness(
        businessId: businessId,
        refreshToken: refreshToken,
      );
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        session: session,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromError(e),
      );
    }
  }

  Future<AuthSession?> refreshAccessToken({String? businessId}) async {
    try {
      final service = await _service();
      final session = await service.refreshStoredSession(businessId: businessId);
      if (session != null) {
        state = state.copyWith(
          status: _statusForSession(session),
          session: session,
        );
      }
      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = await _service();
      await service.logout();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  String _messageFromError(Object error) {
    if (error is OtpException) {
      return error.message;
    }
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['code']?.toString();
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return _mapApiErrorMessage(code, message);
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Network unavailable. Check your connection and try again.';
      }
    }
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring('Exception: '.length);
      }
      return message;
    }
    return 'Something went wrong. Please try again.';
  }

  String _mapApiErrorMessage(String? code, String message) {
    switch (code) {
      case 'MSG91_VERIFICATION_FAILED':
        return 'MSG91 verification failed. Please try again.';
      case 'AUTH_NOT_CONFIGURED':
        return 'Authentication is not configured on the server.';
      case 'VALIDATION_ERROR':
        return 'Invalid login request. Please try again.';
      case 'INVALID_TOKEN':
      case 'TOKEN_EXPIRED':
        return message;
      default:
        if (message.toLowerCase().contains('phone number')) {
          return 'Could not complete sign-in. Please try again.';
        }
        return message;
    }
  }
}
