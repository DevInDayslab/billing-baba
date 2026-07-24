import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';

const subscriptionProfileIncompleteMessage =
    'Please complete your business profile before purchasing a subscription.';

bool isSubscriptionCheckoutProfileComplete(BusinessProfileModel? profile) {
  if (profile == null) {
    return false;
  }

  final ownerName = profile.ownerName?.trim();
  final email = profile.email?.trim();
  final phone = Validators.normalizeIndianPhone(profile.phone);

  return ownerName != null &&
      ownerName.isNotEmpty &&
      email != null &&
      email.isNotEmpty &&
      phone != null &&
      phone.isNotEmpty;
}

bool isSubscriptionOrderCheckoutReady(CreateOrderResponseModel order) {
  final ownerName = order.ownerName.trim();
  final email = order.businessEmail.trim();
  final phone = Validators.normalizeIndianPhone(order.businessPhone);

  return ownerName.isNotEmpty &&
      email.isNotEmpty &&
      phone != null &&
      phone.isNotEmpty;
}

/// Razorpay expects `+{country code}{phone}`; defaults to India (+91).
String? formatRazorpayContact(String? phone) {
  final normalized = Validators.normalizeIndianPhone(phone);
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return '+91$normalized';
}
