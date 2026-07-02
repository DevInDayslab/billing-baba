import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  AuthRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  final Dio _dio;

  static const _healthCheckTimeout = Duration(seconds: 5);

  /// Lightweight reachability check before backend login.
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.health,
        options: Options(
          sendTimeout: _healthCheckTimeout,
          receiveTimeout: _healthCheckTimeout,
        ),
      );
      return response.statusCode == 200 && response.data?['success'] == true;
    } on DioException {
      return false;
    }
  }

  Future<AuthSession> login({
    required String msg91AccessToken,
    required String phone,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.auth}/login',
      data: {
        'access_token': msg91AccessToken,
        'phone': _normalizePhoneForApi(phone),
      },
    );
    return _parseSession(response.data);
  }

  String _normalizePhoneForApi(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    return digits;
  }

  Future<AuthSession> devLogin() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.auth}/dev-login',
    );
    return _parseSession(response.data);
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
        message: 'Invalid auth response',
      );
    }
    return AuthSession.fromJson(data);
  }
}
