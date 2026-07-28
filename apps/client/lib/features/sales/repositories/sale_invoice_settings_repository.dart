import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';

class SaleInvoiceSettingsRepository {
  SaleInvoiceSettingsRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _key => '${StorageKeys.saleInvoiceSettings}_$_businessId.json';

  Future<SaleInvoiceSettings> load({String? firmId}) async {
    final raw = _storage.read(_key);
    if (raw == null || raw.isEmpty) {
      return SaleInvoiceSettings.defaults(firmId: firmId);
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(json, firmId: firmId);
    } on Object {
      return SaleInvoiceSettings.defaults(firmId: firmId);
    }
  }

  Future<void> save(SaleInvoiceSettings settings) async {
    await _storage.write(_key, jsonEncode(_toJson(settings)));
  }

  Map<String, dynamic> _toJson(SaleInvoiceSettings settings) {
    return {
      'invoiceBillNumberEnabled': settings.invoiceBillNumberEnabled,
      'cashSaleByDefault': settings.cashSaleByDefault,
      'billingNameOfParties': settings.billingNameOfParties,
      'poDetailsForCustomer': settings.poDetailsForCustomer,
      'addTimeOnTransactions': settings.addTimeOnTransactions,
      'allowInclusiveExclusiveTax': settings.allowInclusiveExclusiveTax,
      'displayPurchasePrice': settings.displayPurchasePrice,
      'showLast5SalePrice': settings.showLast5SalePrice,
      'freeItemQuantity': settings.freeItemQuantity,
      'itemsTableCount': settings.itemsTableCount,
      'barcodeScanningForItems': settings.barcodeScanningForItems,
      'transactionWiseTax': settings.transactionWiseTax,
      'transactionWiseDiscount': settings.transactionWiseDiscount,
      'roundOffTransactionAmount': settings.roundOffTransactionAmount,
      'shareTransactionAs': settings.shareTransactionAs.name,
      'passcodeForEditDeleteEnabled': settings.passcodeForEditDeleteEnabled,
      'passcode': settings.passcode,
      'discountDuringPayment': settings.discountDuringPayment,
      'linkPaymentsToInvoices': settings.linkPaymentsToInvoices,
      'dueDatesAndPaymentTerms': settings.dueDatesAndPaymentTerms,
      'enableInvoicePreview': settings.enableInvoicePreview,
      'termsAndConditionsEnabled': settings.termsAndConditionsEnabled,
      'termsAndConditionsText': settings.termsAndConditionsText,
      'additionalFieldsEnabled': settings.additionalFieldsEnabled,
      'transportationDetailsEnabled': settings.transportationDetailsEnabled,
      'additionalChargesEnabled': settings.additionalChargesEnabled,
      'showProfitOnSaleInvoice': settings.showProfitOnSaleInvoice,
      'reverseCharge': settings.reverseCharge,
      'stateOfSupply': settings.stateOfSupply,
      'eWayBillNumberEnabled': settings.eWayBillNumberEnabled,
      'salePrefixEnabled': settings.salePrefixEnabled,
      'selectedFirmId': settings.selectedFirmId,
      'transactionPrefixes': {
        for (final entry in settings.transactionPrefixes.entries)
          entry.key.name: entry.value,
      },
    };
  }

  SaleInvoiceSettings _fromJson(
    Map<String, dynamic> json, {
    String? firmId,
  }) {
    final defaults = SaleInvoiceSettings.defaults(firmId: firmId);
    final prefixesRaw = json['transactionPrefixes'] as Map<String, dynamic>?;
    final prefixes = Map<SaleTransactionPrefixType, String>.from(
      defaults.transactionPrefixes,
    );
    if (prefixesRaw != null) {
      for (final type in SaleTransactionPrefixType.values) {
        final value = prefixesRaw[type.name] as String?;
        if (value != null && value.trim().isNotEmpty) {
          prefixes[type] = value.trim();
        }
      }
    }

    return SaleInvoiceSettings(
      invoiceBillNumberEnabled:
          json['invoiceBillNumberEnabled'] as bool? ??
          defaults.invoiceBillNumberEnabled,
      cashSaleByDefault:
          json['cashSaleByDefault'] as bool? ?? defaults.cashSaleByDefault,
      billingNameOfParties:
          json['billingNameOfParties'] as bool? ??
          defaults.billingNameOfParties,
      poDetailsForCustomer:
          json['poDetailsForCustomer'] as bool? ??
          defaults.poDetailsForCustomer,
      addTimeOnTransactions:
          json['addTimeOnTransactions'] as bool? ??
          defaults.addTimeOnTransactions,
      allowInclusiveExclusiveTax:
          json['allowInclusiveExclusiveTax'] as bool? ??
          defaults.allowInclusiveExclusiveTax,
      displayPurchasePrice:
          json['displayPurchasePrice'] as bool? ??
          defaults.displayPurchasePrice,
      showLast5SalePrice:
          json['showLast5SalePrice'] as bool? ?? defaults.showLast5SalePrice,
      freeItemQuantity:
          json['freeItemQuantity'] as bool? ?? defaults.freeItemQuantity,
      itemsTableCount:
          (json['itemsTableCount'] as num?)?.toInt() ?? defaults.itemsTableCount,
      barcodeScanningForItems:
          json['barcodeScanningForItems'] as bool? ??
          defaults.barcodeScanningForItems,
      transactionWiseTax:
          json['transactionWiseTax'] as bool? ?? defaults.transactionWiseTax,
      transactionWiseDiscount:
          json['transactionWiseDiscount'] as bool? ??
          defaults.transactionWiseDiscount,
      roundOffTransactionAmount:
          json['roundOffTransactionAmount'] as bool? ??
          defaults.roundOffTransactionAmount,
      shareTransactionAs: SaleInvoiceShareFormat.fromStorage(
        json['shareTransactionAs'] as String?,
      ),
      passcodeForEditDeleteEnabled:
          json['passcodeForEditDeleteEnabled'] as bool? ??
          defaults.passcodeForEditDeleteEnabled,
      passcode: json['passcode'] as String? ?? defaults.passcode,
      discountDuringPayment:
          json['discountDuringPayment'] as bool? ??
          defaults.discountDuringPayment,
      linkPaymentsToInvoices:
          json['linkPaymentsToInvoices'] as bool? ??
          defaults.linkPaymentsToInvoices,
      dueDatesAndPaymentTerms:
          json['dueDatesAndPaymentTerms'] as bool? ??
          defaults.dueDatesAndPaymentTerms,
      enableInvoicePreview:
          json['enableInvoicePreview'] as bool? ??
          defaults.enableInvoicePreview,
      termsAndConditionsEnabled:
          json['termsAndConditionsEnabled'] as bool? ??
          defaults.termsAndConditionsEnabled,
      termsAndConditionsText:
          json['termsAndConditionsText'] as String? ??
          defaults.termsAndConditionsText,
      additionalFieldsEnabled:
          json['additionalFieldsEnabled'] as bool? ??
          defaults.additionalFieldsEnabled,
      transportationDetailsEnabled:
          json['transportationDetailsEnabled'] as bool? ??
          defaults.transportationDetailsEnabled,
      additionalChargesEnabled:
          json['additionalChargesEnabled'] as bool? ??
          defaults.additionalChargesEnabled,
      showProfitOnSaleInvoice:
          json['showProfitOnSaleInvoice'] as bool? ??
          defaults.showProfitOnSaleInvoice,
      reverseCharge:
          json['reverseCharge'] as bool? ?? defaults.reverseCharge,
      stateOfSupply:
          json['stateOfSupply'] as String? ?? defaults.stateOfSupply,
      eWayBillNumberEnabled:
          json['eWayBillNumberEnabled'] as bool? ??
          defaults.eWayBillNumberEnabled,
      salePrefixEnabled:
          json['salePrefixEnabled'] as bool? ?? defaults.salePrefixEnabled,
      selectedFirmId:
          json['selectedFirmId'] as String? ?? firmId ?? defaults.selectedFirmId,
      transactionPrefixes: prefixes,
    );
  }
}
