import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/application/sale_line_item_column_visibility_provider.dart';
import 'package:billing_baba/features/sales/application/sale_transaction_totals_settings.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/models/sale_line_item_columns.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings → Transaction → Items Table mapped to Add Sale grid behavior.
class SaleLineItemTableSettings {
  const SaleLineItemTableSettings({
    this.allowInclusiveExclusiveTax = true,
    this.displayPurchasePrice = false,
    this.showLast5SalePrice = false,
    this.freeItemQuantity = false,
    this.countColumnEnabled = false,
    this.countColumnLabel = 'Count',
  });

  factory SaleLineItemTableSettings.from(SaleInvoiceSettings settings) {
    return SaleLineItemTableSettings(
      allowInclusiveExclusiveTax: settings.allowInclusiveExclusiveTax,
      displayPurchasePrice: settings.displayPurchasePrice,
      showLast5SalePrice: settings.showLast5SalePrice,
      freeItemQuantity: settings.freeItemQuantity,
      countColumnEnabled: settings.countColumnEnabled,
      countColumnLabel: settings.countColumnLabel,
    );
  }

  final bool allowInclusiveExclusiveTax;
  final bool displayPurchasePrice;
  final bool showLast5SalePrice;
  final bool freeItemQuantity;
  final bool countColumnEnabled;
  final String countColumnLabel;
}

final saleLineItemTableSettingsProvider = Provider<SaleLineItemTableSettings>((
  ref,
) {
  final settings = ref.watch(saleInvoiceSettingsProvider);
  return settings.when(
    data: SaleLineItemTableSettings.from,
    loading: () => const SaleLineItemTableSettings(),
    error: (_, _) => const SaleLineItemTableSettings(),
  );
});

/// User column prefs merged with Items Table settings (free qty, count).
final effectiveSaleLineItemColumnVisibilityProvider =
    Provider<SaleLineItemColumnVisibility>((ref) {
      final base = ref.watch(saleLineItemColumnVisibilityStateProvider);
      final table = ref.watch(saleLineItemTableSettingsProvider);
      final totals = ref.watch(saleTransactionTotalsSettingsProvider);

      var visible = SaleLineItemColumn.values.where(base.isVisible).toSet();

      if (totals.transactionWiseTax) {
        visible.remove(SaleLineItemColumn.taxPercent);
      }
      if (totals.transactionWiseDiscount) {
        visible.remove(SaleLineItemColumn.discount);
      }
      if (totals.isLiteSale) {
        return const SaleLineItemColumnVisibility({SaleLineItemColumn.price});
      }

      if (table.freeItemQuantity) {
        visible.add(SaleLineItemColumn.freeQty);
      } else {
        visible.remove(SaleLineItemColumn.freeQty);
      }

      if (table.countColumnEnabled) {
        visible.add(SaleLineItemColumn.count);
      } else {
        visible.remove(SaleLineItemColumn.count);
      }

      return SaleLineItemColumnVisibility(visible);
    });
