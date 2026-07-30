import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/auth/utils/auth_debug_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

class OtpException implements Exception {
  const OtpException(
    this.message, {
    this.code,
    this.isNetwork = false,
    this.isConsumed = false,
    this.cause,
  });

  final String message;
  final int? code;
  final bool isNetwork;
  final bool isConsumed;
  final Object? cause;

  @override
  String toString() => message;
}

class OtpService {
  static var _initialized = false;

  static void markInitialized() {
    _initialized = true;
  }

  bool get isConfigured => _initialized;

  /// Local mock OTP when MSG91 credentials are not set in .env.
  bool get isMockMode => !_initialized;

  static const mockReqId = 'mock-otp-req';
  static const mockAccessToken = 'mock-otp-verified';

  bool get isSdkSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  static void initializeWidget({
    required String widgetId,
    required String authToken,
  }) {
    if (widgetId.isEmpty || authToken.isEmpty) {
      return;
    }
    OTPWidget.initializeWidget(widgetId, authToken);
    markInitialized();
    AuthDebugLogger.widgetInitialized(
      widgetId: widgetId,
      platform: defaultTargetPlatform.name,
    );
  }

  String formatIdentifier(String mobileNumber) {
    final cleanNumber = mobileNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.startsWith('91') && cleanNumber.length > 10) {
      return cleanNumber;
    }
    return '91$cleanNumber';
  }

  Future<String> sendOtp(String mobileNumber) async {
    _ensureReady();

    if (isMockMode) {
      return mockReqId;
    }

    final identifier = formatIdentifier(mobileNumber);

    try {
      final result = await OTPWidget.sendOTP({'identifier': identifier});
      AuthDebugLogger.logSdkResponse('sendOTP', result);
      if (result == null) {
        throw const OtpException('Unable to send OTP. Please try again later.');
      }

      if (_isErrorType(result) ||
          result['message'] == 'AuthenticationFailure') {
        throw const OtpException(
          'Unable to send OTP. Please try again later.',
        );
      }

      final reqId = _parseReqId(result);
      if (reqId != null) {
        return reqId;
      }

      throw const OtpException(
        'OTP was sent but the session expired. Go back and try again.',
      );
    } on Object catch (e) {
      throw _wrapSendError(e);
    }
  }

  Future<String> retryOtp(String reqId) async {
    _ensureReady();

    if (isMockMode) {
      final trimmed = reqId.trim();
      return trimmed.isEmpty ? mockReqId : trimmed;
    }

    final trimmed = reqId.trim();
    if (trimmed.isEmpty) {
      throw const OtpException(
        'Session expired. Go back and request a new OTP.',
      );
    }

    try {
      final result = await OTPWidget.retryOTP({'reqId': trimmed});
      AuthDebugLogger.logSdkResponse('retryOTP', result);
      if (result == null) {
        throw const OtpException('Failed to resend OTP. Please try again.');
      }
      if (_isErrorType(result)) {
        throw _mapSdkError(result, fallback: 'Failed to resend OTP');
      }

      final type = result['type']?.toString().toLowerCase() ?? '';
      if (type != 'success') {
        final message = result['message']?.toString().trim();
        throw OtpException(
          message == null || message.isEmpty
              ? 'Failed to resend OTP'
              : message,
        );
      }

      return _parseReqId(result) ?? trimmed;
    } on Object catch (e) {
      if (e is OtpException) rethrow;
      throw _wrapNetworkError(e);
    }
  }

  Future<String> verifyOtp({
    required String reqId,
    required String otp,
  }) async {
    _ensureReady();

    if (isMockMode) {
      if (otp.trim() != AppConfig.devOtp) {
        throw const OtpException('Invalid OTP. Please check and try again.');
      }
      return mockAccessToken;
    }

    final trimmedReqId = reqId.trim();
    if (trimmedReqId.isEmpty) {
      throw const OtpException(
        'Session expired. Go back and request a new OTP.',
      );
    }

    try {
      final result = await OTPWidget.verifyOTP({
        'otp': otp,
        'reqId': trimmedReqId,
      });

      if (result == null) {
        throw const OtpException('Invalid OTP. Please check and try again.');
      }

      final type = result['type']?.toString().toLowerCase() ?? '';
      if (type != 'success') {
        throw _mapSdkError(
          result,
          fallback: 'Invalid OTP. Please check and try again.',
        );
      }

      final accessToken = _extractAccessToken(result);
      if (accessToken == null || accessToken.isEmpty) {
        throw const OtpException('Access token missing. Please try again.');
      }

      return accessToken;
    } on Object catch (e) {
      if (e is OtpException) rethrow;
      throw _wrapNetworkError(e);
    }
  }

  OtpException _mapSdkError(
    Map<String, dynamic> result, {
    required String fallback,
  }) {
    final codeRaw = result['code'];
    final code = codeRaw is int ? codeRaw : int.tryParse('$codeRaw');
    final message = result['message']?.toString().toLowerCase() ?? '';

    if (code == 703 ||
        message.contains('already') ||
        message.contains('verifed')) {
      return const OtpException(
        'This OTP has already been used. Request a new one.',
        code: 703,
        isConsumed: true,
      );
    }
    if (code == 702 || message.contains('expired')) {
      return const OtpException(
        'OTP expired. Please request a new OTP.',
        code: 702,
        isConsumed: true,
      );
    }
    if (result['message'] == 'AuthenticationFailure') {
      return const OtpException(
        'Unable to send OTP. Please try again later.',
      );
    }
    return OtpException(fallback, code: code);
  }

  OtpException _wrapSendError(Object error) {
    if (error is OtpException) return error;
    return _wrapNetworkError(
      error,
      fallback: "Couldn't send OTP. Please check your connection.",
    );
  }

  OtpException _wrapNetworkError(
    Object error, {
    String fallback = 'Please check your internet connection.',
  }) {
    final text = error.toString().toLowerCase();
    if (text.contains('socket') ||
        text.contains('network') ||
        text.contains('timeout') ||
        text.contains('connection')) {
      return OtpException(fallback, isNetwork: true, cause: error);
    }
    return OtpException(fallback, cause: error);
  }

  String? _extractAccessToken(Map<String, dynamic> result) {
    for (final key in [
      'access-token',
      'access_token',
      'accessToken',
      'token',
    ]) {
      final value = result[key];
      if (value is String && value.isNotEmpty && _looksLikeJwt(value)) {
        return value;
      }
    }

    final message = result['message'];
    if (message is String && message.isNotEmpty && _looksLikeJwt(message)) {
      return message;
    }

    return null;
  }

  bool _looksLikeJwt(String value) {
    final parts = value.trim().split('.');
    return parts.length >= 3;
  }

  void _ensureReady() {
    if (!isSdkSupported) {
      throw const OtpException(
        'OTP login is not supported on this platform.',
      );
    }
  }

  bool _isErrorType(Map<String, dynamic> result) {
    return result['type']?.toString().toLowerCase() == 'error';
  }

  String? _parseReqId(Map<String, dynamic> result) {
    // MSG91's Flutter SDK stores reqId from `message` on success responses.
    final type = result['type']?.toString().toLowerCase() ?? '';
    if (type == 'success') {
      final message = result['message']?.toString().trim();
      if (message != null &&
          message.isNotEmpty &&
          message != 'AuthenticationFailure' &&
          !_looksLikeJwt(message)) {
        return message;
      }
    }

    for (final key in ['request_id', 'reqId', 'requestId']) {
      final value = result[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    final message = result['message']?.toString().trim();
    if (message != null && message.isNotEmpty && _looksLikeReqId(message)) {
      return message;
    }

    return null;
  }

  bool _looksLikeReqId(String value) {
    if (value.length < 12) return false;
    if (_looksLikeJwt(value)) return false;
    final lower = value.toLowerCase();
    if (lower.contains('otp') ||
        lower.contains('sent') ||
        lower.contains('success') ||
        lower.contains('fail')) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value);
  }
}
