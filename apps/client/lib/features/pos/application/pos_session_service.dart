import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/connectivity_monitor.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/pos_session_dto.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'pos_session_service.g.dart';

const _localSessionPrefix = 'local-pos-';
const _uuid = Uuid();

@Riverpod(keepAlive: true)
Future<PosSessionService> posSessionService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  return PosSessionService(
    remote: SalesRemoteDataSource(api.dio),
    storage: storage,
    connectivityMonitor: ref.watch(connectivityMonitorProvider),
  );
}

class PosSessionService {
  PosSessionService({
    required this._remote,
    required this._storage,
    required ConnectivityMonitor connectivityMonitor,
  }) : _connectivity = connectivityMonitor;

  final SalesRemoteDataSource _remote;
  final StorageService _storage;
  final ConnectivityMonitor _connectivity;

  static bool isLocalSessionId(String sessionId) =>
      sessionId.startsWith(_localSessionPrefix);

  Future<PosSessionDto> getOrOpenSession() async {
    final connectivity = await _connectivity.checkNow();
    if (connectivity == SyncConnectivityStatus.online) {
      try {
        final session = await _openRemoteSession();
        await _clearLocalSession();
        return session;
      } on DioException {
        // Fall back to a persisted local session while offline or unreachable.
      }
    }

    return _getOrCreateLocalSession();
  }

  Future<void> closeSession({
    required String sessionId,
    double closingCash = 0,
  }) async {
    if (isLocalSessionId(sessionId)) {
      await _clearLocalSession();
      return;
    }

    try {
      await _remote.closePosSession(
        sessionId: sessionId,
        closingCash: closingCash.toStringAsFixed(4),
      );
    } on DioException {
      // Terminal can still close locally if backend close fails.
    }
  }

  Future<PosSessionDto> _openRemoteSession() async {
    final response = await _remote.listPosSessions(limit: 50);
    final activeSession = response.sessions.firstWhereOrNull(
      (session) => session.isOpen,
    );
    if (activeSession != null) {
      return activeSession;
    }

    return _remote.createPosSession(openingCash: '0');
  }

  Future<PosSessionDto> _getOrCreateLocalSession() async {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId) ?? '';
    if (businessId.isEmpty) {
      return _localSessionDto('$_localSessionPrefix${_uuid.v4()}');
    }

    final key = StorageKeys.localPosSessionId(businessId);
    final existingId = _storage.read(key);
    if (existingId != null && existingId.isNotEmpty) {
      return _localSessionDto(existingId);
    }

    final newId = '$_localSessionPrefix${_uuid.v4()}';
    await _storage.write(key, newId);
    return _localSessionDto(newId);
  }

  Future<void> _clearLocalSession() async {
    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId) ?? '';
    if (businessId.isEmpty) return;
    await _storage.remove(StorageKeys.localPosSessionId(businessId));
  }

  PosSessionDto _localSessionDto(String sessionId) {
    final now = DateTime.now().toUtc().toIso8601String();
    return PosSessionDto(
      id: sessionId,
      userId: 'local',
      startedAt: now,
      createdAt: now,
      updatedAt: now,
      openingCash: '0',
    );
  }
}
