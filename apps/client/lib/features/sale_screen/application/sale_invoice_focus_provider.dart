import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Item id whose quantity field should be focused on the sale invoice panel.
final saleInvoiceQuantityFocusItemIdProvider =
    NotifierProvider<SaleInvoiceQuantityFocus, String?>(
      SaleInvoiceQuantityFocus.new,
    );

class SaleInvoiceQuantityFocus extends Notifier<String?> {
  @override
  String? build() => null;

  void request(String itemId) => state = itemId;

  void clear() => state = null;
}

void requestSaleInvoiceQuantityFocus(WidgetRef ref, String itemId) {
  ref.read(saleInvoiceQuantityFocusItemIdProvider.notifier).request(itemId);
}
