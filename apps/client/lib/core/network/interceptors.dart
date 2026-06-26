import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Returns application-level Dio interceptors.
List<Interceptor> buildInterceptors() {
  return [
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.next(options),
      onResponse: (response, handler) => handler.next(response),
      onError: (error, handler) => handler.next(error),
    ),
  ];
}

/// Pretty logger for debug builds only.
Interceptor buildLoggerInterceptor() {
  return PrettyDioLogger(requestHeader: true, requestBody: true);
}
