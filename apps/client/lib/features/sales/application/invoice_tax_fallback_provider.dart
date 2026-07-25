import 'dart:async';

import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/application/commerce_settings_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/utils/invoice_tax_preference.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolved GST % for new invoice lines: recent selection, else business default.
final invoiceFallbackTaxPercentProvider = FutureProvider<double?>((ref) async {
  final businessId = ref.watch(currentBusinessProvider)?.id;
  if (businessId == null) return null;

  final commerce = await ref.watch(commerceSettingsProvider.future);
  return InvoiceTaxPreference.resolveFallbackTaxPercent(
    businessId: businessId,
    commerceSettings: commerce,
  );
});

Future<double?> readInvoiceFallbackTaxPercent(Ref ref) async {
  final cached = ref.read(invoiceFallbackTaxPercentProvider).value;
  if (cached != null) return cached;
  return ref.read(invoiceFallbackTaxPercentProvider.future);
}

Future<void> rememberInvoiceLineTax(Ref ref, double taxPercent) async {
  final businessId = ref.read(currentBusinessProvider)?.id;
  if (businessId == null) return;

  await InvoiceTaxPreference.writeRecentRate(businessId, taxPercent);
  if (taxPercent > 0) {
    ref.invalidate(invoiceFallbackTaxPercentProvider);
  }
}

void rememberInvoiceLineTaxIfChanged(
  Ref ref,
  SaleLineItem previous,
  SaleLineItem next,
) {
  if (next.taxPercent > 0 && next.taxPercent != previous.taxPercent) {
    unawaited(rememberInvoiceLineTax(ref, next.taxPercent));
  }
}

Future<SaleLineItem> applyCatalogItemWithInvoiceTaxFallback(
  Ref ref,
  SaleLineItem line,
  SaleItemOption catalogItem, {
  String? partyPriceTier,
  bool resetQtyWhenEmpty = true,
}) async {
  final fallback = await readInvoiceFallbackTaxPercent(ref);
  final applied = applyCatalogItemToLine(
    line,
    catalogItem,
    partyPriceTier: partyPriceTier,
    resetQtyWhenEmpty: resetQtyWhenEmpty,
    fallbackTaxPercent: fallback,
  );
  if (applied.taxPercent > 0) {
    unawaited(rememberInvoiceLineTax(ref, applied.taxPercent));
  }
  return applied;
}
