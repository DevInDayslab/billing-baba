class SubscriptionUnavailableException implements Exception {
  SubscriptionUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SubscriptionValidationException implements Exception {
  SubscriptionValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SubscriptionProfileIncompleteException implements Exception {
  SubscriptionProfileIncompleteException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SubscriptionPaymentException implements Exception {
  SubscriptionPaymentException(this.message);

  final String message;

  @override
  String toString() => message;
}
