import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/utils/party_group_names.dart';

/// Local-only UI fields not yet stored on the API.
class PartyLocalExtension {
  const PartyLocalExtension({
    this.gstType = '',
    this.billingAddress = '',
    this.shippingAddress = '',
    this.partyGroup = '',
    this.addressLine = '',
    this.city = '',
    this.pincode = '',
    this.country = 'India',
    this.shippingAddressLine = '',
    this.shippingCity = '',
    this.shippingPincode = '',
    this.shippingCountry = 'India',
    this.openingBalanceAsOfDate,
    this.loyaltyPointsOpeningBalance = '',
    this.loyaltyPointsAsOfDate,
    this.loyaltyPointsBalance = '',
    this.additionalField1 = '',
    this.additionalField2 = '',
    this.defaultPriceTier = '',
    this.additionalPhones = const [],
  });

  factory PartyLocalExtension.fromJson(Map<String, dynamic> json) {
    return PartyLocalExtension(
      gstType: json['gst_type'] as String? ?? '',
      billingAddress: json['billing_address'] as String? ?? '',
      shippingAddress: json['shipping_address'] as String? ?? '',
      partyGroup: json['party_group'] as String? ?? '',
      addressLine: json['address_line'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
      shippingAddressLine: json['shipping_address_line'] as String? ?? '',
      shippingCity: json['shipping_city'] as String? ?? '',
      shippingPincode: json['shipping_pincode'] as String? ?? '',
      shippingCountry: json['shipping_country'] as String? ?? 'India',
      openingBalanceAsOfDate: json['opening_balance_as_of_date'] != null
          ? DateTime.tryParse(json['opening_balance_as_of_date'] as String)
          : null,
      loyaltyPointsOpeningBalance:
          json['loyalty_points_opening_balance'] as String? ?? '',
      loyaltyPointsAsOfDate: json['loyalty_points_as_of_date'] != null
          ? DateTime.tryParse(json['loyalty_points_as_of_date'] as String)
          : null,
      loyaltyPointsBalance: json['loyalty_points_balance'] as String? ?? '',
      additionalField1: json['additional_field_1'] as String? ?? '',
      additionalField2: json['additional_field_2'] as String? ?? '',
      defaultPriceTier: json['default_price_tier'] as String? ?? '',
      additionalPhones: json['additional_phones'] is List
          ? (json['additional_phones'] as List)
                .map((phone) => phone.toString())
                .toList()
          : const [],
    );
  }

  factory PartyLocalExtension.fromAddPartyResult(AddPartyResult result) {
    return PartyLocalExtension(
      gstType: result.gstType,
      billingAddress: result.billingAddress,
      shippingAddress: result.shippingAddress,
      partyGroup: result.partyGroup,
      addressLine: result.addressLine,
      city: result.city,
      pincode: result.pincode,
      country: result.country,
      shippingAddressLine: result.shippingAddressLine,
      shippingCity: result.shippingCity,
      shippingPincode: result.shippingPincode,
      shippingCountry: result.shippingCountry,
      openingBalanceAsOfDate: result.openingBalanceAsOfDate,
      loyaltyPointsOpeningBalance: result.loyaltyPointsOpeningBalance,
      loyaltyPointsAsOfDate: result.loyaltyPointsAsOfDate,
      loyaltyPointsBalance: _initialLoyaltyBalance(
        result.loyaltyPointsOpeningBalance,
      ),
      additionalField1: result.additionalField1Enabled
          ? result.additionalField1
          : '',
      additionalField2: result.additionalField2Enabled
          ? result.additionalField2
          : '',
      defaultPriceTier: result.defaultPriceTier,
      additionalPhones: result.additionalPhones,
    );
  }

  final String gstType;
  final String billingAddress;
  final String shippingAddress;
  final String partyGroup;
  final String addressLine;
  final String city;
  final String pincode;
  final String country;
  final String shippingAddressLine;
  final String shippingCity;
  final String shippingPincode;
  final String shippingCountry;
  final DateTime? openingBalanceAsOfDate;
  final String loyaltyPointsOpeningBalance;
  final DateTime? loyaltyPointsAsOfDate;
  final String loyaltyPointsBalance;
  final String additionalField1;
  final String additionalField2;
  final String defaultPriceTier;
  final List<String> additionalPhones;

  Map<String, dynamic> toJson() => {
    'gst_type': gstType,
    'billing_address': billingAddress,
    'shipping_address': shippingAddress,
    'party_group': partyGroup,
    'address_line': addressLine,
    'city': city,
    'pincode': pincode,
    'country': country,
    'shipping_address_line': shippingAddressLine,
    'shipping_city': shippingCity,
    'shipping_pincode': shippingPincode,
    'shipping_country': shippingCountry,
    if (openingBalanceAsOfDate != null)
      'opening_balance_as_of_date': openingBalanceAsOfDate!.toIso8601String(),
    'loyalty_points_opening_balance': loyaltyPointsOpeningBalance,
    if (loyaltyPointsAsOfDate != null)
      'loyalty_points_as_of_date': loyaltyPointsAsOfDate!.toIso8601String(),
    'loyalty_points_balance': loyaltyPointsBalance,
    'additional_field_1': additionalField1,
    'additional_field_2': additionalField2,
    'default_price_tier': defaultPriceTier,
    'additional_phones': additionalPhones,
  };
}

String _initialLoyaltyBalance(String openingBalance) {
  final opening = double.tryParse(openingBalance) ?? 0;
  return opening > 0 ? openingBalance : '';
}

class PartyCache {
  PartyCache(this._storage);

  final StorageService _storage;

  String _partiesKey(String businessId) =>
      '${StorageKeys.cachedParties}_$businessId';

  String _extensionsKey(String businessId) =>
      '${StorageKeys.partyLocalExtensions}_$businessId';

  String _pendingKey(String businessId) =>
      '${StorageKeys.pendingPartyOperations}_$businessId';

  String _filterKey(String businessId) =>
      '${StorageKeys.partyListFilter}_$businessId';

  String _selectedKey(String businessId) =>
      '${StorageKeys.selectedPartyId}_$businessId';

  String _groupNamesKey(String businessId) =>
      '${StorageKeys.partyGroupNames}_$businessId';

  Future<void> saveParties(
    String businessId,
    List<Map<String, dynamic>> parties,
  ) async {
    await _storage.write(_partiesKey(businessId), jsonEncode(parties));
  }

  Future<void> upsertParty(
    String businessId,
    Map<String, dynamic> party,
  ) async {
    final parties = await readParties(businessId);
    final index = parties.indexWhere((item) => item['id'] == party['id']);
    if (index == -1) {
      parties.add(party);
    } else {
      parties[index] = party;
    }
    await saveParties(businessId, parties);
  }

  Future<void> removeParty(String businessId, String partyId) async {
    final parties = await readParties(businessId);
    parties.removeWhere((item) => item['id'] == partyId);
    await saveParties(businessId, parties);
  }

  Future<List<Map<String, dynamic>>> readParties(String businessId) async {
    final raw = _storage.read(_partiesKey(businessId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.cast<Map<String, dynamic>>();
    } on Object catch (_) {
      return [];
    }
  }

  Future<void> saveLocalExtensions(
    String businessId,
    Map<String, Map<String, dynamic>> extensions,
  ) async {
    await _storage.write(_extensionsKey(businessId), jsonEncode(extensions));
  }

  Future<Map<String, PartyLocalExtension>> readLocalExtensions(
    String businessId,
  ) async {
    final raw = _storage.read(_extensionsKey(businessId));
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(
          key as String,
          PartyLocalExtension.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        ),
      );
    } on Object catch (_) {
      return {};
    }
  }

  Future<void> upsertLocalExtension(
    String businessId,
    String partyId,
    PartyLocalExtension extension,
  ) async {
    final current = await readLocalExtensions(businessId);
    current[partyId] = extension;
    await saveLocalExtensions(
      businessId,
      current.map((key, value) => MapEntry(key, value.toJson())),
    );
  }

  Future<void> removeLocalExtension(String businessId, String partyId) async {
    final current = await readLocalExtensions(businessId);
    current.remove(partyId);
    await saveLocalExtensions(
      businessId,
      current.map((key, value) => MapEntry(key, value.toJson())),
    );
  }

  String? readBusinessId() => _storage.read(StorageKeys.lastOpenedBusinessId);

  Future<void> saveSelectedPartyId(String businessId, String? partyId) async {
    await _storage.write(_selectedKey(businessId), partyId ?? '');
  }

  String? readSelectedPartyId(String businessId) {
    final value = _storage.read(_selectedKey(businessId));
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> saveListFilter(String businessId, String filter) async {
    await _storage.write(_filterKey(businessId), filter);
  }

  String? readListFilter(String businessId) =>
      _storage.read(_filterKey(businessId));

  Future<void> queuePendingOperation(
    String businessId,
    Map<String, dynamic> operation,
  ) async {
    final pending = await readPendingOperations(businessId);
    pending.add(operation);
    await _storage.write(_pendingKey(businessId), jsonEncode(pending));
  }

  Future<List<Map<String, dynamic>>> readPendingOperations(
    String businessId,
  ) async {
    final raw = _storage.read(_pendingKey(businessId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.cast<Map<String, dynamic>>();
    } on Object catch (_) {
      return [];
    }
  }

  Future<void> clearPendingOperations(String businessId) async {
    await _storage.write(_pendingKey(businessId), '[]');
  }

  Future<void> savePartyGroupNames(
    String businessId,
    List<String> names,
  ) async {
    await _storage.write(_groupNamesKey(businessId), jsonEncode(names));
  }

  List<String> readPartyGroupNames(String businessId) {
    final raw = _storage.read(_groupNamesKey(businessId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return mergePartyGroupNames(
        decoded.map((item) => item.toString()),
      );
    } on Object catch (_) {
      return [];
    }
  }
}
