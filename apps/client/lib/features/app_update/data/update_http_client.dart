import 'package:dio/dio.dart';

Dio createUpdateHttpClient() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: const {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    ),
  );
}
