import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';

class ImportPartyPreviewRow {
  const ImportPartyPreviewRow({
    required this.id,
    required this.sheetRowNumber,
    required this.partyName,
    required this.mobile,
    required this.typeLabel,
    required this.email,
    required this.gstin,
    required this.state,
    required this.partyGroup,
    required this.openingBalance,
    required this.status,
    this.issueMessage,
    this.isSelected = false,
    this.importResult,
  });

  final String id;
  final int sheetRowNumber;
  final String partyName;
  final String mobile;
  final String typeLabel;
  final String email;
  final String gstin;
  final String state;
  final String partyGroup;
  final String openingBalance;
  final ImportRowStatus status;
  final String? issueMessage;
  final bool isSelected;
  final AddPartyResult? importResult;

  bool get canImport =>
      status == ImportRowStatus.valid &&
      isSelected &&
      importResult != null;

  ImportPartyPreviewRow copyWith({
    ImportRowStatus? status,
    String? issueMessage,
    bool? isSelected,
    AddPartyResult? importResult,
  }) {
    return ImportPartyPreviewRow(
      id: id,
      sheetRowNumber: sheetRowNumber,
      partyName: partyName,
      mobile: mobile,
      typeLabel: typeLabel,
      email: email,
      gstin: gstin,
      state: state,
      partyGroup: partyGroup,
      openingBalance: openingBalance,
      status: status ?? this.status,
      issueMessage: issueMessage ?? this.issueMessage,
      isSelected: isSelected ?? this.isSelected,
      importResult: importResult ?? this.importResult,
    );
  }
}

class ImportPartiesResult {
  const ImportPartiesResult({
    required this.successCount,
    required this.failedCount,
    required this.skippedCount,
    this.errors = const [],
  });

  final int successCount;
  final int failedCount;
  final int skippedCount;
  final List<String> errors;
}
