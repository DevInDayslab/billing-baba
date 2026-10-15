import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/utilities/application/import_parties_commit.dart';
import 'package:billing_baba/features/utilities/application/import_parties_excel_parser.dart';
import 'package:billing_baba/features/utilities/application/import_parties_excel_service.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:billing_baba/features/utilities/models/import_party_preview_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportPartiesExcelState {
  const ImportPartiesExcelState({
    this.fileName,
    this.isParsing = false,
    this.isImporting = false,
    this.rows = const [],
    this.importCompleted = 0,
    this.importTotal = 0,
    this.parseError,
    this.importError,
  });

  final String? fileName;
  final bool isParsing;
  final bool isImporting;
  final List<ImportPartyPreviewRow> rows;
  final int importCompleted;
  final int importTotal;
  final String? parseError;
  final String? importError;

  bool get showParseSuccess =>
      !isParsing && rows.isNotEmpty && parseError == null;

  int get validCount =>
      rows.where((row) => row.status == ImportRowStatus.valid).length;

  int get duplicateCount =>
      rows.where((row) => row.status == ImportRowStatus.duplicate).length;

  int get errorCount =>
      rows.where((row) => row.status == ImportRowStatus.error).length;

  int get selectedCount => rows.where((row) => row.canImport).length;

  bool get canImport => selectedCount > 0 && !isImporting && !isParsing;

  ImportPartiesExcelState copyWith({
    String? fileName,
    bool? isParsing,
    bool? isImporting,
    List<ImportPartyPreviewRow>? rows,
    int? importCompleted,
    int? importTotal,
    String? parseError,
    String? importError,
    bool clearParseError = false,
    bool clearRows = false,
    bool clearImportError = false,
  }) {
    return ImportPartiesExcelState(
      fileName: fileName ?? this.fileName,
      isParsing: isParsing ?? this.isParsing,
      isImporting: isImporting ?? this.isImporting,
      rows: clearRows ? const [] : (rows ?? this.rows),
      importCompleted: importCompleted ?? this.importCompleted,
      importTotal: importTotal ?? this.importTotal,
      parseError: clearParseError ? null : (parseError ?? this.parseError),
      importError: clearImportError ? null : (importError ?? this.importError),
    );
  }
}

final importPartiesExcelProvider =
    NotifierProvider<ImportPartiesExcelNotifier, ImportPartiesExcelState>(
      ImportPartiesExcelNotifier.new,
    );

class ImportPartiesExcelNotifier extends Notifier<ImportPartiesExcelState> {
  @override
  ImportPartiesExcelState build() => const ImportPartiesExcelState();

  void beginParsing(String fileName) {
    state = state.copyWith(
      fileName: fileName,
      isParsing: true,
      clearRows: true,
      clearParseError: true,
      clearImportError: true,
    );
  }

  void cancelParsing({String? error}) {
    state = state.copyWith(
      isParsing: false,
      parseError: error,
    );
  }

  Future<void> parseBytes(List<int> bytes) async {
    if (!state.isParsing) {
      state = state.copyWith(isParsing: true, clearParseError: true);
    }

    try {
      await Future<void>.delayed(Duration.zero);

      final parsed = ImportPartiesExcelParser.parse(bytes);
      await ref.read(partyListProvider.future);
      final existingParties = ref.read(partiesListProvider);

      final rows = ImportPartiesExcelService.buildPreviewRows(
        parsedRows: parsed,
        existingParties: existingParties,
      );

      if (rows.isEmpty) {
        state = state.copyWith(
          isParsing: false,
          parseError: 'No parties found in the uploaded file.',
        );
        return;
      }

      state = state.copyWith(
        isParsing: false,
        rows: rows,
        clearParseError: true,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isParsing: false,
        parseError: 'Failed to read file: $error',
      );
    }
  }

  void toggleRowSelection(String rowId, {required bool selected}) {
    state = state.copyWith(
      rows: [
        for (final row in state.rows)
          if (row.id == rowId && row.status == ImportRowStatus.valid)
            row.copyWith(isSelected: selected)
          else
            row,
      ],
    );
  }

  void selectAllValid({required bool selected}) {
    state = state.copyWith(
      rows: [
        for (final row in state.rows)
          row.status == ImportRowStatus.valid
              ? row.copyWith(isSelected: selected)
              : row,
      ],
    );
  }

  Future<ImportPartiesResult?> confirmImport() async {
    final rowsToImport = state.rows.where((row) => row.canImport).toList();
    if (rowsToImport.isEmpty || state.isImporting || state.isParsing) {
      return null;
    }

    state = state.copyWith(
      isImporting: true,
      importCompleted: 0,
      importTotal: rowsToImport.length,
      clearImportError: true,
    );

    try {
      final result = await commitImportPartyRows(
        ref.read(partyListProvider.notifier),
        state.rows,
      );
      state = state.copyWith(
        isImporting: false,
        importCompleted: rowsToImport.length,
        importTotal: rowsToImport.length,
      );
      return result;
    } on Object catch (error) {
      state = state.copyWith(
        isImporting: false,
        importError: PartyErrorMapper.messageFor(error),
      );
      rethrow;
    }
  }

  void reset() => state = const ImportPartiesExcelState();
}
