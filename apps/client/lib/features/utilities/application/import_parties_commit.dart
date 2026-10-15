import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/utilities/models/import_party_preview_row.dart';
Future<ImportPartiesResult?> commitImportPartyRows(
  PartyList partyListNotifier,
  List<ImportPartyPreviewRow> rows,
) async {
  final rowsToImport = rows.where((row) => row.canImport).toList();
  if (rowsToImport.isEmpty) return null;

  var successCount = 0;
  var failedCount = 0;
  final errors = <String>[];

  for (final row in rowsToImport) {
    try {
      final result = row.importResult;
      if (result == null) {
        throw const PartyException('Party data is incomplete.');
      }
      await partyListNotifier.createParty(result, selectCreated: false);
      successCount++;
    } on ApiValidationException catch (error) {
      failedCount++;
      final nameError = error.fieldErrors['name'];
      final mobileError = error.fieldErrors['mobile'];
      errors.add(
        '${row.partyName}: ${nameError ?? mobileError ?? error.message}',
      );
    } on PartyException catch (error) {
      failedCount++;
      errors.add('${row.partyName}: ${error.message}');
    } on Object catch (error) {
      failedCount++;
      errors.add('${row.partyName}: ${PartyErrorMapper.messageFor(error)}');
    }
  }

  return ImportPartiesResult(
    successCount: successCount,
    failedCount: failedCount,
    skippedCount: rows.length - rowsToImport.length,
    errors: errors,
  );
}
