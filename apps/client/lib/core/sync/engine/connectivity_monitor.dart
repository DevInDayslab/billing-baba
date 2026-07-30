import 'dart:async';

import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps [Connectivity] for the sync runtime.
class ConnectivityMonitor {
  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final _controller = StreamController<SyncConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  SyncConnectivityStatus _status = SyncConnectivityStatus.unknown;

  SyncConnectivityStatus get status => _status;

  Stream<SyncConnectivityStatus> get onStatusChanged => _controller.stream;

  Future<void> start() async {
    await _subscription?.cancel();
    await _refresh();
    _subscription = _connectivity.onConnectivityChanged.listen(_apply);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<SyncConnectivityStatus> checkNow() async {
    await _refresh();
    return _status;
  }

  Future<void> _refresh() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _apply(results);
    } on Object catch (e) {
      LoggingService.instance.warn('ConnectivityMonitor check failed: $e');
      _set(SyncConnectivityStatus.unknown);
    }
  }

  void _apply(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none)) {
      _set(SyncConnectivityStatus.offline);
      return;
    }
    _set(SyncConnectivityStatus.online);
  }

  void _set(SyncConnectivityStatus next) {
    if (_status == next) return;
    _status = next;
    if (!_controller.isClosed) {
      _controller.add(next);
    }
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
