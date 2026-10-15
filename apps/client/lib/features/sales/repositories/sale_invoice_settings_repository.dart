import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';

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
      'manualInvoiceNumberEnabled': settings.manualInvoiceNumberEnabled,
      'cashSaleByDefault': settings.cashSaleByDefault,
      'billingNameOfParties': settings.billingNameOfParties,
      'poDetailsForCustomer': settings.poDetailsForCustomer,
      'addTimeOnTransactions': settings.addTimeOnTransactions,
      'printTimeOnInvoices': settings.printTimeOnInvoices,
      'allowInclusiveExclusiveTax': settings.allowInclusiveExclusiveTax,
      'displayPurchasePrice': settings.displayPurchasePrice,
      'showLast5SalePrice': settings.showLast5SalePrice,
      'showLast5PurchasePrice': settings.showLast5PurchasePrice,
      'freeItemQuantity': settings.freeItemQuantity,
      'countColumnEnabled': settings.countColumnEnabled,
      'countColumnLabel': settings.countColumnLabel,
      'itemsTableCount': settings.itemsTableCount,
      'barcodeScanningForItems': settings.barcodeScanningForItems,
      'transactionWiseTax': settings.transactionWiseTax,
      'transactionWiseDiscount': settings.transactionWiseDiscount,
      'roundOffTransactionAmount': settings.roundOffTransactionAmount,
      'roundOffToValue': settings.roundOffToValue,
      'quickEntry': settings.quickEntry,
      'repeatInvoices': settings.repeatInvoices,
      'wholesalePriceToggleOnInvoice': settings.wholesalePriceToggleOnInvoice,
      'billingFormMode': settings.billingFormMode.name,
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
      'formExtras': settings.formExtras.toJson(),
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
      manualInvoiceNumberEnabled:
          json['manualInvoiceNumberEnabled'] as bool? ??
          defaults.manualInvoiceNumberEnabled,
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
      printTimeOnInvoices:
          json['printTimeOnInvoices'] as bool? ?? defaults.printTimeOnInvoices,
      allowInclusiveExclusiveTax:
          json['allowInclusiveExclusiveTax'] as bool? ??
          defaults.allowInclusiveExclusiveTax,
      displayPurchasePrice:
          json['displayPurchasePrice'] as bool? ??
          defaults.displayPurchasePrice,
      showLast5SalePrice:
          json['showLast5SalePrice'] as bool? ?? defaults.showLast5SalePrice,
      showLast5PurchasePrice:
          json['showLast5PurchasePrice'] as bool? ??
          defaults.showLast5PurchasePrice,
      freeItemQuantity:
          json['freeItemQuantity'] as bool? ?? defaults.freeItemQuantity,
      countColumnEnabled:
          json['countColumnEnabled'] as bool? ?? defaults.countColumnEnabled,
      countColumnLabel:
          json['countColumnLabel'] as String? ?? defaults.countColumnLabel,
      itemsTableCount:
          (json['itemsTableCount'] as num?)?.toInt() ??
          defaults.itemsTableCount,
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
      roundOffToValue:
          (json['roundOffToValue'] as num?)?.toInt() ??
          defaults.roundOffToValue,
      quickEntry: json['quickEntry'] as bool? ?? defaults.quickEntry,
      repeatInvoices:
          json['repeatInvoices'] as bool? ?? defaults.repeatInvoices,
      wholesalePriceToggleOnInvoice:
          json['wholesalePriceToggleOnInvoice'] as bool? ??
          defaults.wholesalePriceToggleOnInvoice,
      billingFormMode: SaleBillingFormMode.fromStorage(
        json['billingFormMode'] as String?,
      ),
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
      reverseCharge: json['reverseCharge'] as bool? ?? defaults.reverseCharge,
      stateOfSupply: json['stateOfSupply'] as String? ?? defaults.stateOfSupply,
      eWayBillNumberEnabled:
          json['eWayBillNumberEnabled'] as bool? ??
          defaults.eWayBillNumberEnabled,
      salePrefixEnabled:
          json['salePrefixEnabled'] as bool? ?? defaults.salePrefixEnabled,
      selectedFirmId:
          json['selectedFirmId'] as String? ??
          firmId ??
          defaults.selectedFirmId,
      transactionPrefixes: prefixes,
      formExtras: TransactionFormExtras.fromJson(
        json['formExtras'] is Map
            ? Map<String, dynamic>.from(json['formExtras'] as Map)
            : null,
      ),
    );
  }
}
