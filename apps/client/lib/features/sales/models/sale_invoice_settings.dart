import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';

/// Sale invoice form density on desktop.
enum SaleBillingFormMode {
  liteSale,
  fullSale;

  static SaleBillingFormMode fromStorage(String? value) {
    return SaleBillingFormMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SaleBillingFormMode.fullSale,
    );
  }
}

/// Prefix types shown on Settings → Transaction.
const transactionSettingsPrefixTypes = <SaleTransactionPrefixType>[
  SaleTransactionPrefixType.sale,
  SaleTransactionPrefixType.saleOrder,
  SaleTransactionPrefixType.estimate,
  SaleTransactionPrefixType.deliveryChallan,
  SaleTransactionPrefixType.creditNote,
  SaleTransactionPrefixType.purchaseOrder,
  SaleTransactionPrefixType.proformaInvoice,
  SaleTransactionPrefixType.paymentIn,
];

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
    required this.manualInvoiceNumberEnabled,
    required this.cashSaleByDefault,
    required this.billingNameOfParties,
    required this.poDetailsForCustomer,
    required this.addTimeOnTransactions,
    required this.printTimeOnInvoices,
    required this.allowInclusiveExclusiveTax,
    required this.displayPurchasePrice,
    required this.showLast5SalePrice,
    required this.showLast5PurchasePrice,
    required this.freeItemQuantity,
    required this.countColumnEnabled,
    required this.countColumnLabel,
    required this.itemsTableCount,
    required this.barcodeScanningForItems,
    required this.transactionWiseTax,
    required this.transactionWiseDiscount,
    required this.roundOffTransactionAmount,
    required this.roundOffToValue,
    required this.quickEntry,
    required this.repeatInvoices,
    required this.wholesalePriceToggleOnInvoice,
    required this.billingFormMode,
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
    required this.formExtras,
  });

  factory SaleInvoiceSettings.defaults({String? firmId}) {
    return SaleInvoiceSettings(
      invoiceBillNumberEnabled: true,
      manualInvoiceNumberEnabled: false,
      cashSaleByDefault: false,
      billingNameOfParties: false,
      poDetailsForCustomer: false,
      addTimeOnTransactions: false,
      printTimeOnInvoices: false,
      allowInclusiveExclusiveTax: true,
      displayPurchasePrice: false,
      showLast5SalePrice: false,
      showLast5PurchasePrice: false,
      freeItemQuantity: false,
      countColumnEnabled: false,
      countColumnLabel: 'Count',
      itemsTableCount: 1,
      barcodeScanningForItems: true,
      transactionWiseTax: false,
      transactionWiseDiscount: false,
      roundOffTransactionAmount: true,
      roundOffToValue: 1,
      quickEntry: false,
      repeatInvoices: false,
      wholesalePriceToggleOnInvoice: false,
      billingFormMode: SaleBillingFormMode.fullSale,
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
      formExtras: TransactionFormExtras.defaults(),
    );
  }

  static Map<SaleTransactionPrefixType, String> defaultPrefixes() {
    return {
      for (final type in SaleTransactionPrefixType.values)
        type: type.defaultPrefix,
    };
  }

  final bool invoiceBillNumberEnabled;
  final bool manualInvoiceNumberEnabled;
  final bool cashSaleByDefault;
  final bool billingNameOfParties;
  final bool poDetailsForCustomer;
  final bool addTimeOnTransactions;
  final bool printTimeOnInvoices;
  final bool allowInclusiveExclusiveTax;
  final bool displayPurchasePrice;
  final bool showLast5SalePrice;
  final bool showLast5PurchasePrice;
  final bool freeItemQuantity;
  final bool countColumnEnabled;
  final String countColumnLabel;
  final int itemsTableCount;
  final bool barcodeScanningForItems;
  final bool transactionWiseTax;
  final bool transactionWiseDiscount;
  final bool roundOffTransactionAmount;
  final int roundOffToValue;
  final bool quickEntry;
  final bool repeatInvoices;
  final bool wholesalePriceToggleOnInvoice;
  final SaleBillingFormMode billingFormMode;
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
  final TransactionFormExtras formExtras;

  String prefixFor(SaleTransactionPrefixType type) {
    final value = transactionPrefixes[type]?.trim();
    if (value == null || value.isEmpty) return '';
    return value;
  }

  String prefixDisplayFor(SaleTransactionPrefixType type) {
    final value = transactionPrefixes[type]?.trim() ?? '';
    return value.isEmpty ? 'None' : value;
  }

  SaleInvoiceSettings copyWith({
    bool? invoiceBillNumberEnabled,
    bool? manualInvoiceNumberEnabled,
    bool? cashSaleByDefault,
    bool? billingNameOfParties,
    bool? poDetailsForCustomer,
    bool? addTimeOnTransactions,
    bool? printTimeOnInvoices,
    bool? allowInclusiveExclusiveTax,
    bool? displayPurchasePrice,
    bool? showLast5SalePrice,
    bool? showLast5PurchasePrice,
    bool? freeItemQuantity,
    bool? countColumnEnabled,
    String? countColumnLabel,
    int? itemsTableCount,
    bool? barcodeScanningForItems,
    bool? transactionWiseTax,
    bool? transactionWiseDiscount,
    bool? roundOffTransactionAmount,
    int? roundOffToValue,
    bool? quickEntry,
    bool? repeatInvoices,
    bool? wholesalePriceToggleOnInvoice,
    SaleBillingFormMode? billingFormMode,
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
    TransactionFormExtras? formExtras,
  }) {
    return SaleInvoiceSettings(
      invoiceBillNumberEnabled:
          invoiceBillNumberEnabled ?? this.invoiceBillNumberEnabled,
      manualInvoiceNumberEnabled:
          manualInvoiceNumberEnabled ?? this.manualInvoiceNumberEnabled,
      cashSaleByDefault: cashSaleByDefault ?? this.cashSaleByDefault,
      billingNameOfParties: billingNameOfParties ?? this.billingNameOfParties,
      poDetailsForCustomer: poDetailsForCustomer ?? this.poDetailsForCustomer,
      addTimeOnTransactions:
          addTimeOnTransactions ?? this.addTimeOnTransactions,
      printTimeOnInvoices: printTimeOnInvoices ?? this.printTimeOnInvoices,
      allowInclusiveExclusiveTax:
          allowInclusiveExclusiveTax ?? this.allowInclusiveExclusiveTax,
      displayPurchasePrice: displayPurchasePrice ?? this.displayPurchasePrice,
      showLast5SalePrice: showLast5SalePrice ?? this.showLast5SalePrice,
      showLast5PurchasePrice:
          showLast5PurchasePrice ?? this.showLast5PurchasePrice,
      freeItemQuantity: freeItemQuantity ?? this.freeItemQuantity,
      countColumnEnabled: countColumnEnabled ?? this.countColumnEnabled,
      countColumnLabel: countColumnLabel ?? this.countColumnLabel,
      itemsTableCount: itemsTableCount ?? this.itemsTableCount,
      barcodeScanningForItems:
          barcodeScanningForItems ?? this.barcodeScanningForItems,
      transactionWiseTax: transactionWiseTax ?? this.transactionWiseTax,
      transactionWiseDiscount:
          transactionWiseDiscount ?? this.transactionWiseDiscount,
      roundOffTransactionAmount:
          roundOffTransactionAmount ?? this.roundOffTransactionAmount,
      roundOffToValue: roundOffToValue ?? this.roundOffToValue,
      quickEntry: quickEntry ?? this.quickEntry,
      repeatInvoices: repeatInvoices ?? this.repeatInvoices,
      wholesalePriceToggleOnInvoice:
          wholesalePriceToggleOnInvoice ?? this.wholesalePriceToggleOnInvoice,
      billingFormMode: billingFormMode ?? this.billingFormMode,
      shareTransactionAs: shareTransactionAs ?? this.shareTransactionAs,
      passcodeForEditDeleteEnabled:
          passcodeForEditDeleteEnabled ?? this.passcodeForEditDeleteEnabled,
      passcode: passcode ?? this.passcode,
      discountDuringPayment:
          discountDuringPayment ?? this.discountDuringPayment,
      linkPaymentsToInvoices:
          linkPaymentsToInvoices ?? this.linkPaymentsToInvoices,
      dueDatesAndPaymentTerms:
          dueDatesAndPaymentTerms ?? this.dueDatesAndPaymentTerms,
      enableInvoicePreview: enableInvoicePreview ?? this.enableInvoicePreview,
      termsAndConditionsEnabled:
          termsAndConditionsEnabled ?? this.termsAndConditionsEnabled,
      termsAndConditionsText:
          termsAndConditionsText ?? this.termsAndConditionsText,
      additionalFieldsEnabled:
          additionalFieldsEnabled ?? this.additionalFieldsEnabled,
      transportationDetailsEnabled:
          transportationDetailsEnabled ?? this.transportationDetailsEnabled,
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
      formExtras: formExtras ?? this.formExtras,
    );
  }
}
