import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/features/subscription/application/subscription_service_types.dart';
import 'package:dio/dio.dart';

class SubscriptionErrorMapper {
  const SubscriptionErrorMapper._();

  static String messageFor(Object error) {
    return switch (error) {
      SubscriptionUnavailableException(:final message) => message,
      SubscriptionValidationException(:final message) => message,
      SubscriptionProfileIncompleteException(:final message) => message,
      SubscriptionPaymentException(:final message) => message,
      DioException() => ApiErrorParser.userFacingMessage(error),
      _ => 'Something went wrong. Please try again.',
    };
  }
}
