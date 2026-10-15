import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/data/party_contact_import_api.dart';
import 'package:billing_baba/features/parties/models/party_contact_import_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partyContactImportServiceProvider = Provider<PartyContactImportService>(
  (ref) => PartyContactImportService(ref),
);

class PartyContactImportService {
  PartyContactImportService(this._ref);

  final Ref _ref;

  Future<PartyContactImportSessionCreated> createSession() async {
    final api = await _ref.read(apiClientProvider.future);
    return PartyContactImportApi(api.dio).createSession();
  }

  Future<PartyContactImportSession> pollSession(
    String sessionId, {
    bool includeStaging = false,
  }) async {
    final api = await _ref.read(apiClientProvider.future);
    return PartyContactImportApi(api.dio).getSession(
      sessionId,
      includeStaging: includeStaging,
    );
  }

  Future<PartyContactImportSession> loadByToken(String token) async {
    final api = await _ref.read(apiClientProvider.future);
    return PartyContactImportApi(api.dio).getSessionByToken(token);
  }

  Future<PartyContactImportSession> submitContacts(
    String token,
    List<PartyContactImportStagingRowDto> contacts,
  ) async {
    final api = await _ref.read(apiClientProvider.future);
    return PartyContactImportApi(api.dio).submitStaging(token, contacts);
  }

  Future<void> commitSession(String sessionId) async {
    final api = await _ref.read(apiClientProvider.future);
    await PartyContactImportApi(api.dio).commitSession(sessionId);
  }
}
