/// How sale transactions are shared from mobile.
enum SaleInvoiceShareFormat {
  image,
  pdf;

  String get label => switch (this) {
    SaleInvoiceShareFormat.image => 'Image',
    SaleInvoiceShareFormat.pdf => 'PDF',
  };

  static SaleInvoiceShareFormat fromStorage(String? value) {
    return SaleInvoiceShareFormat.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SaleInvoiceShareFormat.image,
    );
  }
}

/// Document types that support configurable transaction prefixes.
enum SaleTransactionPrefixType {
  sale,
  saleOrder,
  estimate,
  deliveryChallan,
  proformaInvoice,
  creditNote,
  paymentIn,
  purchase,
  purchaseOrder,
  debitNote,
  paymentOut,
  expense;

  String get label => switch (this) {
    SaleTransactionPrefixType.sale => 'Sale',
    SaleTransactionPrefixType.saleOrder => 'Sale Order',
    SaleTransactionPrefixType.estimate => 'Estimate',
    SaleTransactionPrefixType.deliveryChallan => 'Delivery Challan',
    SaleTransactionPrefixType.proformaInvoice => 'Proforma Invoice',
    SaleTransactionPrefixType.creditNote => 'Credit Note',
    SaleTransactionPrefixType.paymentIn => 'Payment In',
    SaleTransactionPrefixType.purchase => 'Purchase',
    SaleTransactionPrefixType.purchaseOrder => 'Purchase Order',
    SaleTransactionPrefixType.debitNote => 'Debit Note',
    SaleTransactionPrefixType.paymentOut => 'Payment Out',
    SaleTransactionPrefixType.expense => 'Expense',
  };

  String get defaultPrefix => switch (this) {
    SaleTransactionPrefixType.sale => 'INV',
    SaleTransactionPrefixType.saleOrder => 'SO',
    SaleTransactionPrefixType.estimate => 'EST',
    SaleTransactionPrefixType.deliveryChallan => 'DC',
    SaleTransactionPrefixType.proformaInvoice => 'PI',
    SaleTransactionPrefixType.creditNote => 'CN',
    SaleTransactionPrefixType.paymentIn => 'PIN',
    SaleTransactionPrefixType.purchase => 'PUR',
    SaleTransactionPrefixType.purchaseOrder => 'PO',
    SaleTransactionPrefixType.debitNote => 'DN',
    SaleTransactionPrefixType.paymentOut => 'POUT',
    SaleTransactionPrefixType.expense => 'EXP',
  };
}

/// Device-local sale invoice preferences (scoped per business).
class SaleInvoiceSettings {
  const SaleInvoiceSettings({
    required this.invoiceBillNumberEnabled,
    required this.cashSaleByDefault,
    required this.billingNameOfParties,
    required this.poDetailsForCustomer,
    required this.addTimeOnTransactions,
    required this.allowInclusiveExclusiveTax,
    required this.displayPurchasePrice,
    required this.showLast5SalePrice,
    required this.freeItemQuantity,
    required this.itemsTableCount,
    required this.barcodeScanningForItems,
    required this.transactionWiseTax,
    required this.transactionWiseDiscount,
    required this.roundOffTransactionAmount,
    required this.shareTransactionAs,
    required this.passcodeForEditDeleteEnabled,
    required this.passcode,
    required this.discountDuringPayment,
    required this.linkPaymentsToInvoices,
    required this.dueDatesAndPaymentTerms,
    required this.enableInvoicePreview,
    required this.termsAndConditionsEnabled,
    required this.termsAndConditionsText,
    required this.additionalFieldsEnabled,
    required this.transportationDetailsEnabled,
    required this.additionalChargesEnabled,
    required this.showProfitOnSaleInvoice,
    required this.reverseCharge,
    required this.stateOfSupply,
    required this.eWayBillNumberEnabled,
    required this.salePrefixEnabled,
    required this.selectedFirmId,
    required this.transactionPrefixes,
  });

  factory SaleInvoiceSettings.defaults({String? firmId}) {
    return SaleInvoiceSettings(
      invoiceBillNumberEnabled: true,
      cashSaleByDefault: false,
      billingNameOfParties: false,
      poDetailsForCustomer: false,
      addTimeOnTransactions: false,
      allowInclusiveExclusiveTax: true,
      displayPurchasePrice: false,
      showLast5SalePrice: false,
      freeItemQuantity: false,
      itemsTableCount: 1,
      barcodeScanningForItems: true,
      transactionWiseTax: false,
      transactionWiseDiscount: false,
      roundOffTransactionAmount: true,
      shareTransactionAs: SaleInvoiceShareFormat.image,
      passcodeForEditDeleteEnabled: false,
      passcode: '',
      discountDuringPayment: false,
      linkPaymentsToInvoices: true,
      dueDatesAndPaymentTerms: true,
      enableInvoicePreview: true,
      termsAndConditionsEnabled: false,
      termsAndConditionsText: 'Thanks for doing business with us!',
      additionalFieldsEnabled: false,
      transportationDetailsEnabled: false,
      additionalChargesEnabled: false,
      showProfitOnSaleInvoice: false,
      reverseCharge: false,
      stateOfSupply: 'Madhya Pradesh',
      eWayBillNumberEnabled: false,
      salePrefixEnabled: false,
      selectedFirmId: firmId,
      transactionPrefixes: SaleInvoiceSettings.defaultPrefixes(),
    );
  }

  static Map<SaleTransactionPrefixType, String> defaultPrefixes() {
    return {
      for (final type in SaleTransactionPrefixType.values)
        type: type.defaultPrefix,
    };
  }

  final bool invoiceBillNumberEnabled;
  final bool cashSaleByDefault;
  final bool billingNameOfParties;
  final bool poDetailsForCustomer;
  final bool addTimeOnTransactions;
  final bool allowInclusiveExclusiveTax;
  final bool displayPurchasePrice;
  final bool showLast5SalePrice;
  final bool freeItemQuantity;
  final int itemsTableCount;
  final bool barcodeScanningForItems;
  final bool transactionWiseTax;
  final bool transactionWiseDiscount;
  final bool roundOffTransactionAmount;
  final SaleInvoiceShareFormat shareTransactionAs;
  final bool passcodeForEditDeleteEnabled;
  final String passcode;
  final bool discountDuringPayment;
  final bool linkPaymentsToInvoices;
  final bool dueDatesAndPaymentTerms;
  final bool enableInvoicePreview;
  final bool termsAndConditionsEnabled;
  final String termsAndConditionsText;
  final bool additionalFieldsEnabled;
  final bool transportationDetailsEnabled;
  final bool additionalChargesEnabled;
  final bool showProfitOnSaleInvoice;
  final bool reverseCharge;
  final String stateOfSupply;
  final bool eWayBillNumberEnabled;
  final bool salePrefixEnabled;
  final String? selectedFirmId;
  final Map<SaleTransactionPrefixType, String> transactionPrefixes;

  String prefixFor(SaleTransactionPrefixType type) {
    final value = transactionPrefixes[type]?.trim();
    if (value == null || value.isEmpty) return type.defaultPrefix;
    return value;
  }

  SaleInvoiceSettings copyWith({
    bool? invoiceBillNumberEnabled,
    bool? cashSaleByDefault,
    bool? billingNameOfParties,
    bool? poDetailsForCustomer,
    bool? addTimeOnTransactions,
    bool? allowInclusiveExclusiveTax,
    bool? displayPurchasePrice,
    bool? showLast5SalePrice,
    bool? freeItemQuantity,
    int? itemsTableCount,
    bool? barcodeScanningForItems,
    bool? transactionWiseTax,
    bool? transactionWiseDiscount,
    bool? roundOffTransactionAmount,
    SaleInvoiceShareFormat? shareTransactionAs,
    bool? passcodeForEditDeleteEnabled,
    String? passcode,
    bool? discountDuringPayment,
    bool? linkPaymentsToInvoices,
    bool? dueDatesAndPaymentTerms,
    bool? enableInvoicePreview,
    bool? termsAndConditionsEnabled,
    String? termsAndConditionsText,
    bool? additionalFieldsEnabled,
    bool? transportationDetailsEnabled,
    bool? additionalChargesEnabled,
    bool? showProfitOnSaleInvoice,
    bool? reverseCharge,
    String? stateOfSupply,
    bool? eWayBillNumberEnabled,
    bool? salePrefixEnabled,
    String? selectedFirmId,
    Map<SaleTransactionPrefixType, String>? transactionPrefixes,
  }) {
    return SaleInvoiceSettings(
      invoiceBillNumberEnabled:
          invoiceBillNumberEnabled ?? this.invoiceBillNumberEnabled,
      cashSaleByDefault: cashSaleByDefault ?? this.cashSaleByDefault,
      billingNameOfParties: billingNameOfParties ?? this.billingNameOfParties,
      poDetailsForCustomer: poDetailsForCustomer ?? this.poDetailsForCustomer,
      addTimeOnTransactions:
          addTimeOnTransactions ?? this.addTimeOnTransactions,
      allowInclusiveExclusiveTax:
          allowInclusiveExclusiveTax ?? this.allowInclusiveExclusiveTax,
      displayPurchasePrice: displayPurchasePrice ?? this.displayPurchasePrice,
      showLast5SalePrice: showLast5SalePrice ?? this.showLast5SalePrice,
      freeItemQuantity: freeItemQuantity ?? this.freeItemQuantity,
      itemsTableCount: itemsTableCount ?? this.itemsTableCount,
      barcodeScanningForItems:
          barcodeScanningForItems ?? this.barcodeScanningForItems,
      transactionWiseTax: transactionWiseTax ?? this.transactionWiseTax,
      transactionWiseDiscount:
          transactionWiseDiscount ?? this.transactionWiseDiscount,
      roundOffTransactionAmount:
          roundOffTransactionAmount ?? this.roundOffTransactionAmount,
      shareTransactionAs: shareTransactionAs ?? this.shareTransactionAs,
      passcodeForEditDeleteEnabled: passcodeForEditDeleteEnabled ??
          this.passcodeForEditDeleteEnabled,
      passcode: passcode ?? this.passcode,
      discountDuringPayment:
          discountDuringPayment ?? this.discountDuringPayment,
      linkPaymentsToInvoices:
          linkPaymentsToInvoices ?? this.linkPaymentsToInvoices,
      dueDatesAndPaymentTerms:
          dueDatesAndPaymentTerms ?? this.dueDatesAndPaymentTerms,
      enableInvoicePreview:
          enableInvoicePreview ?? this.enableInvoicePreview,
      termsAndConditionsEnabled:
          termsAndConditionsEnabled ?? this.termsAndConditionsEnabled,
      termsAndConditionsText:
          termsAndConditionsText ?? this.termsAndConditionsText,
      additionalFieldsEnabled:
          additionalFieldsEnabled ?? this.additionalFieldsEnabled,
      transportationDetailsEnabled: transportationDetailsEnabled ??
          this.transportationDetailsEnabled,
      additionalChargesEnabled:
          additionalChargesEnabled ?? this.additionalChargesEnabled,
      showProfitOnSaleInvoice:
          showProfitOnSaleInvoice ?? this.showProfitOnSaleInvoice,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      eWayBillNumberEnabled:
          eWayBillNumberEnabled ?? this.eWayBillNumberEnabled,
      salePrefixEnabled: salePrefixEnabled ?? this.salePrefixEnabled,
      selectedFirmId: selectedFirmId ?? this.selectedFirmId,
      transactionPrefixes: transactionPrefixes ?? this.transactionPrefixes,
    );
  }
}
