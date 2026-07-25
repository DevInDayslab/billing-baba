import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/features/subscription/application/subscription_service_types.dart';
import 'package:dio/dio.dart';

Never throwSubscriptionApiError(DioException error) {
  final statusCode = error.response?.statusCode;
  final code = ApiErrorParser.errorCode(error);
  final message =
      ApiErrorParser.firstValidationDetail(error) ??
      ApiErrorParser.errorMessage(error) ??
      ApiErrorParser.userFacingMessage(error);

  if (statusCode == 401) {
    throw error;
  }

  if (statusCode == 503 || code == 'DATABASE_NOT_CONFIGURED') {
    throw SubscriptionUnavailableException(
      message.isNotEmpty
          ? message
          : 'Subscription service is temporarily unavailable.',
    );
  }

  if (statusCode == 410 || code == 'PAYMENT_UNAVAILABLE') {
    throw SubscriptionPaymentException(
      message.isNotEmpty ? message : 'Payments are temporarily unavailable.',
    );
  }

  if (code == 'BUSINESS_PROFILE_INCOMPLETE') {
    throw SubscriptionProfileIncompleteException(
      message.isNotEmpty
          ? message
          : 'Complete your business profile before purchasing a plan.',
    );
  }

  if (statusCode == 400 || statusCode == 422 || code == 'VALIDATION_ERROR') {
    throw SubscriptionValidationException(
      message.isNotEmpty ? message : 'Please check the details and try again.',
    );
  }

  if (code == 'INVALID_PLAN' || code == 'BUSINESS_NOT_FOUND') {
    throw SubscriptionValidationException(
      message.isNotEmpty ? message : 'Unable to process this plan request.',
    );
  }

  throw error;
}
