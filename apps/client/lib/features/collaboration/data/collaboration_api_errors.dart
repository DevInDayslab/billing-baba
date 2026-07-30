import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:dio/dio.dart';

Never throwCollaborationApiError(DioException error) {
  final statusCode = error.response?.statusCode;
  final code = ApiErrorParser.errorCode(error);
  final message =
      ApiErrorParser.firstValidationDetail(error) ??
      ApiErrorParser.errorMessage(error) ??
      ApiErrorParser.userFacingMessage(error);

  if (statusCode == 401) {
    throw error;
  }

  if (statusCode == 403 || code == 'FORBIDDEN') {
    throw CollaborationForbiddenException(
      message.isNotEmpty
          ? message
          : 'You do not have permission for this action.',
    );
  }

  if (statusCode == 404 ||
      code == 'INVITATION_NOT_FOUND' ||
      code == 'NOT_FOUND') {
    throw CollaborationNotFoundException(
      message.isNotEmpty ? message : 'The requested item was not found.',
    );
  }

  if (statusCode == 409 ||
      code == 'CONFLICT' ||
      code == 'INVITATION_ALREADY_ACCEPTED' ||
      code == 'INVITATION_NOT_ACTIONABLE') {
    throw CollaborationConflictException(
      message.isNotEmpty
          ? message
          : 'This action cannot be completed right now.',
    );
  }

  if (statusCode == 410 || code == 'INVITATION_EXPIRED') {
    throw CollaborationConflictException(
      message.isNotEmpty ? message : 'This invitation has expired.',
    );
  }

  if (statusCode == 400 || statusCode == 422 || code == 'VALIDATION_ERROR') {
    throw CollaborationValidationException(
      message.isNotEmpty ? message : 'Please check the details and try again.',
    );
  }

  throw error;
}
