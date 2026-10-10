import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/utilities/application/import_parties_excel_parser.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:billing_baba/features/utilities/models/import_party_preview_row.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:uuid/uuid.dart';

abstract final class ImportPartiesExcelService {
  static const _uuid = Uuid();
  static const _defaultState = 'Andhra Pradesh';

  static List<ImportPartyPreviewRow> buildPreviewRows({
    required List<ParsedImportPartyExcelRow> parsedRows,
    required List<PartyModel> existingParties,
  }) {
    final existingNames = {
      for (final party in existingParties) party.name.trim().toLowerCase(),
    };
    final existingPhones = <String>{
      for (final party in existingParties) ..._partyPhoneKeys(party),
    };
    final existingGstins = {
      for (final party in existingParties)
        if (party.gstin.trim().isNotEmpty)
          party.gstin.trim().toUpperCase(),
    };

    final seenNames = <String>{};
    final seenPhones = <String>{};
    final seenGstins = <String>{};

    return parsedRows.map((row) {
      final display = _displayValues(row);
      final normalizedName = row.partyName.trim().toLowerCase();
      final normalizedPhone = PartyModel.normalizePhone(row.mobile);

      if (row.partyName.trim().isEmpty) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.error,
          issueMessage: 'Party name is required',
        );
      }

      if (seenNames.contains(normalizedName)) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage: 'Duplicate party name in file',
        );
      }
      seenNames.add(normalizedName);

      if (existingNames.contains(normalizedName)) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage: 'Party already exists',
        );
      }

      final phoneError = Validators.requiredPhone(row.mobile);
      if (phoneError != null) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.error,
          issueMessage: phoneError,
        );
      }

      if (seenPhones.contains(normalizedPhone)) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage: 'Duplicate mobile number in file',
        );
      }
      seenPhones.add(normalizedPhone);

      if (existingPhones.contains(normalizedPhone)) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage:
              'This mobile number is already registered to another party',
        );
      }

      final gstin = row.gstin.trim();
      if (gstin.isNotEmpty) {
        final gstinUpper = gstin.toUpperCase();
        if (seenGstins.contains(gstinUpper)) {
          return _previewRow(
            row: row,
            display: display,
            status: ImportRowStatus.duplicate,
            issueMessage: 'Duplicate GSTIN in file',
          );
        }
        seenGstins.add(gstinUpper);

        if (existingGstins.contains(gstinUpper)) {
          return _previewRow(
            row: row,
            display: display,
            status: ImportRowStatus.duplicate,
            issueMessage: 'GSTIN is already registered to another party',
          );
        }

        final gstinError = Validators.gstin(gstin);
        if (gstinError != null) {
          return _previewRow(
            row: row,
            display: display,
            status: ImportRowStatus.error,
            issueMessage: gstinError,
          );
        }
      }

      final email = row.email.trim();
      if (email.isNotEmpty) {
        final emailError = Validators.email(email);
        if (emailError != null) {
          return _previewRow(
            row: row,
            display: display,
            status: ImportRowStatus.error,
            issueMessage: emailError,
          );
        }
      }

      final openingBalance =
          Validators.normalizeDecimalString(row.openingBalance) ?? '0.00';

      final importResult = AddPartyResult(
        partyName: row.partyName.trim(),
        partyType: _parsePartyType(row.partyType),
        phone: normalizedPhone,
        email: email,
        gstin: gstin.isEmpty ? '' : gstin.toUpperCase(),
        state: row.state.trim().isEmpty ? _defaultState : row.state.trim(),
        partyGroup: row.partyGroup.trim(),
        openingBalance: openingBalance,
      );

      return _previewRow(
        row: row,
        display: display,
        status: ImportRowStatus.valid,
        isSelected: true,
        importResult: importResult,
      );
    }).toList();
  }

  static ImportPartyPreviewRow _previewRow({
    required ParsedImportPartyExcelRow row,
    required _DisplayValues display,
    required ImportRowStatus status,
    String? issueMessage,
    bool isSelected = false,
    AddPartyResult? importResult,
  }) {
    return ImportPartyPreviewRow(
      id: _uuid.v4(),
      sheetRowNumber: row.sheetRowNumber,
      partyName: row.partyName,
      mobile: display.mobile,
      typeLabel: display.typeLabel,
      email: display.email,
      gstin: display.gstin,
      state: display.state,
      partyGroup: display.partyGroup,
      openingBalance: display.openingBalance,
      status: status,
      issueMessage: issueMessage,
      isSelected: isSelected,
      importResult: importResult,
    );
  }

  static _DisplayValues _displayValues(ParsedImportPartyExcelRow row) {
    final type = _parsePartyType(row.partyType);
    final phone = row.mobile.trim().isEmpty
        ? '-'
        : PartyModel.normalizePhone(row.mobile);

    return _DisplayValues(
      mobile: phone,
      typeLabel: type,
      email: row.email.trim().isEmpty ? '-' : row.email.trim(),
      gstin: row.gstin.trim().isEmpty ? '-' : row.gstin.trim().toUpperCase(),
      state: row.state.trim().isEmpty ? _defaultState : row.state.trim(),
      partyGroup: row.partyGroup.trim().isEmpty ? '-' : row.partyGroup.trim(),
      openingBalance: _formatDisplayAmount(row.openingBalance),
    );
  }

  static String _parsePartyType(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.startsWith('supplier')) return 'supplier';
    if (value.startsWith('both')) return 'both';
    return 'customer';
  }

  static String _formatDisplayAmount(String raw) {
    if (raw.trim().isEmpty) return '0.00';
    final normalized = Validators.normalizeDecimalString(raw);
    return normalized ?? raw.trim();
  }

  static Iterable<String> _partyPhoneKeys(PartyModel party) {
    final keys = <String>{
      PartyModel.normalizePhone(party.phone),
      ...party.additionalPhones.map(PartyModel.normalizePhone),
    };
    keys.removeWhere((phone) => phone.isEmpty);
    return keys;
  }
}

class _DisplayValues {
  const _DisplayValues({
    required this.mobile,
    required this.typeLabel,
    required this.email,
    required this.gstin,
    required this.state,
    required this.partyGroup,
    required this.openingBalance,
  });

  final String mobile;
  final String typeLabel;
  final String email;
  final String gstin;
  final String state;
  final String partyGroup;
  final String openingBalance;
}
