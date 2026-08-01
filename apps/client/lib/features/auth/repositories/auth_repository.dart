import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/network/interceptors.dart';
import 'package:billing_baba/core/network/pinned_api_http_client.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/utils/auth_debug_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final baseUrl = AppConfig.apiBaseUrl;
    LoggingService.instance.info('AuthRepository Dio baseUrl=$baseUrl');
    return Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      )
      ..httpClientAdapter = createBypassSslHttpClientAdapter()
      ..interceptors.addAll([
        ...buildInterceptors(),
      ]);
  }

  static const _healthCheckTimeout = Duration(seconds: 5);

  /// Lightweight reachability check before backend login.
  Future<bool> checkHealth() async {
    final url = '${AppConfig.apiBaseUrl}${ApiEndpoints.health}';
    AuthDebugLogger.log('checkHealth → GET $url');

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.health,
        options: Options(
          sendTimeout: _healthCheckTimeout,
          receiveTimeout: _healthCheckTimeout,
        ),
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      final healthy =
          response.statusCode == 200 && data?['status']?.toString() == 'ok';

      AuthDebugLogger.log(
        'checkHealth ← status=${response.statusCode} healthy=$healthy '
        'data.status=${data?['status']}',
      );

      if (!healthy && AppConfig.authDebugLogging) {
        debugPrint('[AUTH] checkHealth unexpected body: ${response.data}');
      }

      return healthy;
    } on DioException catch (e, st) {
      AuthDebugLogger.log(
        'checkHealth ✗ ${e.type} status=${e.response?.statusCode} '
        'message=${e.message}',
      );
      if (AppConfig.authDebugLogging) {
        debugPrint('[AUTH] checkHealth stackTrace:\n$st');
      }
      return false;
    }
  }

  Future<AuthSession> login({
    required String msg91AccessToken,
    required String phone,
  }) async {
    const path = '${ApiEndpoints.auth}/login';
    final normalizedPhone = _normalizePhoneForApi(phone);
    final body = {
      'access_token': msg91AccessToken,
      'phone': normalizedPhone,
    };

    AuthDebugLogger.log('login → POST ${AppConfig.apiBaseUrl}$path');
    AuthDebugLogger.log(
      'login body: phone=$normalizedPhone '
      'access_token=${AuthDebugLogger.maskToken(msg91AccessToken)}',
    );

    try {
      AuthDebugLogger.log('login dio.post starting');
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      AuthDebugLogger.log(
        'login dio.post response status=${response.statusCode}',
      );
      return _parseSession(response.data);
    } on DioException catch (e, st) {
      AuthDebugLogger.log(
        'login ✗ ${e.type} status=${e.response?.statusCode} message=${e.message}',
      );
      if (AppConfig.authDebugLogging) {
        debugPrint('[AUTH] login stackTrace:\n$st');
      }
      rethrow;
    }
  }

  String _normalizePhoneForApi(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    return digits;
  }

  Future<AuthSession> devLogin() async {
    const path = '${ApiEndpoints.auth}/dev-login';
    AuthDebugLogger.log('devLogin → POST ${AppConfig.apiBaseUrl}$path');

    try {
      AuthDebugLogger.log('devLogin dio.post starting');
      // First empty-catalog login may seed ~50 demo products server-side.
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: const <String, dynamic>{},
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      AuthDebugLogger.log(
        'devLogin dio.post response status=${response.statusCode}',
      );
      return _parseSession(response.data);
    } on DioException catch (e, st) {
      AuthDebugLogger.log(
        'devLogin ✗ ${e.type} status=${e.response?.statusCode} '
        'message=${e.message}',
      );
      if (AppConfig.authDebugLogging) {
        debugPrint('[AUTH] devLogin stackTrace:\n$st');
      }
      rethrow;
    }
  }

  Future<AuthSession> refresh({
    required String refreshToken,
    String? businessId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.auth}/refresh',
      data: {
        'refresh_token': refreshToken,
        'business_id': ?businessId,
      },
    );
    return _parseSession(response.data);
  }

  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _dio.post<void>(
      '${ApiEndpoints.auth}/logout',
      data: {'refresh_token': refreshToken},
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
  }

  Future<MeResponse> me(String accessToken) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.auth}/me',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid me response',
      );
    }
    return MeResponse.fromJson(data);
  }

  AuthSession _parseSession(Map<String, dynamic>? body) {
    final data = body?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.auth),
        message: 'Invalid auth response: $body',
      );
    }
    return AuthSession.fromJson(data);
  }
}
