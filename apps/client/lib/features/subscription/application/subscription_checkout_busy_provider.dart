import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while Razorpay checkout / verify is in progress.
///
/// Sync & Share polling and window-focus refreshes must not run during this
/// window — they rebuild large parts of the tree under the platform WebView
/// and freeze the macOS UI.
final subscriptionCheckoutBusyProvider =
    NotifierProvider<SubscriptionCheckoutBusy, bool>(
      SubscriptionCheckoutBusy.new,
    );

class SubscriptionCheckoutBusy extends Notifier<bool> {
  @override
  bool build() => false;

  void begin() => state = true;

  void end() => state = false;
}
