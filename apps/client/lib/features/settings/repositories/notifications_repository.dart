import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/settings/data/notifications_remote_data_source.dart';
import 'package:dio/dio.dart';

class NotificationDispatchException implements Exception {
  const NotificationDispatchException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class NotificationOfflineException implements Exception {
  const NotificationOfflineException();

  @override
  String toString() => 'Network unavailable';
}

/// Thin repository over [NotificationsRemoteDataSource].
/// Flutter UI must call this — never Dio / notification providers directly.
class NotificationsRepository {
  NotificationsRepository(this._remote);

  final NotificationsRemoteDataSource _remote;

  Future<NotificationStatusDto> getStatus() => _map(_remote.getStatus);

  Future<NotifyDispatchResult> sendTest(String phone) =>
      _map(() => _remote.sendTest(phone));

  Future<NotifyDispatchResult> sendPartyReminder({
    required String partyId,
    required String salesDocumentId,
    String? phone,
    String? dueDate,
  }) =>
      _map(
        () => _remote.sendPartyReminder(
          partyId: partyId,
          salesDocumentId: salesDocumentId,
          phone: phone,
          dueDate: dueDate,
        ),
      );

  Future<NotifyDispatchResult> shareSalesDocument(String id) =>
      _map(() => _remote.shareSalesDocument(id));

  Future<NotifyDispatchResult> notifySalesDocument(
    String id, {
    String? phone,
  }) =>
      _map(() => _remote.notifySalesDocument(id, phone: phone));

  Future<NotifyDispatchResult> notifyPaymentReceived(String paymentId) =>
      _map(() => _remote.notifyPaymentReceived(paymentId));

  Future<T> _map<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      _mapAndThrow(error);
    }
  }

  Never _mapAndThrow(DioException error) {
    final validation = ApiErrorParser.parseValidation(error);
    if (validation != null) {
      throw NotificationDispatchException(validation.message);
    }

    final code = ApiErrorParser.errorCode(error);
    final message = ApiErrorParser.errorMessage(error);

    if (_isOffline(error)) {
      throw const NotificationOfflineException();
    }

    switch (code) {
      case 'UNAUTHORIZED':
      case 'INVALID_TOKEN':
      case 'TOKEN_EXPIRED':
        throw NotificationDispatchException(
          message ?? 'Your session expired. Please sign in again.',
          code: code,
        );
      case 'NOT_FOUND':
        throw NotificationDispatchException(
          message ?? 'Invoice or payment not found',
          code: code,
        );
      case 'PHONE_REQUIRED':
      case 'INVALID_PHONE':
        throw NotificationDispatchException(
          message ?? 'Invalid or missing phone number',
          code: code,
        );
      case 'FORBIDDEN':
        throw NotificationDispatchException(
          message ?? 'You do not have permission for this action.',
          code: code,
        );
      default:
        throw NotificationDispatchException(
          message ?? 'Unable to send notification. Please try again.',
          code: code,
        );
    }
  }

  static String messageFor(Object error) {
    if (error is NotificationDispatchException) return error.message;
    if (error is NotificationOfflineException) {
      return 'Network unavailable. Try again when you are online.';
    }
    if (error is ApiValidationException) return error.message;
    return 'Unable to send notification. Please try again.';
  }

  static bool _isOffline(DioException error) =>
      error.response == null ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout;
}
