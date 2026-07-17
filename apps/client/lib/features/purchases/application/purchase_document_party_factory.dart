import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/purchases/application/purchase_document_parse_mapper.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';

/// Builds party-creation payloads from a parsed purchase document.
class PurchaseDocumentPartyFactory {
  const PurchaseDocumentPartyFactory._();

  static final _gstinPattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );

  static bool needsCreation(
    PurchaseDocumentParseDto parsed,
    List<PartyModel> parties,
  ) {
    if (PurchaseDocumentParseMapper.resolveParty(parsed, parties) != null) {
      return false;
    }

    final name = parsed.vendorName?.trim();
    return name != null && name.isNotEmpty;
  }

  static AddPartyResult toAddPartyResult(PurchaseDocumentParseDto parsed) {
    final name = parsed.vendorName!.trim();
    final gstin = _sanitizeGstin(parsed.gstin);
    final hasGstin = gstin.isNotEmpty;
    final state = _resolveState(parsed);
    final address = parsed.vendorAddress?.trim() ?? '';

    return AddPartyResult(
      partyName: name,
      partyType: 'supplier',
      gstin: gstin,
      phone: _sanitizePhone(parsed.vendorPhone),
      email: _sanitizeEmail(parsed.vendorEmail),
      gstType: hasGstin
          ? 'Registered Business - Regular'
          : 'Unregistered/Consumer',
      state: state,
      addressLine: address,
      billingAddress: address,
      shippingAddress: address,
      shippingAddressLine: address,
      city: parsed.vendorCity?.trim() ?? '',
      pincode: parsed.vendorPincode?.trim() ?? '',
      shippingCity: parsed.vendorCity?.trim() ?? '',
      shippingPincode: parsed.vendorPincode?.trim() ?? '',
    );
  }

  static String _sanitizeGstin(String? value) {
    final normalized =
        value?.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '') ?? '';
    if (normalized.isEmpty) return '';
    if (Validators.gstin(normalized) != null) return '';
    return _gstinPattern.hasMatch(normalized) ? normalized : '';
  }

  static String _sanitizeEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    return Validators.email(trimmed) == null ? trimmed : '';
  }

  static String _sanitizePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    final normalized = PartyModel.normalizePhone(trimmed);
    return normalized.length == 10 ? normalized : '';
  }

  static String _resolveState(PurchaseDocumentParseDto parsed) {
    final vendorState = parsed.vendorState?.trim();
    if (vendorState != null && vendorState.isNotEmpty) {
      return vendorState;
    }

    final placeOfSupply = parsed.stateOfSupply?.trim();
    if (placeOfSupply != null && placeOfSupply.isNotEmpty) {
      return placeOfSupply;
    }

    return '';
  }
}
