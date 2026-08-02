import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _posTaxOption = '18%';

/// Maps POS cart state into command-sync sales draft input.
SalesDocumentDraftInput mapPosCartToDraftInput({
  required PosCartState cart,
  required String posSessionId,
  String? partyId,
  String? notes,
}) {
  return SalesDocumentDraftInput(
    documentType: SalesDocumentType.pos,
    documentSeries: SalesConstants.posSeries,
    partyId: partyId,
    documentDate: DateTime.now(),
    notes: notes,
    items: mapPosCartItemsToSaleLines(cart.items, cart.billDiscountPercent),
    taxOption: _posTaxOption,
    posSessionId: posSessionId,
  );
}

List<SaleLineItem> mapPosCartItemsToSaleLines(
  List<CartItem> items,
  double billDiscountPercent,
) {
  final taxableBeforeBill = items.fold<double>(
    0,
    (sum, item) => sum + item.lineTotal,
  );
  final billDiscountAmount = taxableBeforeBill * billDiscountPercent / 100;

  return [
    for (final cartItem in items)
      _mapCartItemToSaleLine(
        cartItem,
        billDiscountShare: taxableBeforeBill > 0
            ? cartItem.lineTotal / taxableBeforeBill * billDiscountAmount
            : 0,
      ),
  ];
}

SaleLineItem _mapCartItemToSaleLine(
  CartItem cartItem, {
  required double billDiscountShare,
}) {
  final gross = cartItem.grossTotal;
  final totalDiscount = cartItem.discountAmount + billDiscountShare;
  final discountPercent = gross > 0 ? totalDiscount / gross * 100 : 0.0;

  return SaleLineItem(
    id: _uuid.v4(),
    itemId: cartItem.item.id,
    itemName: cartItem.item.name,
    qty: cartItem.quantity.toDouble(),
    unit: cartItem.item.unit,
    pricePerUnit: cartItem.item.price,
    discountPercent: discountPercent,
    mrp: cartItem.item.mrp ?? 0,
  );
}

FinalizeSalePaymentCommand? mapPosPaymentsToFinalizeCommand({
  required List<PaymentEntry> payments,
  required double totalPayable,
}) {
  if (totalPayable <= 0) return null;

  final resolved = payments.isNotEmpty
      ? payments
      : [PaymentEntry(mode: PaymentMode.cash, amount: totalPayable)];

  final totalPaid = resolved.fold<double>(
    0,
    (sum, entry) => sum + entry.amount,
  );
  final amount = totalPaid > 0 ? totalPaid : totalPayable;
  final primaryMode = resolved.first.mode;

  return FinalizeSalePaymentCommand(
    amount: amount.toStringAsFixed(4),
    paymentMode: _paymentModeToApi(primaryMode),
  );
}

String _paymentModeToApi(PaymentMode mode) => switch (mode) {
  PaymentMode.cash => 'cash',
  PaymentMode.upi => 'upi',
  PaymentMode.card => 'card',
  PaymentMode.bank => 'bank_transfer',
};
