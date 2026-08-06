import 'package:billing_baba/features/collaboration/application/sync_share_live_sync_service.dart';
import 'package:billing_baba/features/payments/application/payment_checkout_busy_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_busy_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_share_refresh_provider.g.dart';

/// Coordinates Sync & Share refresh requests with de-duplication.
///
/// UI and lifecycle hooks should call [refresh] or [refreshAfterMutation] only.
@Riverpod(keepAlive: true)
class SyncShareRefresh extends _$SyncShareRefresh {
  Future<void>? _inFlight;

  @override
  bool build() => false;

  /// Full silent or manual refresh. Concurrent calls share one in-flight request.
  Future<void> refresh({
    bool manual = false,
    SyncShareRefreshTrigger trigger = SyncShareRefreshTrigger.poll,
  }) async {
    // Background refreshes under an open Razorpay WebView freeze macOS.
    if (!manual && ref.read(subscriptionCheckoutBusyProvider)) {
      return;
    }
    if (!manual && ref.read(paymentCheckoutBusyProvider)) {
      return;
    }
    if (_inFlight != null) return _inFlight!;

    state = true;
    _inFlight = _runRefresh(manual: manual).whenComplete(() {
      _inFlight = null;
      state = false;
    });
    return _inFlight!;
  }

  /// After invite/cancel/role change/etc. Reuses the same pipeline.
  Future<void> refreshAfterMutation() {
    return refresh(
      trigger: SyncShareRefreshTrigger.mutation,
    );
  }

  bool get shouldPoll {
    return ref.read(syncShareLiveSyncBackendProvider).shouldPoll(ref);
  }

  Future<void> _runRefresh({required bool manual}) async {
    final backend = ref.read(syncShareLiveSyncBackendProvider);
    try {
      await backend.fetchUpdates(ref, manual: manual);
    } on Object {
      if (manual) rethrow;
      // Background refresh failures keep cached data.
    }
  }
}
