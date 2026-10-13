import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings → Transaction (more features) mapped to sale invoice UI behavior.
class SaleTransactionFeatures {
  const SaleTransactionFeatures({
    this.showEWayBillNumber = false,
    this.quickEntry = false,
    this.showInvoicePreviewOnSave = true,
    this.repeatInvoices = false,
    this.discountDuringPayment = false,
    this.linkPaymentsToInvoices = false,
    this.dueDatesAndPaymentTerms = false,
    this.showProfitOnSaleInvoice = false,
    this.wholesalePriceToggleOnInvoice = false,
    this.termsAndConditionsEnabled = false,
  });

  factory SaleTransactionFeatures.fromSettings(SaleInvoiceSettings settings) {
    return SaleTransactionFeatures(
      showEWayBillNumber: settings.eWayBillNumberEnabled,
      quickEntry: settings.quickEntry,
      showInvoicePreviewOnSave: settings.enableInvoicePreview,
      repeatInvoices: settings.repeatInvoices,
      discountDuringPayment: settings.discountDuringPayment,
      linkPaymentsToInvoices: settings.linkPaymentsToInvoices,
      dueDatesAndPaymentTerms: settings.dueDatesAndPaymentTerms,
      showProfitOnSaleInvoice: settings.showProfitOnSaleInvoice,
      wholesalePriceToggleOnInvoice: settings.wholesalePriceToggleOnInvoice,
      termsAndConditionsEnabled: settings.termsAndConditionsEnabled,
    );
  }

  final bool showEWayBillNumber;
  final bool quickEntry;
  final bool showInvoicePreviewOnSave;
  final bool repeatInvoices;
  final bool discountDuringPayment;
  final bool linkPaymentsToInvoices;
  final bool dueDatesAndPaymentTerms;
  final bool showProfitOnSaleInvoice;
  final bool wholesalePriceToggleOnInvoice;
  final bool termsAndConditionsEnabled;
}

/// Sale transactions list columns driven by payment / due-date settings.
class SaleInvoiceTableColumnFlags {
  const SaleInvoiceTableColumnFlags({
    this.showBalance = false,
    this.showDueDate = false,
    this.showStatus = false,
  });

  factory SaleInvoiceTableColumnFlags.fromFeatures(
    SaleTransactionFeatures features,
  ) {
    return SaleInvoiceTableColumnFlags(
      showBalance: features.linkPaymentsToInvoices,
      showDueDate: features.dueDatesAndPaymentTerms,
      showStatus: features.linkPaymentsToInvoices,
    );
  }

  final bool showBalance;
  final bool showDueDate;
  final bool showStatus;
}

final saleTransactionFeaturesProvider = Provider<SaleTransactionFeatures>((
  ref,
) {
  final settings = ref.watch(saleInvoiceSettingsProvider);
  return settings.when(
    data: SaleTransactionFeatures.fromSettings,
    loading: () => const SaleTransactionFeatures(),
    error: (_, _) => const SaleTransactionFeatures(),
  );
});

final saleConfiguredPaymentTermsProvider = Provider<List<PaymentTermSetting>>((
  ref,
) {
  final settings = ref.watch(saleInvoiceSettingsProvider);
  return settings.when(
    data: (s) => s.formExtras.paymentTerms,
    loading: () => TransactionFormExtras.defaults().paymentTerms,
    error: (_, _) => TransactionFormExtras.defaults().paymentTerms,
  );
});

final salePaymentTermNameOptionsProvider = Provider<List<String>>((ref) {
  return ref
      .watch(saleConfiguredPaymentTermsProvider)
      .map((t) => t.name)
      .where((name) => name.trim().isNotEmpty)
      .toList();
});

/// Repeat invoice frequency options (Settings → Repeat Invoices).
const saleRepeatInvoiceFrequencies = <String>[
  'Daily',
  'Weekly',
  'Monthly',
  'Quarterly',
  'Yearly',
];
