import 'package:billing_baba/features/auth/utils/auth_debug_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

class OtpException implements Exception {
  const OtpException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OtpService {
  static var _initialized = false;

  static void markInitialized() {
    _initialized = true;
  }

  bool get isConfigured => _initialized;

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

    final identifier = formatIdentifier(mobileNumber);
    AuthDebugLogger.log(
      'sendOTP identifier=${AuthDebugLogger.maskPhone(identifier)}',
    );

    final result = await OTPWidget.sendOTP({'identifier': identifier});
    if (result == null) {
      throw const OtpException('Authentication failed. Please try again.');
    }

    _logSdkResponse('SEND', result);

    if (_isErrorType(result) || result['message'] == 'AuthenticationFailure') {
      throw const OtpException('Authentication failed. Please try again.');
    }

    final reqId = _parseReqId(result);
    if (reqId != null) {
      AuthDebugLogger.sendOtp(
        maskedPhone: AuthDebugLogger.maskPhone(mobileNumber),
        reqId: reqId,
      );
      return reqId;
    }

    throw const OtpException(
      'OTP was sent but the session expired. Go back and try again.',
    );
  }

  Future<void> retryOtp(String reqId) async {
    _ensureReady();

    final trimmed = reqId.trim();
    if (trimmed.isEmpty) {
      throw const OtpException(
        'Session expired. Go back and request a new OTP.',
      );
    }

    final result = await OTPWidget.retryOTP({'reqId': trimmed});
    _logSdkResponse('RETRY', result);

    if (result != null && _isErrorType(result)) {
      throw OtpException(_userMessageForSdkError(result, 'Failed to resend OTP'));
    }
  }

  Future<String> verifyOtp({
    required String reqId,
    required String otp,
  }) async {
    _ensureReady();

    final trimmedReqId = reqId.trim();
    if (trimmedReqId.isEmpty) {
      throw const OtpException(
        'Session expired. Go back and request a new OTP.',
      );
    }

    final result = await OTPWidget.verifyOTP({
      'otp': otp,
      'reqId': trimmedReqId,
    });

    if (result == null) {
      throw const OtpException('Invalid OTP.');
    }

    _logSdkResponse('VERIFY', result);

    final type = result['type']?.toString().toLowerCase() ?? '';
    if (type != 'success') {
      throw OtpException(_userMessageForVerifyError(result));
    }

    final accessToken = _extractAccessToken(result);
    if (accessToken == null || accessToken.isEmpty) {
      throw const OtpException('Access token missing. Please try again.');
    }

    AuthDebugLogger.accessTokenReceived(accessToken);
    return accessToken;
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

  String _userMessageForVerifyError(Map<String, dynamic> result) {
    final errorMsg = result['message']?.toString() ?? '';
    final codeRaw = result['code'];
    final code = codeRaw is int ? codeRaw : int.tryParse('$codeRaw');
    final lower = errorMsg.toLowerCase();

    if (code == 703 ||
        code == 702 ||
        lower.contains('already') ||
        lower.contains('verifed')) {
      return 'OTP already used. Tap Resend OTP for a new code.';
    }
    if (lower.contains('expired')) {
      return 'OTP expired. Tap Resend OTP for a new code.';
    }
    if (lower.contains('invalid') || lower.contains('incorrect')) {
      return 'Invalid OTP. Please check and try again.';
    }
    if (errorMsg.isNotEmpty && !errorMsg.contains('.')) {
      return errorMsg;
    }
    return 'Invalid OTP. Please check and try again.';
  }

  String _userMessageForSdkError(
    Map<String, dynamic> result,
    String fallback,
  ) {
    final message = result['message']?.toString() ?? '';
    if (message == 'AuthenticationFailure') {
      return 'Authentication failed. Please try again.';
    }
    if (message.isNotEmpty) {
      return message;
    }
    return fallback;
  }

  void _ensureReady() {
    if (!isSdkSupported) {
      throw const OtpException(
        'OTP login is not supported on this platform.',
      );
    }
    if (!_initialized) {
      throw const OtpException(
        'OTP service is not configured. Check MSG91 settings in .env.',
      );
    }
  }

  bool _isErrorType(Map<String, dynamic> result) {
    return result['type']?.toString().toLowerCase() == 'error';
  }

  String? _parseReqId(Map<String, dynamic> result) {
    for (final key in ['request_id', 'reqId', 'requestId']) {
      final value = result[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    final message = result['message']?.toString().trim();
    if (message != null &&
        message.isNotEmpty &&
        _looksLikeReqId(message)) {
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

  void _logSdkResponse(String step, Map<String, dynamic>? result) {
    AuthDebugLogger.logSdkResponse(step, result);
  }
}
