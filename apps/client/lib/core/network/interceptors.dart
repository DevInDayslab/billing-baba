import 'package:dio/dio.dart';

/// Ensures POST/PUT/PATCH requests with JSON content-type always include a body.
/// Fastify rejects `Content-Type: application/json` with no body (FST_ERR_CTP_EMPTY_JSON_BODY).
Interceptor buildJsonBodyInterceptor() {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      final method = options.method.toUpperCase();
      if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
        final contentType = _jsonContentType(options);
        if (contentType != null && options.data == null) {
          options.data = <String, dynamic>{};
        }
      } else if ((method == 'DELETE' || method == 'GET') &&
          options.data == null) {
        // Fastify rejects application/json with an empty body on bodyless requests.
        options.headers.remove(Headers.contentTypeHeader);
        options.contentType = null;
      }
      handler.next(options);
    },
  );
}

String? _jsonContentType(RequestOptions options) {
  final contentType = options.contentType?.toLowerCase();
  if (contentType != null && contentType.contains('application/json')) {
    return contentType;
  }
  final header = options.headers['Content-Type']?.toString().toLowerCase();
  if (header != null && header.contains('application/json')) {
    return header;
  }
  return null;
}

/// Returns application-level Dio interceptors.
List<Interceptor> buildInterceptors() {
  return [
    buildJsonBodyInterceptor(),
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.next(options),
      onResponse: (response, handler) => handler.next(response),
      onError: (error, handler) => handler.next(error),
    ),
  ];
}
