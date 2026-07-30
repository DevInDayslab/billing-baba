import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// Shared offline copy used across dashboard, inventory, purchases, etc.
abstract final class OfflineMessages {
  static const connectToInternet = 'Please connect to the internet';
  static const showingCachedData = 'Offline — showing cached data';
}

/// Returns true when [error] indicates the device cannot reach the server.
bool isOfflineError(Object? error) {
  if (error == null) return false;

  if (error is SocketException || error is TimeoutException) {
    return true;
  }

  if (error is DioException) {
    return error.response == null ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  return false;
}
