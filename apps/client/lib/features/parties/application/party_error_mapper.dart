import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:dio/dio.dart';

class PartyOfflineException implements Exception {
  const PartyOfflineException();

  @override
  String toString() => 'Network unavailable';
}

class PartyException implements Exception {
  const PartyException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PartyBusinessNotSelectedException implements Exception {
  const PartyBusinessNotSelectedException();

  @override
  String toString() => 'Business not selected';
}

abstract final class PartyErrorMapper {
  static Never mapAndThrow(DioException error) {
    final validation = ApiErrorParser.parseValidation(error);
    if (validation != null) {
      final mobileError = validation.fieldErrors['mobile'];
      if (mobileError != null) {
        throw const PartyException(
          'Party already exists with this mobile number',
        );
      }
      throw PartyException(validation.message);
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['code']?.toString();
      switch (code) {
        case 'PARTY_HAS_DEPENDENCIES':
          throw const PartyException(
            'Unable to delete party because it has linked documents.',
          );
        case 'BUSINESS_NOT_SELECTED':
          throw const PartyBusinessNotSelectedException();
        case 'NOT_FOUND':
          throw const PartyException('Party not found');
        case 'FORBIDDEN':
          throw const PartyException('You do not have access to this business');
      }
    }

    if (_isOffline(error)) {
      throw const PartyOfflineException();
    }

    throw const PartyException(
      'Unable to complete the request. Please try again.',
    );
  }

  static String messageFor(Object error) {
    if (error is PartyException) return error.message;
    if (error is PartyBusinessNotSelectedException) {
      return 'Business not selected. Please select a business first.';
    }
    if (error is PartyOfflineException) {
      return 'Network unavailable. Showing cached data.';
    }
    if (error is ApiValidationException) return error.message;
    if (error is StateError &&
        error.message.contains('Business must be selected')) {
      return 'Business not selected. Please select a business first.';
    }
    return 'Unable to load parties. Please try again.';
  }

  static bool _isOffline(DioException error) =>
      error.response == null ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout;
}
