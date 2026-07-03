import 'dart:async';

import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/services/session_cache_cleanup.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/models/auth_user.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/auth/models/otp_phase.dart';
import 'package:billing_baba/features/auth/repositories/auth_repository.dart';
import 'package:billing_baba/features/auth/services/auth_service.dart';
import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:billing_baba/features/auth/utils/auth_flow_logger.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

const _resendCooldown = Duration(seconds: 30);
const _splashMinDuration = Duration(milliseconds: 2400);

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
    this.otpPhase = OtpPhase.idle,
    this.phone = '',
    this.reqId = '',
    this.msg91AccessToken,
    this.error,
    this.session,
    this.resendAvailableAt,
    this.otpSessionVersion = 0,
    this.backendLoginCompleted = false,
  });

  final AuthStatus status;
  final OtpPhase otpPhase;
  final String phone;
  final String reqId;
  final String? msg91AccessToken;
  final String? error;
  final AuthSession? session;
  final DateTime? resendAvailableAt;
  final int otpSessionVersion;
  final bool backendLoginCompleted;

  bool get isOtpBusy => otpPhase.isBusy;

  bool get isSendingOtp => otpPhase == OtpPhase.sendingOtp;

  bool get isVerifyingOtp =>
      otpPhase == OtpPhase.verifyingOtp || otpPhase == OtpPhase.backendLogin;

  bool get isBackendLogin => otpPhase == OtpPhase.backendLogin;

  bool get isBackendLoginFailed => otpPhase == OtpPhase.backendLoginFailed;

  bool get canSendOtp =>
      status == AuthStatus.unauthenticated && otpPhase == OtpPhase.idle;

  bool get canVerifyOtp =>
      status == AuthStatus.otpSent && otpPhase.canVerify && reqId.isNotEmpty;

  bool get canRetryBackendLogin =>
      status == AuthStatus.otpSent &&
      otpPhase == OtpPhase.backendLoginFailed &&
      msg91AccessToken != null &&
      msg91AccessToken!.isNotEmpty;

  bool get canResendOtp {
    if (status != AuthStatus.otpSent || !otpPhase.canResend) return false;
    final availableAt = resendAvailableAt;
    if (availableAt == null) return false;
    return DateTime.now().isAfter(availableAt);
  }

  bool get showResend =>
      status == AuthStatus.otpSent &&
      !backendLoginCompleted &&
      otpPhase != OtpPhase.backendLogin &&
      otpPhase != OtpPhase.backendLoginFailed &&
      otpPhase != OtpPhase.verifyingOtp;

  int get resendSecondsLeft {
    final availableAt = resendAvailableAt;
    if (availableAt == null) return 0;
    final remaining = availableAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  AuthState copyWith({
    AuthStatus? status,
    OtpPhase? otpPhase,
    String? phone,
    String? reqId,
    String? msg91AccessToken,
    String? error,
    AuthSession? session,
    DateTime? resendAvailableAt,
    int? otpSessionVersion,
    bool? backendLoginCompleted,
    bool clearError = false,
    bool clearSession = false,
    bool clearReqId = false,
    bool clearResendTimer = false,
    bool clearMsg91Token = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      otpPhase: otpPhase ?? this.otpPhase,
      phone: phone ?? this.phone,
      reqId: clearReqId ? '' : reqId ?? this.reqId,
      msg91AccessToken: clearMsg91Token
          ? null
          : msg91AccessToken ?? this.msg91AccessToken,
      error: clearError ? null : error ?? this.error,
      session: clearSession ? null : session ?? this.session,
      resendAvailableAt: clearResendTimer
          ? null
          : resendAvailableAt ?? this.resendAvailableAt,
      otpSessionVersion: otpSessionVersion ?? this.otpSessionVersion,
      backendLoginCompleted:
          backendLoginCompleted ?? this.backendLoginCompleted,
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
  static const _sendTimeout = Duration(seconds: 20);

  var _autoLoginStarted = false;
  var _verifyInFlight = false;
  var _backendLoginInFlight = false;
  var _resendInFlight = false;
  var _sendInFlight = false;
  var _devLoginInFlight = false;
  int _verifyGeneration = 0;

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

  void _setOtpPhase(OtpPhase phase) {
    AuthFlowLogger.otpTransition(phase);
    state = state.copyWith(otpPhase: phase);
  }

  void _setAuthStatus(AuthStatus status) {
    AuthFlowLogger.authStatus(status.name);
    state = state.copyWith(status: status);
  }

  AuthStatus _statusForSession(AuthSession session) {
    if (session.businesses.isEmpty) {
      return AuthStatus.needsBusinessSelection;
    }
    if (session.user.role == null) {
      return AuthStatus.needsBusinessSelection;
    }
    return AuthStatus.authenticated;
  }

  bool _hasBusinessScope(AuthSession? session) =>
      session != null && session.user.role != null;

  Future<void> _invalidateBusinessProviders({bool includeList = false}) async {
    if (includeList) {
      ref.invalidate(businessListProvider);
    }
    ref.invalidate(businessProfileProvider);
    ref.invalidate(businessServiceProvider);
    ref.invalidate(partyListProvider);
    ref.invalidate(partyServiceProvider);
  }

  Future<void> _clearBusinessScopedCaches() async {
    final storage = await ref.read(storageServiceProvider.future);
    await SessionCacheCleanup(storage).clearBusinessScopedData();
    await _invalidateBusinessProviders(includeList: true);
  }

  void _onOtpSent(String reqId, {required String phone}) {
    _setOtpPhase(OtpPhase.otpSent);
    _setAuthStatus(AuthStatus.otpSent);
    state = state.copyWith(
      phone: phone,
      reqId: reqId,
      clearError: true,
      resendAvailableAt: DateTime.now().add(_resendCooldown),
      otpSessionVersion: state.otpSessionVersion + 1,
      backendLoginCompleted: false,
    );
  }

  void _completeOtpLogin(AuthSession session) {
    _verifyGeneration++;
    _verifyInFlight = false;
    _backendLoginInFlight = false;
    _resendInFlight = false;
    AuthFlowLogger.reset();
    final nextStatus = _statusForSession(session);
    _setAuthStatus(nextStatus);
    state = state.copyWith(
      otpPhase: OtpPhase.idle,
      session: session,
      phone: session.user.phone,
      clearReqId: true,
      clearError: true,
      clearResendTimer: true,
      clearMsg91Token: true,
      backendLoginCompleted: true,
    );
  }

  Future<void> _completeMockOtpLogin() async {
    final digits = state.phone.replaceAll(RegExp(r'\D'), '');
    final phone = digits.length == 10 ? '91$digits' : digits;

    final session = AuthSession(
      accessToken: OtpService.mockAccessToken,
      refreshToken: 'mock-refresh-token',
      expiresIn: 900,
      user: AuthUser(
        id: 'local-user',
        phone: phone,
        name: 'User',
        role: 'owner',
      ),
      businesses: const [
        BusinessSummary(
          id: 'local-business',
          name: 'My Business',
          role: 'owner',
        ),
      ],
    );

    try {
      final service = await _service();
      await service.persistSession(session);
    } catch (_) {
      // Best-effort until backend login is wired.
    }

    _completeOtpLogin(session);
  }

  void _resetOtpFlow() {
    _verifyGeneration++;
    _verifyInFlight = false;
    _backendLoginInFlight = false;
    _resendInFlight = false;
    _sendInFlight = false;
    AuthFlowLogger.reset();
    state = state.copyWith(
      otpPhase: OtpPhase.idle,
      clearReqId: true,
      clearError: true,
      clearResendTimer: true,
      clearMsg91Token: true,
      backendLoginCompleted: false,
      otpSessionVersion: state.otpSessionVersion + 1,
    );
  }

  void _onBackendLoginFailed(int generation, String specificMessage) {
    if (generation != _verifyGeneration || state.backendLoginCompleted) {
      return;
    }
    _verifyInFlight = false;
    _backendLoginInFlight = false;
    _setOtpPhase(OtpPhase.backendLoginFailed);
    state = state.copyWith(
      error: _formatBackendLoginFailureMessage(specificMessage),
      clearResendTimer: true,
    );
  }

  String _formatBackendLoginFailureMessage(String specificMessage) {
    return '$specificMessage\n\nYour OTP has already been verified.\n\nPlease retry when the server becomes available.';
  }

  Future<void> _attemptBackendLogin(int generation) async {
    if (generation != _verifyGeneration || state.backendLoginCompleted) {
      return;
    }

    _setOtpPhase(OtpPhase.backendLogin);
    state = state.copyWith(clearError: true, clearResendTimer: true);

    final token = state.msg91AccessToken;
    if (token == null || token.isEmpty) {
      _onBackendLoginFailed(generation, 'Something went wrong.');
      return;
    }

    try {
      final healthy = await ref.read(authRepositoryProvider).checkHealth();
      if (generation != _verifyGeneration) return;

      if (!healthy) {
        _onBackendLoginFailed(
          generation,
          'Billing Baba server is currently unavailable.',
        );
        return;
      }

      final service = await _service();
      final session = await service.loginWithMsg91Token(
        msg91AccessToken: token,
        phone: state.phone,
      );

      if (generation != _verifyGeneration) return;

      _completeOtpLogin(session);
    } on DioException catch (e) {
      if (generation != _verifyGeneration || state.backendLoginCompleted) {
        return;
      }
      _onBackendLoginFailed(generation, _backendLoginErrorMessage(e));
    } catch (e) {
      if (generation != _verifyGeneration || state.backendLoginCompleted) {
        return;
      }
      _onBackendLoginFailed(generation, _backendLoginErrorMessage(e));
    } finally {
      if (!state.backendLoginCompleted &&
          state.otpPhase != OtpPhase.backendLogin) {
        _verifyInFlight = false;
        _backendLoginInFlight = false;
      }
    }
  }

  Future<void> tryAutoLogin() async {
    _setAuthStatus(AuthStatus.initializing);
    state = state.copyWith(clearError: true);

    try {
      final service = await _service().timeout(const Duration(seconds: 8));
      final sessionFuture = service.loadStoredSession().timeout(
        const Duration(seconds: 8),
      );
      final results = await Future.wait<Object?>([
        Future<void>.delayed(_splashMinDuration),
        sessionFuture,
      ]);
      final session = results[1] as AuthSession?;
      if (session == null) {
        _setAuthStatus(AuthStatus.unauthenticated);
        state = state.copyWith(clearSession: true, otpPhase: OtpPhase.idle);
        return;
      }

      final nextStatus = _statusForSession(session);
      _setAuthStatus(nextStatus);
      state = state.copyWith(
        session: session,
        phone: session.user.phone,
        otpPhase: OtpPhase.idle,
        backendLoginCompleted: true,
      );
    } on TimeoutException {
      await Future<void>.delayed(_splashMinDuration);
      _setAuthStatus(AuthStatus.unauthenticated);
      state = state.copyWith(clearSession: true, otpPhase: OtpPhase.idle);
    } catch (e) {
      await Future<void>.delayed(_splashMinDuration);
      _setAuthStatus(AuthStatus.unauthenticated);
      state = state.copyWith(
        clearSession: true,
        otpPhase: OtpPhase.idle,
        error: _messageFromError(e),
      );
    }
  }

  Future<void> sendOtp(String phone) async {
    if (_sendInFlight || !state.canSendOtp) return;

    _sendInFlight = true;
    _setOtpPhase(OtpPhase.sendingOtp);
    state = state.copyWith(
      phone: phone,
      clearError: true,
      clearReqId: true,
      clearResendTimer: true,
      backendLoginCompleted: false,
    );

    try {
      final reqId = await _otp.sendOtp(phone).timeout(_sendTimeout);
      _onOtpSent(reqId, phone: phone);
    } on TimeoutException {
      _setOtpPhase(OtpPhase.idle);
      _setAuthStatus(AuthStatus.unauthenticated);
      state = state.copyWith(
        clearReqId: true,
        error: "Couldn't send OTP. Please check your connection.",
      );
    } on OtpException catch (e) {
      _setOtpPhase(OtpPhase.idle);
      _setAuthStatus(AuthStatus.unauthenticated);
      state = state.copyWith(clearReqId: true, error: e.message);
    } catch (e) {
      _setOtpPhase(OtpPhase.idle);
      _setAuthStatus(AuthStatus.unauthenticated);
      state = state.copyWith(
        clearReqId: true,
        error: _messageFromError(e),
      );
    } finally {
      _sendInFlight = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (_verifyInFlight || state.backendLoginCompleted || !state.canVerifyOtp) {
      return;
    }

    final reqId = state.reqId;
    if (reqId.isEmpty) {
      state = state.copyWith(
        error: 'Session expired. Go back and request a new OTP.',
      );
      return;
    }

    _verifyInFlight = true;
    final generation = ++_verifyGeneration;
    _setOtpPhase(OtpPhase.verifyingOtp);
    state = state.copyWith(clearError: true);

    try {
      final msg91Token = await _otp.verifyOtp(reqId: reqId, otp: otp);

      if (generation != _verifyGeneration ||
          state.backendLoginCompleted ||
          !_verifyInFlight) {
        return;
      }

      if (_otp.isMockMode && msg91Token == OtpService.mockAccessToken) {
        await _completeMockOtpLogin();
        return;
      }

      state = state.copyWith(msg91AccessToken: msg91Token);
      await _attemptBackendLogin(generation);
    } on OtpException catch (e) {
      if (state.backendLoginCompleted || generation != _verifyGeneration) {
        return;
      }
      if (e.isConsumed) {
        if (state.backendLoginCompleted) return;
        state = state.copyWith(
          otpPhase: OtpPhase.error,
          error: e.message,
          clearReqId: true,
        );
        return;
      }
      _setOtpPhase(OtpPhase.otpSent);
      state = state.copyWith(
        error: e.isNetwork
            ? 'Please check your internet connection.'
            : e.message,
      );
    } catch (e) {
      if (state.backendLoginCompleted || generation != _verifyGeneration) {
        return;
      }
      _setOtpPhase(OtpPhase.otpSent);
      state = state.copyWith(error: _messageFromError(e));
    } finally {
      if (!state.backendLoginCompleted &&
          state.otpPhase != OtpPhase.backendLogin) {
        _verifyInFlight = false;
      }
    }
  }

  Future<void> retryBackendLogin() async {
    if (_backendLoginInFlight ||
        _verifyInFlight ||
        !state.canRetryBackendLogin) {
      return;
    }

    _backendLoginInFlight = true;
    final generation = _verifyGeneration;
    await _attemptBackendLogin(generation);
  }

  Future<void> devLogin() async {
    if (_devLoginInFlight || state.backendLoginCompleted) return;

    _devLoginInFlight = true;
    debugPrint('[DEV_LOGIN] Request started');
    state = state.copyWith(clearError: true);
    _setOtpPhase(OtpPhase.backendLogin);

    try {
      final service = await _service();
      final session = await service.devLogin();
      debugPrint('[DEV_LOGIN] Login successful');
      _completeOtpLogin(session);
    } on DioException catch (e) {
      debugPrint('[DEV_LOGIN] Failed: ${e.response?.statusCode ?? 'network'}');
      _setOtpPhase(OtpPhase.idle);
      state = state.copyWith(error: _devLoginErrorMessage(e));
    } catch (e) {
      debugPrint('[DEV_LOGIN] Failed: unknown');
      _setOtpPhase(OtpPhase.idle);
      state = state.copyWith(error: _devLoginErrorMessage(e));
    } finally {
      _devLoginInFlight = false;
    }
  }

  Future<void> resendOtp() async {
    if (_resendInFlight || !state.canResendOtp || state.backendLoginCompleted) {
      return;
    }

    final phone = state.phone;
    if (phone.isEmpty) return;

    _resendInFlight = true;
    _setOtpPhase(OtpPhase.sendingOtp);
    state = state.copyWith(clearError: true);

    try {
      String reqId;
      try {
        reqId = await _otp.retryOtp(state.reqId);
      } on OtpException catch (e) {
        if (!e.isConsumed) rethrow;
        reqId = await _otp.sendOtp(phone).timeout(_sendTimeout);
      }

      _onOtpSent(reqId, phone: phone);
    } on TimeoutException {
      _setOtpPhase(OtpPhase.otpSent);
      state = state.copyWith(
        error: "Couldn't send OTP. Please check your connection.",
      );
    } on OtpException catch (e) {
      _setOtpPhase(OtpPhase.otpSent);
      state = state.copyWith(error: e.message);
    } catch (e) {
      _setOtpPhase(OtpPhase.otpSent);
      state = state.copyWith(error: _messageFromError(e));
    } finally {
      _resendInFlight = false;
    }
  }

  void resetToLogin() {
    _resetOtpFlow();
    _setAuthStatus(AuthStatus.unauthenticated);
    state = state.copyWith(phone: '');
  }

  Future<void> selectBusiness(String businessId) async {
    final refreshToken = state.session?.refreshToken;
    if (refreshToken == null) return;

    state = state.copyWith(clearError: true);
    try {
      final service = await _service();
      final session = await service.selectBusiness(
        businessId: businessId,
        refreshToken: refreshToken,
      );
      if (!_hasBusinessScope(session)) {
        state = state.copyWith(
          error: 'Could not select business. Please try again.',
        );
        return;
      }
      _setAuthStatus(AuthStatus.authenticated);
      state = state.copyWith(session: session);
      await _invalidateBusinessProviders();
    } catch (e) {
      state = state.copyWith(error: _messageFromError(e));
    }
  }

  Future<void> enterBusinessSelection() async {
    final refreshToken = state.session?.refreshToken;
    if (refreshToken == null) return;

    state = state.copyWith(clearError: true);
    try {
      await _clearBusinessScopedCaches();
      final service = await _service();
      final session = await service.refreshStoredSession(
        refreshToken: refreshToken,
        preserveBusinessScope: false,
      );
      if (session == null) {
        _setAuthStatus(AuthStatus.unauthenticated);
        state = state.copyWith(clearSession: true);
        return;
      }
      _setAuthStatus(AuthStatus.needsBusinessSelection);
      state = state.copyWith(session: session);
    } catch (e) {
      state = state.copyWith(error: _messageFromError(e));
    }
  }

  void patchBusinessFromProfile({
    required String businessId,
    required String name,
    String? gstin,
  }) {
    final session = state.session;
    if (session == null) return;

    final businesses = session.businesses
        .map(
          (business) => business.id == businessId
              ? business.copyWith(name: name, gstin: gstin)
              : business,
        )
        .toList();

    state = state.copyWith(
      session: session.copyWith(businesses: businesses),
    );
  }

  Future<void> refreshBusinesses() async {
    final accessToken = state.session?.accessToken;
    if (accessToken == null) return;

    try {
      final me = await ref.read(authRepositoryProvider).me(accessToken);
      final current = state.session;
      if (current == null) return;

      final updated = current.copyWith(
        user: me.user,
        businesses: me.businesses,
      );
      _setAuthStatus(_statusForSession(updated));
      state = state.copyWith(session: updated);
    } on DioException {
      // Keep existing session on network failure.
    }
  }

  Future<AuthSession?> refreshAccessToken({String? businessId}) async {
    try {
      final service = await _service();
      final session = await service.refreshStoredSession(
        businessId: businessId,
      );
      if (session != null) {
        _setAuthStatus(_statusForSession(session));
        state = state.copyWith(session: session);
      }
      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final service = await _service();
      await service.logout();
      await _invalidateBusinessProviders(includeList: true);
    } finally {
      AuthFlowLogger.reset();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  String _backendLoginErrorMessage(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Server is taking too long to respond.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect to Billing Baba server.';
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return 'Billing Baba server encountered an error.';
      }
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['code']?.toString();
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return _mapApiErrorMessage(code, message);
        }
      }
    }
    if (error.toString().contains('SocketException')) {
      return 'Unable to connect to Billing Baba server.';
    }
    return 'Something went wrong.';
  }

  String _messageFromError(Object error) {
    if (error is OtpException) {
      return error.isNetwork
          ? 'Please check your internet connection.'
          : error.message;
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
        return 'Please check your internet connection.';
      }
    }
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring('Exception: '.length);
      }
    }
    return 'Something went wrong. Please try again.';
  }

  String _devLoginErrorMessage(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 404:
          return 'Developer Login is disabled.';
        case 401:
          return 'Developer Login is not available.';
        case 500:
          return 'Unable to sign in using Developer Login.';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Please check your internet connection.';
      }
    }
    return 'Unable to sign in using Developer Login.';
  }

  String _mapApiErrorMessage(String? code, String message) {
    switch (code) {
      case 'MSG91_VERIFICATION_FAILED':
        return 'MSG91 verification failed. Please try again.';
      case 'AUTH_NOT_CONFIGURED':
        return 'Authentication is not configured on the server.';
      case 'VALIDATION_ERROR':
        return 'Invalid login request. Please try again.';
      default:
        if (message.toLowerCase().contains('phone number')) {
          return 'Could not complete sign-in. Please try again.';
        }
        return message;
    }
  }
}
