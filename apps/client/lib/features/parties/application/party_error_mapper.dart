import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
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

class PartyHasDependenciesException extends PartyException {
  const PartyHasDependenciesException()
    : super(
        'This party is linked to invoices or other documents and cannot be deleted.',
      );
}

abstract final class PartyErrorMapper {
  static Never mapAndThrow(DioException error) {
    final validation = ApiErrorParser.parseValidation(error);
    if (validation != null) {
      final mobileError = validation.fieldErrors['mobile'];
      if (mobileError != null) {
        throw PartyException(
          mobileError.contains('already')
              ? mobileError
              : 'Party already exists with this mobile number',
        );
      }
      final gstinError = validation.fieldErrors['gstin'];
      if (gstinError != null && gstinError.contains('already')) {
        throw PartyException(gstinError);
      }
      throw PartyException(validation.message);
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final envelope = data['error'];
      final code = envelope is Map<String, dynamic>
          ? envelope['code']?.toString()
          : data['code']?.toString();
      switch (code) {
        case 'PARTY_HAS_DEPENDENCIES':
          throw const PartyHasDependenciesException();
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

    final status = error.response?.statusCode;
    final body = error.response?.data;
    throw PartyException(
      'Unable to complete the request. '
      '${status != null ? 'HTTP $status. ' : ''}'
      '${error.message ?? error.type.name}'
      '${body != null ? ' $body' : ''}',
    );
  }

  static String messageFor(Object error) {
    if (error is PartyException) return error.message;
    if (error is PartyBusinessNotSelectedException) {
      return 'Business not selected. Please select a business first.';
    }
    if (error is PartyOfflineException) {
      return OfflineUiMessages.workingOffline;
    }
    if (error is ApiValidationException) return error.message;
    if (error is DioException && _isOffline(error)) {
      return OfflineUiMessages.workingOffline;
    }
    if (OfflineUiMessages.isOfflineError(error)) {
      return OfflineUiMessages.workingOffline;
    }
    if (error is StateError &&
        error.message.contains('Party not found in local database')) {
      return 'Party ledger is not available yet. Sync this business once while online.';
    }
    if (error is StateError &&
        error.message.contains('Party not found locally')) {
      return 'Party not found. Refresh the list and try again.';
    }
    if (error is StateError && error.message.contains('different business')) {
      return 'This party belongs to another business.';
    }
    if (error is StateError &&
        error.message.contains('Business must be selected')) {
      return 'Business not selected. Please select a business first.';
    }
    if (error is StateError && error.message.contains('No business selected')) {
      return 'Business not selected. Please select a business first.';
    }
    final detail = error.toString().trim();
    if (detail.isNotEmpty) return detail;
    return 'Unable to complete the request. Please try again.';
  }

  static bool _isOffline(DioException error) =>
      error.response == null ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout;
}
