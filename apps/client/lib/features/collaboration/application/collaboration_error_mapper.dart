import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:dio/dio.dart';

abstract final class CollaborationErrorMapper {
  static String messageFor(Object error) {
    if (error is CollaborationValidationException) {
      return error.message;
    }
    if (error is CollaborationNotFoundException) {
      return error.message;
    }
    if (error is CollaborationForbiddenException) {
      return error.message;
    }
    if (error is CollaborationConflictException) {
      return error.message;
    }
    if (error is DioException) {
      final code = ApiErrorParser.errorCode(error);
      final statusCode = error.response?.statusCode;
      if (statusCode == 410 || code == 'INVITATION_EXPIRED') {
        return ApiErrorParser.errorMessage(error) ??
            'This invitation has expired.';
      }
      if (code == 'INVITATION_NOT_FOUND') {
        return ApiErrorParser.errorMessage(error) ?? 'Invitation not found.';
      }
      if (code == 'INVITATION_NOT_ACTIONABLE') {
        return ApiErrorParser.errorMessage(error) ??
            'This invitation cannot be updated in its current state.';
      }
      if (code == 'INVITATION_ALREADY_ACCEPTED') {
        return ApiErrorParser.errorMessage(error) ??
            'This invitation has already been accepted.';
      }
      if (code == 'CONFLICT') {
        return ApiErrorParser.errorMessage(error) ??
            'This action conflicts with the current state.';
      }
      if (code == 'FORBIDDEN') {
        return ApiErrorParser.errorMessage(error) ??
            'You do not have permission for this action.';
      }
      final fieldDetail = ApiErrorParser.firstValidationDetail(error);
      if (fieldDetail != null && fieldDetail.isNotEmpty) return fieldDetail;
      return ApiErrorParser.userFacingMessage(error);
    }
    return 'Something went wrong. Please try again.';
  }
}
