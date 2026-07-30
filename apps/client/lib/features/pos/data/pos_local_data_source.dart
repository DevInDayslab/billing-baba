import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class PosLocalDataSource {
  PosLocalDataSource(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<void> saveSale({
    required String businessId,
    required SalesDocumentDto dto,
    required List<CartItem> items,
    required List<SalesDocumentLineDto> lineDtos,
    required List<PaymentEntry> payments,
  }) {
    return _db.transaction(() async {
      final createdAt = DateTime.tryParse(dto.createdAt) ?? DateTime.now();
      final totalAmount = double.tryParse(dto.subtotal) ?? 0;
      final taxAmount = double.tryParse(dto.taxAmount) ?? 0;
      final finalAmount = double.tryParse(dto.totalAmount) ?? 0;

      await _db
          .into(_db.salesLocal)
          .insertOnConflictUpdate(
            SalesLocalCompanion(
              id: Value(dto.id),
              businessId: Value(businessId),
              docNumber: Value(dto.documentNumber ?? dto.id),
              partyId: Value(dto.partyId),
              totalAmount: Value(totalAmount),
              taxAmount: Value(taxAmount),
              finalAmount: Value(finalAmount),
              createdAt: Value(createdAt),
              paymentMethod: Value(
                payments.map((p) => _paymentModeToApi(p.mode)).join(','),
              ),
              apiResponseJson: Value(jsonEncode(_documentToJson(dto))),
            ),
          );

      await (_db.delete(_db.salesLineLocal)..where(
            (line) =>
                line.saleId.equals(dto.id) & line.businessId.equals(businessId),
          ))
          .go();

      for (var i = 0; i < items.length; i++) {
        final cartItem = items[i];
        final lineDto = i < lineDtos.length ? lineDtos[i] : null;
        await _db
            .into(_db.salesLineLocal)
            .insert(
              SalesLineLocalCompanion(
                id: Value(lineDto?.id ?? _uuid.v4()),
                businessId: Value(businessId),
                saleId: Value(dto.id),
                itemId: Value(cartItem.item.id),
                itemName: Value(cartItem.item.name),
                quantity: Value(cartItem.quantity),
                rate: Value(cartItem.item.price),
                lineTotal: Value(
                  lineDto != null
                      ? (double.tryParse(lineDto.lineTotal) ??
                            cartItem.lineTotal)
                      : cartItem.lineTotal,
                ),
                cgstAmount: Value(
                  double.tryParse(lineDto?.cgstAmount ?? '0') ?? 0,
                ),
                sgstAmount: Value(
                  double.tryParse(lineDto?.sgstAmount ?? '0') ?? 0,
                ),
                igstAmount: Value(
                  double.tryParse(lineDto?.igstAmount ?? '0') ?? 0,
                ),
              ),
            );
      }
    });
  }

  Future<(SaleLocal, List<SaleLineLocal>)?> getSaleWithLines(
    String businessId,
    String saleId,
  ) async {
    final sale =
        await (_db.select(_db.salesLocal)..where(
              (row) =>
                  row.id.equals(saleId) & row.businessId.equals(businessId),
            ))
            .getSingleOrNull();
    if (sale == null) return null;

    final lines =
        await (_db.select(_db.salesLineLocal)..where(
              (row) =>
                  row.saleId.equals(saleId) &
                  row.businessId.equals(businessId),
            ))
            .get();
    return (sale, lines);
  }

  Future<List<SaleLocal>> getAllSales(String businessId) {
    return (_db.select(_db.salesLocal)
          ..where((row) => row.businessId.equals(businessId))
          ..orderBy([
            (row) => OrderingTerm.desc(row.createdAt),
          ]))
        .get();
  }

  Future<Map<String, List<SaleLineLocal>>> getLinesBySaleIds(
    String businessId,
    Iterable<String> saleIds,
  ) async {
    final ids = saleIds.toList();
    if (ids.isEmpty) return const {};

    final rows = await (_db.select(_db.salesLineLocal)
          ..where(
            (row) =>
                row.businessId.equals(businessId) & row.saleId.isIn(ids),
          ))
        .get();

    final grouped = <String, List<SaleLineLocal>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.saleId, () => []).add(row);
    }
    return grouped;
  }

  Future<void> saveHeldBill(String businessId, HeldBill bill) async {
    await _db
        .into(_db.heldBillsLocal)
        .insertOnConflictUpdate(
          HeldBillsLocalCompanion(
            id: Value(bill.id),
            businessId: Value(businessId),
            itemsJson: Value(jsonEncode(_cartItemsToJson(bill.items))),
            paymentsJson: Value(jsonEncode(_paymentsToJson(bill.payments))),
            customerName: Value(bill.customerName),
            notes: Value(bill.notes),
            heldAt: Value(bill.heldAt),
          ),
        );
  }

  Future<List<HeldBill>> getHeldBills(String businessId) async {
    final rows =
        await (_db.select(_db.heldBillsLocal)
              ..where((row) => row.businessId.equals(businessId))
              ..orderBy([
                (row) => OrderingTerm.desc(row.heldAt),
              ]))
            .get();
    return rows.map(_heldBillFromRow).toList();
  }

  Future<void> deleteHeldBill(String businessId, String id) async {
    await (_db.delete(_db.heldBillsLocal)..where(
          (row) => row.id.equals(id) & row.businessId.equals(businessId),
        ))
        .go();
  }

  HeldBill _heldBillFromRow(HeldBillsLocalData row) {
    final itemsJson = jsonDecode(row.itemsJson) as List<dynamic>;
    final paymentsJson = jsonDecode(row.paymentsJson) as List<dynamic>;
    return HeldBill(
      id: row.id,
      items: itemsJson
          .map((e) => _cartItemFromJson(e as Map<String, dynamic>))
          .toList(),
      heldAt: row.heldAt,
      payments: paymentsJson
          .map((e) => _paymentFromJson(e as Map<String, dynamic>))
          .toList(),
      customerName: row.customerName,
      notes: row.notes,
    );
  }

  List<Map<String, dynamic>> _cartItemsToJson(List<CartItem> items) {
    return items.map(_cartItemToJson).toList();
  }

  Map<String, dynamic> _cartItemToJson(CartItem item) => {
    'item': {
      'id': item.item.id,
      'name': item.item.name,
      'sku': item.item.sku,
      'categoryId': item.item.categoryId,
      'categoryName': item.item.categoryName,
      'price': item.item.price,
      'mrp': item.item.mrp,
      'stock': item.item.stock,
      'unit': item.item.unit,
      'imageUrl': item.item.imageUrl,
      'hsnCode': item.item.hsnCode,
    },
    'quantity': item.quantity,
    'discountPercent': item.discountPercent,
  };

  CartItem _cartItemFromJson(Map<String, dynamic> json) {
    final itemJson = json['item'] as Map<String, dynamic>;
    return CartItem(
      item: PosItem(
        id: itemJson['id'] as String,
        name: itemJson['name'] as String,
        sku: itemJson['sku'] as String,
        categoryId: itemJson['categoryId'] as String? ??
            itemJson['category'] as String?,
        categoryName: itemJson['categoryName'] as String? ??
            itemJson['category'] as String? ??
            'Uncategorized',
        price: (itemJson['price'] as num).toDouble(),
        mrp: (itemJson['mrp'] as num?)?.toDouble(),
        stock: itemJson['stock'] as int,
        unit: itemJson['unit'] as String? ?? 'pcs',
        imageUrl: itemJson['imageUrl'] as String?,
        hsnCode: itemJson['hsnCode'] as String?,
      ),
      quantity: json['quantity'] as int,
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
    );
  }

  List<Map<String, dynamic>> _paymentsToJson(List<PaymentEntry> payments) {
    return payments.map(_paymentToJson).toList();
  }

  Map<String, dynamic> _paymentToJson(PaymentEntry payment) => {
    'mode': payment.mode.name,
    'amount': payment.amount,
  };

  PaymentEntry _paymentFromJson(Map<String, dynamic> json) {
    final modeName = json['mode'] as String;
    final mode = PaymentMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => PaymentMode.cash,
    );
    return PaymentEntry(
      mode: mode,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> _documentToJson(SalesDocumentDto dto) {
    return {
      'id': dto.id,
      'document_type': dto.documentType,
      'status': dto.status,
      'document_number': dto.documentNumber,
      'document_series': dto.documentSeries,
      'party_id': dto.partyId,
      'subtotal': dto.subtotal,
      'discount_total': dto.discountTotal,
      'tax_amount': dto.taxAmount,
      'total_amount': dto.totalAmount,
      'paid_amount': dto.paidAmount,
      'payment_mode': dto.paymentMode,
      'document_date': dto.documentDate,
      'pos_session_id': dto.posSessionId,
      'notes': dto.notes,
      'created_at': dto.createdAt,
      'updated_at': dto.updatedAt,
    };
  }

  String _paymentModeToApi(PaymentMode mode) => switch (mode) {
    PaymentMode.cash => 'cash',
    PaymentMode.upi => 'upi',
    PaymentMode.card => 'card',
    PaymentMode.bank => 'bank_transfer',
  };
}
