import 'package:billing_baba/features/sales/models/sale_fa_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';

bool isBillLevelTaxActive(String taxOption) => taxOption != 'NONE';

double billTaxPercentFromOption(String taxOption) =>
    saleTaxSlabs[taxOption] ?? 0;

double resolveSaleTotalTax({
  required String taxOption,
  required double subtotal,
  required Iterable<SaleLineItem> items,
}) {
  final billPercent = billTaxPercentFromOption(taxOption);
  if (billPercent > 0) {
    return subtotal * billPercent / 100;
  }
  return items.fold<double>(0, (sum, item) => sum + item.lineTax);
}

double resolveSaleRawGrandTotal({
  required String taxOption,
  required double subtotal,
  required Iterable<SaleLineItem> items,
}) {
  final billPercent = billTaxPercentFromOption(taxOption);
  if (billPercent > 0) {
    return subtotal + subtotal * billPercent / 100;
  }
  return items.fold<double>(0, (sum, item) => sum + item.amount);
}

List<SaleLineItem> applyBillTaxOptionToSaleItems(
  List<SaleLineItem> items,
  String taxOption,
) {
  if (!isBillLevelTaxActive(taxOption)) return items;
  return [for (final item in items) item.copyWith(taxPercent: 0)];
}

double effectiveSaleLineTaxPercent({
  required String taxOption,
  required double lineTaxPercent,
}) {
  final billPercent = billTaxPercentFromOption(taxOption);
  return billPercent > 0 ? billPercent : lineTaxPercent;
}

double resolveSaleFaTotalTax({
  required String taxOption,
  required double subtotal,
  required Iterable<SaleFixedAssetLineItem> items,
}) {
  final billPercent = billTaxPercentFromOption(taxOption);
  if (billPercent > 0) {
    return subtotal * billPercent / 100;
  }
  return items.fold<double>(0, (sum, item) => sum + item.lineTax);
}

double resolveSaleFaRawGrandTotal({
  required String taxOption,
  required double subtotal,
  required Iterable<SaleFixedAssetLineItem> items,
}) {
  final billPercent = billTaxPercentFromOption(taxOption);
  if (billPercent > 0) {
    return subtotal + subtotal * billPercent / 100;
  }
  return items.fold<double>(0, (sum, item) => sum + item.amount);
}

List<SaleFixedAssetLineItem> applyBillTaxOptionToSaleFaItems(
  List<SaleFixedAssetLineItem> items,
  String taxOption,
) {
  if (!isBillLevelTaxActive(taxOption)) return items;
  return [for (final item in items) item.copyWith(taxPercent: 0)];
}

double effectiveSaleFaLineTaxPercent({
  required String taxOption,
  required double lineTaxPercent,
}) {
  final billPercent = billTaxPercentFromOption(taxOption);
  return billPercent > 0 ? billPercent : lineTaxPercent;
}
