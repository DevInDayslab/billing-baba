import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/network/business_selection_retry_guard.dart';
import 'package:billing_baba/core/network/network_diagnostics_service.dart';
import 'package:billing_baba/core/network/network_error_details.dart';
import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/services/session_cache_cleanup.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/models/auth_user.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/auth/models/otp_phase.dart';
import 'package:billing_baba/features/auth/repositories/auth_repository.dart';
import 'package:billing_baba/features/auth/services/auth_service.dart';
import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:billing_baba/features/auth/utils/auth_debug_logger.dart';
import 'package:billing_baba/features/auth/utils/auth_flow_logger.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/business/utils/business_open_debug_log.dart';
import 'package:billing_baba/features/business/utils/switch_company_debug_log.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/shared/utils/jwt_utils.dart';
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

/// Auth inputs that should restart [businessProfileProvider].
typedef BusinessProfileAuthScope = (
  AuthStatus status,
  String? userId,
  String? userRole,
);

BusinessProfileAuthScope businessProfileAuthScope(AuthState auth) {
  final session = auth.session;
  return (auth.status, session?.user.id, session?.user.role);
}

bool businessProfileHasScope(BusinessProfileAuthScope scope) {
  final (status, _, userRole) = scope;
  return status == AuthStatus.authenticated &&
      userRole != null &&
      userRole.isNotEmpty;
}

@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.initializing,
    this.otpPhase = OtpPhase.idle,
    this.phone = '',
    this.reqId = '',
    this.msg91AccessToken,
    this.error,
    this.networkError,
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
  final NetworkErrorDetails? networkError;
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
    NetworkErrorDetails? networkError,
    AuthSession? session,
    DateTime? resendAvailableAt,
    int? otpSessionVersion,
    bool? backendLoginCompleted,
    bool clearError = false,
    bool clearNetworkError = false,
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
      networkError: clearNetworkError
          ? null
          : networkError ?? this.networkError,
      session: clearSession ? null : session ?? this.session,
      resendAvailableAt: clearResendTimer
          ? null
          : resendAvailableAt ?? this.resendAvailableAt,
      otpSessionVersion: otpSessionVersion ?? this.otpSessionVersion,
      backendLoginCompleted:
          backendLoginCompleted ?? this.backendLoginCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.otpPhase == otpPhase &&
        other.phone == phone &&
        other.reqId == reqId &&
        other.msg91AccessToken == msg91AccessToken &&
        other.error == error &&
        _networkErrorEquals(other.networkError, networkError) &&
        other.session == session &&
        other.resendAvailableAt == resendAvailableAt &&
        other.otpSessionVersion == otpSessionVersion &&
        other.backendLoginCompleted == backendLoginCompleted;
  }

  @override
  int get hashCode => Object.hash(
    status,
    otpPhase,
    phone,
    reqId,
    msg91AccessToken,
    error,
    networkError?.title,
    networkError?.reason,
    networkError?.details,
    networkError?.host,
    networkError?.httpStatus,
    session,
    resendAvailableAt,
    otpSessionVersion,
    backendLoginCompleted,
  );
}

bool _networkErrorEquals(
  NetworkErrorDetails? a,
  NetworkErrorDetails? b,
) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  return a.title == b.title &&
      a.reason == b.reason &&
      a.details == b.details &&
      a.host == b.host &&
      a.httpStatus == b.httpStatus;
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
  Future<void> _businessSelectionChain = Future<void>.value();

  @override
  AuthState build() {
    if (!_autoLoginStarted) {
      _autoLoginStarted = true;
      unawaited(Future.microtask(tryAutoLogin));
    }
    return const AuthState();
  }

  Future<AuthService> _service() => ref.read(authServiceProvider.future);
  OtpService get _otp => ref.read(otpServiceProvider);

  void _commitState(AuthState next) {
    if (next == state) return;
    state = next;
  }

  void _setOtpPhase(OtpPhase phase) {
    AuthFlowLogger.otpTransition(phase);
    _commitState(state.copyWith(otpPhase: phase));
  }

  void _setAuthStatus(AuthStatus status) {
    AuthFlowLogger.authStatus(status.name);
    _commitState(state.copyWith(status: status));
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
    invalidateAllBusinessScopedProviders(
      ref,
      includeBusinessList: includeList,
    );
  }

  Future<void> _clearActiveBusinessSession() async {
    final storage = await ref.read(storageServiceProvider.future);
    await SessionCacheCleanup(storage).clearActiveBusinessSession();
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
    // Drop any leftover company session from a prior login so GoRouter can
    // navigate off /login when status is needsBusinessSelection.
    ref.read(companySessionProvider.notifier).clear();
    final nextStatus = _statusForSession(session);
    if (nextStatus == AuthStatus.needsBusinessSelection ||
        nextStatus == AuthStatus.needsBusinessCreation) {
      ref.read(companySessionProvider.notifier).clear();
    }
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
    } on Object catch (_) {
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

  void _onBackendLoginFailed(
    int generation,
    String specificMessage, {
    NetworkErrorDetails? networkError,
  }) {
    if (generation != _verifyGeneration || state.backendLoginCompleted) {
      return;
    }
    _verifyInFlight = false;
    _backendLoginInFlight = false;
    _setOtpPhase(OtpPhase.backendLoginFailed);
    state = state.copyWith(
      error: _formatBackendLoginFailureMessage(
        networkError?.title ?? specificMessage,
      ),
      networkError: networkError,
      clearResendTimer: true,
    );
  }

  String _formatBackendLoginFailureMessage(String specificMessage) {
    if (state.msg91AccessToken != null && state.msg91AccessToken!.isNotEmpty) {
      return '$specificMessage\n\nYour OTP is already verified — tap Retry to complete sign-in.';
    }
    return specificMessage;
  }

  Future<void> _attemptBackendLogin(int generation) async {
    if (generation != _verifyGeneration || state.backendLoginCompleted) {
      AuthDebugLogger.log(
        '_attemptBackendLogin skipped: generation=$generation '
        'current=$_verifyGeneration completed=${state.backendLoginCompleted}',
      );
      return;
    }

    AuthDebugLogger.log(
      '_attemptBackendLogin entered phone=${AuthDebugLogger.maskPhone(state.phone)} '
      'apiBaseUrl=${AppConfig.apiBaseUrl}',
    );

    _setOtpPhase(OtpPhase.backendLogin);
    state = state.copyWith(clearError: true, clearResendTimer: true);

    final token = state.msg91AccessToken;
    if (token == null || token.isEmpty) {
      AuthDebugLogger.log('_attemptBackendLogin aborted: missing MSG91 token');
      _onBackendLoginFailed(generation, 'Something went wrong.');
      return;
    }

    try {
      AuthDebugLogger.log('_attemptBackendLogin: running health check');
      final healthy = await ref.read(authRepositoryProvider).checkHealth();
      if (generation != _verifyGeneration) return;

      if (!healthy) {
        AuthDebugLogger.log(
          '_attemptBackendLogin aborted: health check failed — login POST not sent',
        );
        _onBackendLoginFailed(
          generation,
          'Billing Baba server is currently unavailable.',
        );
        return;
      }

      AuthDebugLogger.log('_attemptBackendLogin: calling loginWithMsg91Token');
      final service = await _service();
      final session = await service.loginWithMsg91Token(
        msg91AccessToken: token,
        phone: state.phone,
      );

      if (generation != _verifyGeneration) return;

      AuthDebugLogger.log('_attemptBackendLogin: login succeeded');
      _completeOtpLogin(session);
    } on DioException catch (e, st) {
      if (generation != _verifyGeneration || state.backendLoginCompleted) {
        return;
      }
      AuthDebugLogger.log('_attemptBackendLogin DioException: $e');
      if (AppConfig.authDebugLogging) {
        debugPrint('[AUTH] _attemptBackendLogin stackTrace:\n$st');
      }
      _onBackendLoginFailed(
        generation,
        _backendLoginErrorMessage(e),
        networkError: NetworkExceptionClassifier.classify(
          e,
          host: NetworkExceptionClassifier.hostFromApiUrl(),
        ),
      );
    } on Object catch (e, st) {
      if (generation != _verifyGeneration || state.backendLoginCompleted) {
        return;
      }
      AuthDebugLogger.log('_attemptBackendLogin exception: $e');
      if (AppConfig.authDebugLogging) {
        debugPrint('[AUTH] _attemptBackendLogin stackTrace:\n$st');
      }
      _onBackendLoginFailed(
        generation,
        _backendLoginErrorMessage(e),
        networkError: NetworkExceptionClassifier.classify(
          e,
          host: NetworkExceptionClassifier.hostFromApiUrl(),
        ),
      );
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
    state = state.copyWith(clearError: true, backendLoginCompleted: false);

    // Keep branded splash visible for the full animation on all platforms.
    final splashWait = Future<void>.delayed(_splashMinDuration);

    try {
      final service = await _service().timeout(const Duration(seconds: 8));
      final sessionFuture = service.loadStoredSession().timeout(
        const Duration(seconds: 8),
      );
      final results = await Future.wait<Object?>([
        splashWait,
        sessionFuture,
      ]);
      final session = results[1] as AuthSession?;
      if (session == null) {
        _setAuthStatus(AuthStatus.unauthenticated);
        state = state.copyWith(
          clearSession: true,
          otpPhase: OtpPhase.idle,
          backendLoginCompleted: false,
        );
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
      if (AuthService.isOfflineDevSession(session)) {
        // Bootstrap must not wipe a restored session — failures are best-effort.
        try {
          await _bootstrapOfflineDevSession(session);
        } on Object catch (e, st) {
          LoggingService.instance.error(
            'Offline dev session bootstrap failed during auto-login',
            e,
            st,
          );
        }
      }
    } on TimeoutException {
      await splashWait;
      _setAuthStatus(AuthStatus.unauthenticated);
      state = state.copyWith(
        clearSession: true,
        otpPhase: OtpPhase.idle,
        backendLoginCompleted: false,
      );
    } on Object catch (e, st) {
      await splashWait;
      LoggingService.instance.error('tryAutoLogin failed', e, st);
      _setAuthStatus(AuthStatus.unauthenticated);
      state = state.copyWith(
        clearSession: true,
        otpPhase: OtpPhase.idle,
        backendLoginCompleted: false,
        error: _messageFromError(e),
      );
    }
  }

  Future<void> sendOtp(String phone) async {
    if (_sendInFlight || !state.canSendOtp) return;

    final maskedPhone = LoggingService.maskPhone(phone);
    LoggingService.instance.info(
      'sendOtp: login button pressed phone=$maskedPhone',
    );
    AuthDebugLogger.log(
      'sendOtp: login button pressed phone=${AuthDebugLogger.maskPhone(phone)}',
    );

    _sendInFlight = true;
    _setOtpPhase(OtpPhase.sendingOtp);
    state = state.copyWith(
      phone: phone,
      clearError: true,
      clearNetworkError: true,
      clearReqId: true,
      clearResendTimer: true,
      backendLoginCompleted: false,
    );

    final stopwatch = Stopwatch()..start();

    try {
      if (AppConfig.diagnosticsEnabled) {
        final connectivity = NetworkDiagnosticsService();
        final testResult = await connectivity.runConnectivityTest();
        LoggingService.instance.info(
          'Pre-OTP connectivity test: $testResult',
        );
        if (!testResult.success) {
          LoggingService.instance.warn(
            'Backend unreachable before OTP — MSG91 send will still be attempted',
          );
        }
      }

      LoggingService.instance.info('Sending OTP request...');
      final reqId = await _otp.sendOtp(phone).timeout(_sendTimeout);
      stopwatch.stop();
      LoggingService.instance.info(
        'OTP request succeeded duration=${stopwatch.elapsed.inMilliseconds}ms',
      );
      _onOtpSent(reqId, phone: phone);
    } on TimeoutException catch (e, st) {
      stopwatch.stop();
      _handleSendOtpFailure(
        e,
        st,
        phone: phone,
        duration: stopwatch.elapsed,
      );
    } on OtpException catch (e, st) {
      stopwatch.stop();
      if (e.isNetwork || e.cause != null) {
        _handleSendOtpFailure(
          e.cause ?? e,
          st,
          phone: phone,
          duration: stopwatch.elapsed,
        );
      } else {
        _setOtpPhase(OtpPhase.idle);
        _setAuthStatus(AuthStatus.unauthenticated);
        state = state.copyWith(clearReqId: true, error: e.message);
      }
    } on Object catch (e, st) {
      stopwatch.stop();
      _handleSendOtpFailure(
        e,
        st,
        phone: phone,
        duration: stopwatch.elapsed,
      );
    } finally {
      _sendInFlight = false;
    }
  }

  void _handleSendOtpFailure(
    Object error,
    StackTrace stackTrace, {
    required String phone,
    required Duration duration,
    bool keepOtpSent = false,
  }) {
    final details = NetworkExceptionClassifier.classify(
      error,
      host: NetworkExceptionClassifier.hostFromApiUrl(),
      duration: duration,
    );

    LoggingService.instance.error(
      'sendOtp failed phone=${LoggingService.maskPhone(phone)} '
      'duration=${duration.inMilliseconds}ms\n'
      'Reason: ${details.reason}\n'
      'Details: ${details.details}',
      error,
      stackTrace,
    );

    if (keepOtpSent) {
      state = state.copyWith(
        error: details.title,
        networkError: details,
      );
      return;
    }

    _setOtpPhase(OtpPhase.idle);
    _setAuthStatus(AuthStatus.unauthenticated);
    state = state.copyWith(
      clearReqId: true,
      error: details.title,
      networkError: details,
      backendLoginCompleted: false,
    );
  }

  Future<void> verifyOtp(String otp) async {
    if (_verifyInFlight || state.backendLoginCompleted || !state.canVerifyOtp) {
      AuthDebugLogger.log(
        'verifyOtp skipped: inFlight=$_verifyInFlight '
        'completed=${state.backendLoginCompleted} canVerify=${state.canVerifyOtp}',
      );
      return;
    }

    AuthDebugLogger.log(
      'verifyOtp: OTP collected length=${otp.length} '
      'phone=${AuthDebugLogger.maskPhone(state.phone)}',
    );

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
      AuthDebugLogger.log('verifyOtp: calling MSG91 SDK');
      final msg91Token = await _otp.verifyOtp(reqId: reqId, otp: otp);

      if (generation != _verifyGeneration ||
          state.backendLoginCompleted ||
          !_verifyInFlight) {
        return;
      }

      if (_otp.isMockMode && msg91Token == OtpService.mockAccessToken) {
        AuthDebugLogger.log(
          'verifyOtp: mock mode — completing local login without backend POST',
        );
        await _completeMockOtpLogin();
        return;
      }

      AuthDebugLogger.log(
        'verifyOtp: MSG91 token received '
        '${AuthDebugLogger.maskToken(msg91Token)}',
      );
      state = state.copyWith(msg91AccessToken: msg91Token);
      await _attemptBackendLogin(generation);
    } on OtpException catch (e, st) {
      AuthDebugLogger.log(
        'verifyOtp OtpException: ${e.message} code=${e.code}',
      );
      if (AppConfig.authDebugLogging) {
        debugPrint('[AUTH] verifyOtp stackTrace:\n$st');
      }
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
    } on Object catch (e, st) {
      AuthDebugLogger.log('verifyOtp exception: $e');
      if (AppConfig.authDebugLogging) {
        debugPrint('[AUTH] verifyOtp stackTrace:\n$st');
      }
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
    LoggingService.instance.info(
      'Developer Login pressed '
      '(inFlight=$_devLoginInFlight completed=${state.backendLoginCompleted} '
      'status=${state.status.name})',
    );

    // Login screen: recover from a stuck in-flight flag (hung prior attempt /
    // hot reload) or a leftover backendLoginCompleted after a failed auto-login.
    if (state.status == AuthStatus.unauthenticated) {
      _devLoginInFlight = false;
      state = state.copyWith(backendLoginCompleted: false);
    }

    if (_devLoginInFlight) {
      LoggingService.instance.warn('Developer Login ignored: already in flight');
      return;
    }
    if (state.status == AuthStatus.authenticated ||
        state.status == AuthStatus.needsBusinessSelection ||
        state.status == AuthStatus.needsBusinessCreation) {
      LoggingService.instance.info(
        'Developer Login ignored: already signed in (${state.status.name})',
      );
      return;
    }

    _devLoginInFlight = true;
    AuthDebugLogger.log('devLogin: API /auth/dev-login (offline fallback if unreachable)');
    state = state.copyWith(clearError: true, backendLoginCompleted: false);
    _setOtpPhase(OtpPhase.backendLogin);

    try {
      final service = await _service();
      final session = await service.devLogin();
      AuthDebugLogger.log('devLogin: login successful');
      LoggingService.instance.info('Developer Login succeeded');
      _completeOtpLogin(session);
      try {
        if (AuthService.isOfflineDevSession(session)) {
          await _bootstrapOfflineDevSession(session);
        } else if (session.businesses.length == 1 &&
            _statusForSession(session) == AuthStatus.authenticated) {
          // Same path as opening a company after OTP — hydrate profile, masters,
          // and start sync so mobile/desktop share API data.
          await ref
              .read(businessListProvider.notifier)
              .openBusiness(session.businesses.first.id);
        }
      } on Object catch (e, st) {
        LoggingService.instance.error(
          'Post-login bootstrap failed after Developer Login',
          e,
          st,
        );
      }
    } on Object catch (e, st) {
      AuthDebugLogger.log('devLogin failed: $e');
      LoggingService.instance.error('Developer Login failed', e, st);
      if (AppConfig.authDebugLogging) {
        debugPrint('[AUTH] devLogin stackTrace:\n$st');
      }
      _setOtpPhase(OtpPhase.idle);
      state = state.copyWith(
        error: _devLoginErrorMessage(e),
        backendLoginCompleted: false,
      );
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
        if (e.isNetwork) rethrow;
        AuthDebugLogger.log(
          'retryOtp failed (${e.message}); falling back to sendOtp',
        );
        reqId = await _otp.sendOtp(phone).timeout(_sendTimeout);
      }

      _onOtpSent(reqId, phone: phone);
    } on TimeoutException catch (e, st) {
      _setOtpPhase(OtpPhase.otpSent);
      _handleSendOtpFailure(
        e,
        st,
        phone: phone,
        duration: const Duration(seconds: 20),
        keepOtpSent: true,
      );
    } on OtpException catch (e, st) {
      if (e.isNetwork || e.cause != null) {
        _setOtpPhase(OtpPhase.otpSent);
        _handleSendOtpFailure(
          e.cause ?? e,
          st,
          phone: phone,
          duration: Duration.zero,
          keepOtpSent: true,
        );
      } else {
        _setOtpPhase(OtpPhase.otpSent);
        state = state.copyWith(error: e.message);
      }
    } on Object catch (e, st) {
      _setOtpPhase(OtpPhase.otpSent);
      _handleSendOtpFailure(
        e,
        st,
        phone: phone,
        duration: Duration.zero,
        keepOtpSent: true,
      );
    } finally {
      _resendInFlight = false;
    }
  }

  void resetToLogin() {
    _devLoginInFlight = false;
    _resetOtpFlow();
    _setAuthStatus(AuthStatus.unauthenticated);
    state = state.copyWith(phone: '', backendLoginCompleted: false);
  }

  Future<void> _bootstrapOfflineDevSession(AuthSession session) async {
    if (!AuthService.isOfflineDevSession(session) ||
        session.businesses.isEmpty) {
      return;
    }

    final businessSummary = session.businesses.first;
    final user = session.user;

    final businessService = await ref.read(businessServiceProvider.future);
    await businessService.seedOfflineDevSession(session);

    final profile = AuthService.offlineDevBusinessProfile(session);
    final companySession = CompanySession.owner(
      entry: CompanyListEntry(
        id: businessSummary.id,
        name: businessSummary.name,
        relationship: CompanyRelationship.owner,
        syncStatus: business.SyncStatus.on,
        source: CompanyListSource.apiOwned,
        ownerName: user.name,
        phone: user.phone,
      ),
      userId: user.id,
      userName: user.name ?? 'Developer',
      userPhone: user.phone,
    );

    // Defer writes — businessProfileProvider watches authProvider, so updating
    // it synchronously inside Auth.devLogin trips a circular dependency.
    await Future<void>.delayed(Duration.zero);
    if (!ref.mounted) return;
    ref.read(businessProfileProvider.notifier).replaceWith(profile);
    ref.read(companySessionProvider.notifier).setSession(companySession);
  }

  Future<void> selectBusiness(String businessId) {
    if (BusinessSelectionRetryGuard.isBlocked(businessId)) {
      BusinessSelectionRetryGuard.logBlockedOnce('selectBusiness', businessId);
      return Future<void>.value();
    }

    final operation = _businessSelectionChain
        .catchError((_) {})
        .then((_) => _selectBusinessInternal(businessId));
    _businessSelectionChain = operation;
    return operation;
  }

  Future<void> _selectBusinessInternal(String businessId) async {
    if (BusinessSelectionRetryGuard.isBlocked(businessId)) {
      return;
    }

    BusinessOpenDebugLog.step('selectBusiness', 'begin id=$businessId');
    final refreshToken = state.session?.refreshToken;
    if (refreshToken == null) {
      throw const BusinessSelectionFailed(
        'Session expired. Please sign in again.',
      );
    }

    final storage = await ref.read(storageServiceProvider.future);
    final accessToken = await storage.readSecure(StorageKeys.accessToken);
    if (accessToken != null && AuthService.isOfflineDevToken(accessToken)) {
      BusinessOpenDebugLog.step(
        'selectBusiness',
        'offline dev — local scope only',
      );
      final service = await _service();
      await service.persistSession(state.session!, businessId: businessId);
      _setAuthStatus(AuthStatus.authenticated);
      return;
    }

    if (await _isJwtScopedToBusiness(businessId)) {
      BusinessOpenDebugLog.step(
        'selectBusiness',
        'JWT already scoped — skip refresh',
      );
      await _syncSessionRoleFromJwt();
      BusinessSelectionRetryGuard.recordSuccess(businessId);
      if (state.status != AuthStatus.authenticated) {
        _setAuthStatus(AuthStatus.authenticated);
      }
      return;
    }

    BusinessOpenDebugLog.step(
      'selectBusiness',
      'JWT refresh API (retryCount=${BusinessSelectionRetryGuard.retryCount})',
    );
    try {
      final service = await _service();
      final session = await service.selectBusiness(
        businessId: businessId,
        refreshToken: refreshToken,
      );
      if (!_hasBusinessScope(session)) {
        throw const BusinessSelectionFailed(
          'Could not select business. Please try again.',
        );
      }
      AuthFlowLogger.authStatus(AuthStatus.authenticated.name);
      _commitState(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearError: true,
        ),
      );
      BusinessSelectionRetryGuard.recordSuccess(businessId);
      BusinessOpenDebugLog.step('selectBusiness', 'JWT refresh done');
    } on BusinessSelectionFailed {
      BusinessOpenDebugLog.step(
        'selectBusiness',
        'failed (BusinessSelectionFailed)',
      );
      rethrow;
    } on Object catch (e) {
      if (NetworkExceptionClassifier.isConnectivityError(e)) {
        BusinessSelectionRetryGuard.recordConnectivityFailure(businessId, e);
      }
      BusinessOpenDebugLog.step('selectBusiness', 'failed ($e)');
      throw BusinessSelectionFailed(_messageFromError(e));
    }
  }

  Future<bool> _isJwtScopedToBusiness(String businessId) async {
    final storage = await ref.read(storageServiceProvider.future);
    final token = await storage.readSecure(StorageKeys.accessToken);
    if (token != null && AuthService.isOfflineDevToken(token)) {
      final selected = await storage.readSecure(StorageKeys.selectedBusinessId);
      return selected == businessId;
    }

    final jwtBusinessId = JwtUtils.businessId(token);
    final role = JwtUtils.role(token);
    return jwtBusinessId == businessId && role != null && role.isNotEmpty;
  }

  /// Keeps session user role aligned with the scoped JWT when refresh is skipped.
  Future<void> _syncSessionRoleFromJwt() async {
    final session = state.session;
    if (session == null || session.user.role != null) return;

    final storage = await ref.read(storageServiceProvider.future);
    final token = await storage.readSecure(StorageKeys.accessToken);
    final role = JwtUtils.role(token);
    if (role == null || role.isEmpty) return;

    _commitState(
      state.copyWith(
        session: session.copyWith(
          user: session.user.copyWith(role: role),
        ),
      ),
    );
  }

  /// Scopes JWT to [businessId] for edit-from-list without invalidating providers.
  Future<bool> selectBusinessForEdit(String businessId) async {
    try {
      await selectBusiness(businessId);
      if (!_hasBusinessScope(state.session)) return false;
      return await _isJwtScopedToBusiness(businessId);
    } on Object catch (_) {
      return false;
    }
  }

  Future<void> enterBusinessSelection() async {
    final refreshToken = state.session?.refreshToken;
    if (refreshToken == null) return;

    SwitchCompanyDebugLog.action('enterBusinessSelection begin');
    ref.read(companySessionProvider.notifier).clear();
    SwitchCompanyDebugLog.action('companySession cleared');
    state = state.copyWith(clearError: true);
    try {
      final service = await _service();
      // Refresh to an unscoped JWT BEFORE clearing selectedBusinessId /
      // invalidating providers. Doing it the other way raced 401 retries that
      // revoked the refresh token and wiped the session (empty Authorization).
      SwitchCompanyDebugLog.api(
        'refreshStoredSession(preserveBusinessScope: false)',
      );
      final session = await service.refreshStoredSession(
        refreshToken: refreshToken,
        preserveBusinessScope: false,
      );
      if (session == null) {
        final stillHasToken = await service.getAccessToken();
        if (stillHasToken == null || stillHasToken.isEmpty) {
          AuthFlowLogger.authStatus(AuthStatus.unauthenticated.name);
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            clearSession: true,
          );
          SwitchCompanyDebugLog.action(
            'session null + no token → unauthenticated',
          );
          return;
        }
        SwitchCompanyDebugLog.action(
          'refresh failed but tokens kept — abort switch',
        );
        state = state.copyWith(
          error: 'Could not switch company. Please try again.',
        );
        return;
      }

      await _clearActiveBusinessSession();
      SwitchCompanyDebugLog.invalidate(
        'active business session + business-scoped providers',
      );

      // Single write for status + session. Splitting these caused
      // collaborationRepository / companyDirectory to rebuild twice and
      // produced a second loading indicator after Switch Company.
      AuthFlowLogger.authStatus(AuthStatus.needsBusinessSelection.name);
      state = state.copyWith(
        status: AuthStatus.needsBusinessSelection,
        session: session,
      );
      SwitchCompanyDebugLog.action(
        'auth → needsBusinessSelection + session (atomic)',
      );
    } on Object catch (e) {
      SwitchCompanyDebugLog.action('enterBusinessSelection error: $e');
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
    } on Object catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final service = await _service();
      await service.logout();
      ref.read(companySessionProvider.notifier).clear();
      // Defer so invalidation does not run while authProvider is still updating
      // (businessProfileProvider watches authProvider → circular dependency).
      Future.microtask(() {
        if (ref.mounted) {
          invalidateAllBusinessScopedProviders(
            ref,
            includeBusinessList: true,
          );
        }
      });
    } finally {
      ref.read(companySessionProvider.notifier).clear();
      AuthFlowLogger.reset();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  String _backendLoginErrorMessage(Object error) {
    return NetworkExceptionClassifier.classify(
      error,
      host: NetworkExceptionClassifier.hostFromApiUrl(),
    ).reason;
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
      final responseBody = error.response?.data;
      switch (statusCode) {
        case 404:
          return 'Developer Login is disabled. Set ENABLE_DEV_LOGIN=true on the API.';
        case 401:
          return 'Developer Login is not available.';
        case 500:
          return 'Unable to sign in using Developer Login.';
      }
      if (NetworkExceptionClassifier.isConnectivityError(error)) {
        return 'Cannot reach the API. Start the API and set API_BASE_URL '
            '(use your PC LAN IP on a physical phone, not localhost).';
      }
      if (responseBody != null) {
        return 'Developer Login failed ($statusCode): $responseBody';
      }
      return 'Developer Login failed: ${error.message ?? error.type}';
    }
    return 'Unable to sign in using Developer Login: $error';
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
