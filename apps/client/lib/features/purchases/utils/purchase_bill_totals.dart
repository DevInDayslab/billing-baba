import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/sales/application/sale_transaction_totals_settings.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/shared/documents/transaction_round_off.dart';

class PurchaseBillTotals {
  const PurchaseBillTotals({
    required this.totalTax,
    required this.rawGrandTotal,
    required this.roundOffAmount,
    required this.grandTotal,
  });

  final double totalTax;
  final double rawGrandTotal;
  final double roundOffAmount;
  final double grandTotal;
}

PurchaseBillTotals computePurchaseBillTotals({
  required AddPurchaseFormState form,
  required SaleTransactionTotalsSettings settings,
}) {
  final subtotal = form.subtotal;
  final transactionDiscountAmount = settings.transactionWiseDiscount
      ? subtotal * form.transactionDiscountPercent / 100
      : 0.0;
  final discountedSubtotal = subtotal - transactionDiscountAmount;

  final totalTax = settings.transactionWiseTax
      ? _billTax(taxOption: form.taxOption, subtotal: discountedSubtotal)
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

  return PurchaseBillTotals(
    totalTax: totalTax,
    rawGrandTotal: rawGrandTotal,
    roundOffAmount: roundOffAmount,
    grandTotal: rawGrandTotal + roundOffAmount,
  );
}

double _billTax({required String taxOption, required double subtotal}) {
  final billPercent = billTaxPercentFromOption(taxOption);
  if (billPercent <= 0) return 0;
  return subtotal * billPercent / 100;
}

List<PurchaseLineItem> applyBillTaxOptionToPurchaseItems(
  List<PurchaseLineItem> items,
  String taxOption,
) {
  if (!isBillLevelTaxActive(taxOption)) return items;
  return [for (final item in items) item.copyWith(taxPercent: 0)];
}
