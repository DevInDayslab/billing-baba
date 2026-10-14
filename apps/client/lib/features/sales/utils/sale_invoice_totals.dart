import 'package:billing_baba/features/sales/application/sale_transaction_totals_settings.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/shared/documents/transaction_round_off.dart';

class SaleInvoiceTotals {
  const SaleInvoiceTotals({
    required this.subtotal,
    required this.transactionDiscountAmount,
    required this.totalTax,
    required this.rawGrandTotal,
    required this.roundOffAmount,
    required this.grandTotal,
  });

  final double subtotal;
  final double transactionDiscountAmount;
  final double totalTax;
  final double rawGrandTotal;
  final double roundOffAmount;
  final double grandTotal;
}

SaleInvoiceTotals computeSaleInvoiceTotals({
  required AddSaleFormState form,
  required SaleTransactionTotalsSettings settings,
}) {
  final subtotal = form.subtotal;
  final transactionDiscountAmount = settings.transactionWiseDiscount
      ? subtotal * form.transactionDiscountPercent / 100
      : 0.0;
  final discountedSubtotal = subtotal - transactionDiscountAmount;

  final totalTax = settings.transactionWiseTax
      ? resolveSaleTotalTax(
          taxOption: form.taxOption,
          subtotal: discountedSubtotal,
          items: form.items,
        )
      : form.items.fold<double>(0, (sum, item) => sum + item.lineTax);

  final rawGrandTotal = settings.transactionWiseTax &&
          isBillLevelTaxActive(form.taxOption)
      ? discountedSubtotal + totalTax
      : form.items.fold<double>(0, (sum, item) => sum + item.amount) -
          transactionDiscountAmount;

  final roundEnabled = settings.roundOffTransactionAmount && form.roundOff;
  final roundOffAmount = transactionRoundOffDelta(
    rawTotal: rawGrandTotal,
    enabled: roundEnabled,
    mode: settings.roundOffMode,
    toValue: settings.roundOffToValue,
  );
  final grandTotal = rawGrandTotal + roundOffAmount;

  return SaleInvoiceTotals(
    subtotal: subtotal,
    transactionDiscountAmount: transactionDiscountAmount,
    totalTax: totalTax,
    rawGrandTotal: rawGrandTotal,
    roundOffAmount: roundOffAmount,
    grandTotal: grandTotal,
  );
}
