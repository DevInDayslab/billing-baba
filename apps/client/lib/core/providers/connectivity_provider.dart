import 'dart:async';

import 'package:billing_baba/core/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device currently has network connectivity.
final networkConnectivityProvider =
    NotifierProvider<NetworkConnectivityNotifier, bool>(
      NetworkConnectivityNotifier.new,
    );

class NetworkConnectivityNotifier extends Notifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  bool build() {
    final service = ConnectivityService();
    ref.onDispose(() => unawaited(_subscription?.cancel()));

    _subscription = service.onConnectivityChanged.listen((results) {
      state = _isConnected(results);
    });

    unawaited(
      service.isConnected.then((connected) {
        if (ref.mounted) state = connected;
      }),
    );

    return true;
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return !results.contains(ConnectivityResult.none);
  }
}
