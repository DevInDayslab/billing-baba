import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_helper.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/subscription_activated_dialog.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/subscription_payment_dialog.dart';
import 'package:billing_baba/features/subscription/providers/subscription_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

String subscriptionPurchaseErrorMessage(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 404) {
      return 'Subscription service is unavailable. Restart the API server after pulling latest changes.';
    }
    if (status == 400 || status == 503) {
      final code = error.response?.data;
      if (code is Map<String, dynamic>) {
        final apiError = code['error'];
        if (apiError is Map<String, dynamic>) {
          final message = apiError['message'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
      }
      if (status == 503) {
        return 'Payment service is not configured on the server.';
      }
    }
    final message = error.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }
  return error.toString();
}

/// Drives the full desktop purchase flow: creates the order, opens the
/// embedded WebView checkout dialog, verifies payment server-side, and
/// refreshes subscription state automatically.
Future<void> purchaseSubscriptionPlan({
  required BuildContext context,
  required WidgetRef ref,
  required SubscriptionPlanCode plan,
}) async {
  final purchaseLock = ref.read(subscriptionPurchaseInProgressProvider.notifier);
  if (!purchaseLock.start()) {
    return;
  }

  try {
    final profile = ref.read(currentBusinessProvider);
    if (!isSubscriptionCheckoutProfileComplete(profile)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(subscriptionProfileIncompleteMessage)),
      );
      return;
    }

    final order = await createSubscriptionOrder(ref, plan);
    final planName = formatSubscriptionPlanLabel(plan);

    if (!context.mounted) return;

    final result = await showSubscriptionPaymentDialog(
      context,
      order: order,
      expectedPlan: plan,
      planName: planName,
    );

    if (!context.mounted) return;

    switch (result) {
      case SubscriptionPaymentResult.activated:
        await ref.read(currentSubscriptionProvider.notifier).refresh();
        await ref.read(subscriptionHistoryProvider.notifier).refresh();
        await ref.read(subscriptionPlansProvider.notifier).refresh();

        if (!context.mounted) return;
        await showSubscriptionActivatedDialog(context, planName: planName);
      case SubscriptionPaymentResult.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment cancelled.')),
        );
      case SubscriptionPaymentResult.dismissed:
        break;
    }
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(subscriptionPurchaseErrorMessage(error))),
    );
  } finally {
    purchaseLock.finish();
  }
}

String formatSubscriptionPlanLabel(SubscriptionPlanCode plan) {
  return switch (plan) {
    SubscriptionPlanCode.gold => 'Gold',
    SubscriptionPlanCode.platinum => 'Platinum',
    SubscriptionPlanCode.noPlan => 'No Plan',
  };
}

String? formatSubscriptionExpiry(DateTime? expiresAt) {
  if (expiresAt == null) return null;
  return DateFormat('dd MMMM yyyy').format(expiresAt.toLocal());
}

String formatSubscriptionStatus(SubscriptionStatusCode status) {
  return switch (status) {
    SubscriptionStatusCode.active => 'Active',
    SubscriptionStatusCode.expired => 'Expired',
    SubscriptionStatusCode.pending => 'Pending',
    SubscriptionStatusCode.cancelled => 'Cancelled',
  };
}
