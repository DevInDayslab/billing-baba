import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';

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
    return 'Something went wrong. Please try again.';
  }
}
