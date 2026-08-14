/// Maps Razorpay payment method strings to accounting payment mode API values.
abstract final class PaymentModeMapper {
  static String fromRazorpayMethod(String? method) {
    switch (method) {
      case 'upi':
        return 'upi';
      case 'card':
      case 'credit_card':
      case 'debit_card':
      case 'emi':
        return 'card';
      case 'netbanking':
        return 'bank_transfer';
      case 'wallet':
        return 'other';
      default:
        return 'other';
    }
  }
}
