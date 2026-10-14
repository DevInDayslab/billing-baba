import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings → Transaction: taxes, discounts, round-off, billing type.
class SaleTransactionTotalsSettings {
  const SaleTransactionTotalsSettings({
    this.transactionWiseTax = false,
    this.transactionWiseDiscount = false,
    this.roundOffTransactionAmount = true,
    this.roundOffToValue = 1,
    this.roundOffMode = RoundOffMode.nearest,
    this.billingFormMode = SaleBillingFormMode.fullSale,
  });

  factory SaleTransactionTotalsSettings.from(SaleInvoiceSettings settings) {
    return SaleTransactionTotalsSettings(
      transactionWiseTax: settings.transactionWiseTax,
      transactionWiseDiscount: settings.transactionWiseDiscount,
      roundOffTransactionAmount: settings.roundOffTransactionAmount,
      roundOffToValue: settings.roundOffToValue,
      roundOffMode: settings.formExtras.roundOffMode,
      billingFormMode: settings.billingFormMode,
    );
  }

  final bool transactionWiseTax;
  final bool transactionWiseDiscount;
  final bool roundOffTransactionAmount;
  final int roundOffToValue;
  final RoundOffMode roundOffMode;
  final SaleBillingFormMode billingFormMode;

  bool get isLiteSale => billingFormMode == SaleBillingFormMode.liteSale;
}

final saleTransactionTotalsSettingsProvider =
    Provider<SaleTransactionTotalsSettings>((ref) {
      final settings = ref.watch(saleInvoiceSettingsProvider);
      return settings.when(
        data: SaleTransactionTotalsSettings.from,
        loading: () => const SaleTransactionTotalsSettings(),
        error: (_, _) => const SaleTransactionTotalsSettings(),
      );
    });
