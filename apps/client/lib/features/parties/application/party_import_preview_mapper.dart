import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/party_contact_import_models.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:billing_baba/features/utilities/models/import_party_preview_row.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:uuid/uuid.dart';

/// Builds Excel-style preview rows from phone contact staging payloads.
abstract final class PartyImportPreviewMapper {
  static const _uuid = Uuid();
  static const _defaultState = 'Andhra Pradesh';

  static List<ImportPartyPreviewRow> fromContactStaging({
    required List<PartyContactImportStagingRowDto> staging,
    required List<PartyModel> existingParties,
  }) {
    final existingNames = {
      for (final party in existingParties) party.name.trim().toLowerCase(),
    };
    final existingPhones = <String>{
      for (final party in existingParties) ..._partyPhoneKeys(party),
    };

    final seenNames = <String>{};
    final seenPhones = <String>{};

    return staging.asMap().entries.map((entry) {
      final index = entry.key;
      final row = entry.value;
      final sheetRowNumber = index + 1;
      final displayName = row.displayName.trim();
      final normalizedName = displayName.toLowerCase();
      final normalizedPhone = PartyModel.normalizePhone(row.primaryPhone);

      final display = _DisplayValues(
        mobile: normalizedPhone.isEmpty ? '-' : normalizedPhone,
        typeLabel: 'Customer',
        email: row.email?.trim() ?? '',
        gstin: '',
        state: _defaultState,
        partyGroup: '',
        openingBalance: '0.00',
      );

      if (displayName.isEmpty) {
        return _previewRow(
          sheetRowNumber: sheetRowNumber,
          partyName: displayName,
          display: display,
          status: ImportRowStatus.error,
          issueMessage: 'Party name is required',
        );
      }

      if (seenNames.contains(normalizedName)) {
        return _previewRow(
          sheetRowNumber: sheetRowNumber,
          partyName: displayName,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage: 'Duplicate party name in import',
        );
      }
      seenNames.add(normalizedName);

      if (existingNames.contains(normalizedName)) {
        return _previewRow(
          sheetRowNumber: sheetRowNumber,
          partyName: displayName,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage: 'Party already exists',
        );
      }

      final phoneError = Validators.requiredPhone(row.primaryPhone);
      if (phoneError != null) {
        return _previewRow(
          sheetRowNumber: sheetRowNumber,
          partyName: displayName,
          display: display,
          status: ImportRowStatus.error,
          issueMessage: phoneError,
        );
      }

      if (seenPhones.contains(normalizedPhone)) {
        return _previewRow(
          sheetRowNumber: sheetRowNumber,
          partyName: displayName,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage: 'Duplicate mobile number in import',
        );
      }
      seenPhones.add(normalizedPhone);

      if (existingPhones.contains(normalizedPhone)) {
        return _previewRow(
          sheetRowNumber: sheetRowNumber,
          partyName: displayName,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage:
              'This mobile number is already registered to another party',
        );
      }

      final email = row.email?.trim() ?? '';
      if (email.isNotEmpty) {
        final emailError = Validators.email(email);
        if (emailError != null) {
          return _previewRow(
            sheetRowNumber: sheetRowNumber,
            partyName: displayName,
            display: display,
            status: ImportRowStatus.error,
            issueMessage: emailError,
          );
        }
      }

      final importResult = AddPartyResult(
        partyName: displayName,
        partyType: 'customer',
        phone: normalizedPhone,
        email: email,
        gstin: '',
        state: _defaultState,
        partyGroup: '',
        openingBalance: '0.00',
        billingAddress: row.address?.trim() ?? '',
      );

      return _previewRow(
        sheetRowNumber: sheetRowNumber,
        partyName: displayName,
        display: display,
        status: ImportRowStatus.valid,
        isSelected: true,
        importResult: importResult,
      );
    }).toList();
  }

  static Set<String> _partyPhoneKeys(PartyModel party) {
    final keys = <String>{
      PartyModel.normalizePhone(party.phone),
      ...party.additionalPhones.map(PartyModel.normalizePhone),
    };
    keys.removeWhere((phone) => phone.isEmpty);
    return keys;
  }

  static ImportPartyPreviewRow _previewRow({
    required int sheetRowNumber,
    required String partyName,
    required _DisplayValues display,
    required ImportRowStatus status,
    String? issueMessage,
    bool isSelected = false,
    AddPartyResult? importResult,
  }) {
    return ImportPartyPreviewRow(
      id: _uuid.v4(),
      sheetRowNumber: sheetRowNumber,
      partyName: partyName,
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
