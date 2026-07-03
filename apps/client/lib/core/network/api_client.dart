import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/constants/app_constants.dart';
import 'package:billing_baba/core/network/auth_interceptor.dart';
import 'package:billing_baba/core/network/interceptors.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:dio/dio.dart';

/// Configured Dio HTTP client for the Fastify API.
class ApiClient {
  ApiClient({
    Dio? dio,
    StorageService? storage,
    TokenRefreshCallback? onRefreshToken,
  }) : _dio = dio ?? Dio() {
    _dio
      ..options = BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      )
      ..interceptors.addAll([
        if (storage != null)
          AuthInterceptor(
            storage: storage,
            onRefreshToken: onRefreshToken,
          ),
        ...buildInterceptors(),
      ]);
  }

  final Dio _dio;

  Dio get dio => _dio;
}
