import 'dart:async';

import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:flutter/widgets.dart';

typedef SyncScheduleCallback = void Function(SyncScheduleTrigger trigger);

enum SyncScheduleTrigger {
  appStartup,
  connectivityRestored,
  manualRefresh,
  periodicTimer,
  applicationResume,
}

/// Schedules sync triggers without executing sync work.
class SyncScheduler with WidgetsBindingObserver {
  SyncScheduler({
    this.periodicInterval = const Duration(minutes: 5),
    this._onTrigger,
  });

  final Duration periodicInterval;
  SyncScheduleCallback? _onTrigger;

  Timer? _periodic;
  bool _started = false;
  SyncConnectivityStatus _lastConnectivity = SyncConnectivityStatus.unknown;
  DateTime? _nextScheduledSync;

  bool get isStarted => _started;
  DateTime? get nextScheduledSync => _nextScheduledSync;

  void setCallback(SyncScheduleCallback callback) {
    _onTrigger = callback;
  }

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _armPeriodic();
    LoggingService.instance.info('SyncScheduler started');
    _emit(SyncScheduleTrigger.appStartup);
  }

  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _periodic?.cancel();
    _periodic = null;
    _nextScheduledSync = null;
    LoggingService.instance.info('SyncScheduler stopped');
  }

  void requestManualRefresh() {
    _emit(SyncScheduleTrigger.manualRefresh);
  }

  void onConnectivityChanged(SyncConnectivityStatus status) {
    final wasOffline = _lastConnectivity == SyncConnectivityStatus.offline ||
        _lastConnectivity == SyncConnectivityStatus.unknown;
    _lastConnectivity = status;
    if (status == SyncConnectivityStatus.online && wasOffline) {
      _emit(SyncScheduleTrigger.connectivityRestored);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _emit(SyncScheduleTrigger.applicationResume);
    }
  }

  void _armPeriodic() {
    _periodic?.cancel();
    _nextScheduledSync = DateTime.now().toUtc().add(periodicInterval);
    _periodic = Timer.periodic(periodicInterval, (_) {
      _nextScheduledSync = DateTime.now().toUtc().add(periodicInterval);
      _emit(SyncScheduleTrigger.periodicTimer);
    });
  }

  void _emit(SyncScheduleTrigger trigger) {
    LoggingService.instance.info('SyncScheduler trigger: $trigger');
    _onTrigger?.call(trigger);
  }

  void dispose() {
    stop();
  }
}
