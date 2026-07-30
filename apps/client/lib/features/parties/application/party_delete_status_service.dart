import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/data/party_delete_status_repository.dart';
import 'package:billing_baba/features/parties/models/delete_status_response.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'party_delete_status_service.g.dart';

@riverpod
Future<PartyDeleteStatusService> partyDeleteStatusService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return PartyDeleteStatusService(
    repository: PartyDeleteStatusRepository(api.dio),
  );
}

class PartyDeleteStatusService {
  PartyDeleteStatusService({
    required this._repository,
  });

  final PartyDeleteStatusRepository _repository;

  Future<DeleteStatusResponse> getDeleteStatus(String partyId) async {
    try {
      final dto = await _repository.getDeleteStatus(partyId);
      return DeleteStatusResponse.fromDto(dto);
    } on DioException catch (e) {
      PartyErrorMapper.mapAndThrow(e);
    }
  }
}
