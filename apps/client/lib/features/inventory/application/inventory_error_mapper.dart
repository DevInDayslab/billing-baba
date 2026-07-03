import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:dio/dio.dart';

class InventoryOfflineException implements Exception {
  const InventoryOfflineException();

  @override
  String toString() => 'Network unavailable';
}

class InventoryException implements Exception {
  const InventoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class InventoryErrorMapper {
  static Never mapAndThrow(DioException error) {
    final validation = ApiErrorParser.parseValidation(error);
    if (validation != null) {
      throw InventoryException(validation.message);
    }

    final code = ApiErrorParser.errorCode(error);
    switch (code) {
      case 'CATEGORY_HAS_ITEMS':
        throw const InventoryException(
          'Cannot delete category with existing items.',
        );
      case 'BRAND_HAS_ITEMS':
        throw const InventoryException(
          'Cannot delete brand with existing items.',
        );
      case 'UNIT_HAS_ITEMS':
        throw const InventoryException(
          'Cannot delete unit because it is used by items.',
        );
      case 'UNIT_HAS_CONVERSIONS':
        throw const InventoryException(
          'Cannot delete unit because it has active conversions.',
        );
      case 'NOT_FOUND':
        throw const InventoryException('Record not found.');
      case 'FORBIDDEN':
      case 'UNAUTHORIZED':
        throw const InventoryException(
          'You do not have access to this business.',
        );
      case 'CONFLICT':
        throw const InventoryException(
          'This action conflicts with existing data.',
        );
    }

    if (_isOffline(error)) {
      throw const InventoryOfflineException();
    }

    final message = ApiErrorParser.errorMessage(error);
    if (message != null && message.isNotEmpty) {
      throw InventoryException(message);
    }

    throw const InventoryException(
      'Unable to complete the request. Please try again.',
    );
  }

  static String messageFor(Object error) {
    if (error is InventoryException) return error.message;
    if (error is InventoryOfflineException) {
      return 'Network unavailable. Please check your connection.';
    }
    if (error is ApiValidationException) return error.message;
    return 'Unable to load inventory data. Please try again.';
  }

  static bool _isOffline(DioException error) {
    return error.response == null ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }
}
