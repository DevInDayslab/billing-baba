import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/payments/application/payment_analytics.dart';
import 'package:billing_baba/features/payments/application/payment_providers.dart';
import 'package:billing_baba/features/payments/application/payment_service.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentRecoveryPendingProvider =
    NotifierProvider<PaymentRecoveryPending, bool>(PaymentRecoveryPending.new);

class PaymentRecoveryPending extends Notifier<bool> {
  @override
  bool build() => false;

  void setPending(bool value) => state = value;
}

/// Retries pending verification on resume, reconnect, and periodic poll.
class PaymentRecoveryService {
  PaymentRecoveryService(this._ref);

  final Ref _ref;
  Timer? _pollTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Future<void> initialize() async {
    if (!AppConfig.paymentRecoveryEnabled) return;

    await recoverPending();

    _pollTimer = Timer.periodic(AppConfig.paymentRecoveryPollInterval, (_) {
      unawaited(recoverPending());
    });

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) unawaited(recoverPending());
    });
  }

  Future<void> recoverPending() async {
    if (!AppConfig.paymentRecoveryEnabled) return;

    try {
      await _recoverPendingBody();
    } on Object catch (e, st) {
      // Never crash startup/resume when local DB isn't ready yet.
      assert(() {
        debugPrint('PaymentRecoveryService.recoverPending failed: $e\n$st');
        return true;
      }());
    }
  }

  Future<void> _recoverPendingBody() async {
    final repo = await _ref.read(paymentRepositoryProvider.future);
    final sessions = await repo.listPendingSessions();
    if (sessions.isEmpty) {
      _ref.read(paymentRecoveryPendingProvider.notifier).setPending(false);
      return;
    }

    _ref.read(paymentRecoveryPendingProvider.notifier).setPending(true);
    final paymentService = PaymentService(repository: repo);

    for (final session in sessions) {
      if (session.paymentId == null || session.signature == null) {
        if (AppConfig.paymentWebhookRecovery) {
          final status = await repo.getStatus(session.intentId);
          if (status.status == PaymentVerificationStatus.verified) {
            await repo.clearSession(session.intentId);
            PaymentAnalytics.recoverySucceeded(
              intentId: session.intentId,
              retryCount: session.verifyAttempts,
            );
            continue;
          }
        }
        continue;
      }

      await repo.incrementRetry(session.intentId);
      final result = await paymentService.verifyPending(
        intentId: session.intentId,
        callback: RazorpayCheckoutCallback(
          paymentId: session.paymentId!,
          orderId: session.razorpayOrderId,
          signature: session.signature!,
        ),
      );

      if (result.isSuccess) {
        PaymentAnalytics.recoverySucceeded(
          intentId: session.intentId,
          retryCount: session.verifyAttempts + 1,
        );
      }
    }

    final remaining = await repo.listPendingSessions();
    _ref.read(paymentRecoveryPendingProvider.notifier).setPending(
      remaining.isNotEmpty,
    );
  }

  void dispose() {
    _pollTimer?.cancel();
    unawaited(_connectivitySub?.cancel());
  }
}

final paymentRecoveryServiceProvider = Provider<PaymentRecoveryService>((ref) {
  final service = PaymentRecoveryService(ref);
  ref.onDispose(service.dispose);
  return service;
});

/// Wires recovery to app lifecycle (resume + startup).
class PaymentRecoveryLifecycle extends ConsumerStatefulWidget {
  const PaymentRecoveryLifecycle({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PaymentRecoveryLifecycle> createState() =>
      _PaymentRecoveryLifecycleState();
}

class _PaymentRecoveryLifecycleState extends ConsumerState<PaymentRecoveryLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(paymentRecoveryServiceProvider).initialize());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(paymentRecoveryServiceProvider).recoverPending());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
