import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which sale form header fields are shown (Settings → Transaction Header).
class SaleTransactionHeaderVisibility {
  const SaleTransactionHeaderVisibility({
    this.showInvoiceBillNumber = true,
    this.showTransactionTime = false,
    this.showBillingNameOnInvoice = false,
    this.showCustomerPoDetails = false,
    this.cashSaleByDefault = true,
  });

  factory SaleTransactionHeaderVisibility.fromSettings(
    SaleInvoiceSettings settings,
  ) {
    return SaleTransactionHeaderVisibility(
      showInvoiceBillNumber: settings.invoiceBillNumberEnabled,
      showTransactionTime: settings.addTimeOnTransactions,
      showBillingNameOnInvoice: settings.billingNameOfParties,
      showCustomerPoDetails: settings.poDetailsForCustomer,
      cashSaleByDefault: settings.cashSaleByDefault,
    );
  }

  final bool showInvoiceBillNumber;
  final bool showTransactionTime;
  final bool showBillingNameOnInvoice;
  final bool showCustomerPoDetails;
  final bool cashSaleByDefault;
}

final saleTransactionHeaderVisibilityProvider =
    Provider<SaleTransactionHeaderVisibility>((ref) {
      final settings = ref.watch(saleInvoiceSettingsProvider);
      return settings.when(
        data: SaleTransactionHeaderVisibility.fromSettings,
        loading: () => const SaleTransactionHeaderVisibility(),
        error: (_, _) => const SaleTransactionHeaderVisibility(),
      );
    });
