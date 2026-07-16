import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/pos_session_dto.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_session_service.g.dart';

@Riverpod(keepAlive: true)
Future<PosSessionService> posSessionService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return PosSessionService(SalesRemoteDataSource(api.dio));
}

class PosSessionService {
  PosSessionService(this._remote);

  final SalesRemoteDataSource _remote;

  Future<PosSessionDto> getOrOpenSession() async {
    try {
      final response = await _remote.listPosSessions(limit: 50);
      final activeSession = response.sessions.firstWhereOrNull(
        (session) => session.isOpen,
      );
      if (activeSession != null) {
        return activeSession;
      }

      return _remote.createPosSession(openingCash: '0');
    } on DioException {
      rethrow;
    }
  }

  Future<void> closeSession({
    required String sessionId,
    double closingCash = 0,
  }) async {
    await _remote.closePosSession(
      sessionId: sessionId,
      closingCash: closingCash.toStringAsFixed(4),
    );
  }
}
