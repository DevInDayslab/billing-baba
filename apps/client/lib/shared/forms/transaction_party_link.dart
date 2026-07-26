import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';

/// Party-related field values extracted from a linked [PartyModel].
class TransactionPartyFields {
  const TransactionPartyFields({
    required this.partyId,
    required this.partyName,
    this.phone = '',
    this.billingAddress = '',
    this.shippingAddress = '',
    this.stateOfSupply = '',
    this.gstin = '',
    this.email = '',
    this.businessName = '',
    this.creditLimit = '',
    this.outstanding = '',
    this.partyPriceTier = PriceTier.retail,
  });

  final String partyId;
  final String partyName;
  final String phone;
  final String billingAddress;
  final String shippingAddress;
  final String stateOfSupply;
  final String gstin;
  final String email;
  final String businessName;
  final String creditLimit;
  final String outstanding;
  final String partyPriceTier;
}

/// Values used when clearing a party link while optionally keeping the typed name.
class ClearedPartyLinkFields {
  const ClearedPartyLinkFields({
    this.partyName = '',
    this.clearPartyId = true,
    this.clearPartyPriceTier = true,
  });

  final String partyName;
  final bool clearPartyId;
  final bool clearPartyPriceTier;
}

/// Whether a free-text party name edit should unlink the current [partyId].
bool shouldClearPartyIdOnNameEdit({
  required String newName,
  required String previousName,
  required String? currentPartyId,
}) {
  if (currentPartyId == null || currentPartyId.isEmpty) return false;
  return newName.trim() != previousName.trim();
}

/// Builds party field values from a selected [PartyModel].
TransactionPartyFields partyFieldsFromModel(
  PartyModel party, {
  String? currentStateOfSupply,
}) {
  return TransactionPartyFields(
    partyId: party.id,
    partyName: party.name,
    phone: Validators.normalizeIndianPhone(party.phone) ?? '',
    billingAddress: party.billingAddress.isNotEmpty
        ? party.billingAddress
        : party.addressLine,
    shippingAddress: party.shippingAddress.isNotEmpty
        ? party.shippingAddress
        : party.shippingAddressLine,
    stateOfSupply: party.state.isNotEmpty
        ? party.state
        : (currentStateOfSupply ?? ''),
    gstin: party.gstin,
    email: party.email,
    businessName: party.additionalField1.isNotEmpty
        ? party.additionalField1
        : party.name,
    creditLimit: PartyModel.displayCreditLimit(
      hasCustomCreditLimit: party.hasCustomCreditLimit,
      creditLimit: party.creditLimit,
    ),
    outstanding: PartyModel.displayOutstanding(party.balance),
    partyPriceTier: party.defaultPriceTier,
  );
}

/// Field values for clearing a party link (keeps typed name when provided).
ClearedPartyLinkFields clearedPartyLinkFields({String partyName = ''}) {
  return ClearedPartyLinkFields(partyName: partyName);
}

/// Result of editing a party name without using the party picker.
({String partyName, bool clearPartyId}) unlinkedPartyNameChange({
  required String newName,
  required String previousName,
  required String? currentPartyId,
}) {
  return (
    partyName: newName,
    clearPartyId: shouldClearPartyIdOnNameEdit(
      newName: newName,
      previousName: previousName,
      currentPartyId: currentPartyId,
    ),
  );
}
