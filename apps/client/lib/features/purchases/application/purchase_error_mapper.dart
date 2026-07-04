import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:dio/dio.dart';

class PurchaseException implements Exception {
  const PurchaseException(this.message, {this.code, this.fieldErrors});

  final String message;
  final String? code;
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() => message;
}

class PurchaseOfflineException extends PurchaseException {
  const PurchaseOfflineException(super.message);
}

PurchaseException mapPurchaseError(Object error) {
  if (error is DioException) {
    final validation = ApiErrorParser.parseValidation(error);
    if (validation != null) {
      return PurchaseException(
        validation.message,
        code: 'VALIDATION_ERROR',
        fieldErrors: validation.fieldErrors.map(
          (key, value) => MapEntry(key, [value]),
        ),
      );
    }

    final code = ApiErrorParser.errorCode(error);
    final message =
        ApiErrorParser.errorMessage(error) ?? error.message ?? 'Request failed';

    return PurchaseException(
      _friendlyMessage(code, message),
      code: code,
    );
  }

  if (error is PurchaseException) return error;

  return PurchaseException(error.toString());
}

String _friendlyMessage(String? code, String fallback) {
  return switch (code) {
    'PARTY_NOT_FOUND' => 'Supplier not found',
    'DOCUMENT_FINALIZED' => 'This document is already finalized',
    'DOCUMENT_CANCELLED' => 'This document has been cancelled',
    'DOCUMENT_CONVERTED' => 'This document has already been converted',
    'VALIDATION_ERROR' => fallback,
    'STOCK_UNAVAILABLE' => 'Insufficient stock for this operation',
    'OVER_ALLOCATION' => 'Payment allocation exceeds outstanding balance',
    'INVALID_SUPPLIER' => 'Party must be a supplier',
    _ => fallback,
  };
}

abstract final class PurchaseErrorMapper {
  static String messageFor(Object error) {
    if (error is PurchaseException) return error.message;
    return mapPurchaseError(error).message;
  }
}
