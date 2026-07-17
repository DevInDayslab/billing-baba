import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/features/pos/data/pos_local_data_source.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_sales_list_provider.g.dart';

@Riverpod(keepAlive: true)
class PosSalesList extends _$PosSalesList {
  @override
  Future<List<PosSale>> build() async {
    final db = ref.watch(appDatabaseProvider);
    final local = PosLocalDataSource(db);
    final rows = await local.getAllSales();
    final sales = <PosSale>[];
    for (final row in rows) {
      final lines = await local.getSaleWithLines(row.id);
      final lineItems =
          lines?.$2
              .map(
                (line) => PosSaleLineItem(
                  name: line.itemName,
                  quantity: line.quantity,
                  lineTotal: line.lineTotal,
                  itemId: line.itemId,
                  unit: 'pcs',
                  unitPrice: line.rate,
                  cgstAmount: line.cgstAmount,
                  sgstAmount: line.sgstAmount,
                  igstAmount: line.igstAmount,
                ),
              )
              .toList() ??
          const [];
      sales.add(
        PosSale(
          id: row.id,
          docNumber: row.docNumber,
          completedAt: row.createdAt,
          totalAmount: row.totalAmount,
          taxAmount: row.taxAmount,
          finalAmount: row.finalAmount,
          itemCount: lineItems.fold<int>(
            0,
            (sum, line) => sum + line.quantity,
          ),
          partyId: row.partyId,
          paymentMethod: row.paymentMethod,
          payments: _parseStoredPayments(row.paymentMethod, row.finalAmount),
          items: lineItems,
        ),
      );
    }
    return sales;
  }

  void addSale(PosSale sale) {
    final current = state.asData?.value ?? const <PosSale>[];
    state = AsyncData([sale, ...current]);
  }

  PaymentMode _paymentModeFromApi(String apiValue) => switch (apiValue) {
    'upi' => PaymentMode.upi,
    'card' => PaymentMode.card,
    'bank_transfer' => PaymentMode.bank,
    _ => PaymentMode.cash,
  };

  List<PaymentEntry> _parseStoredPayments(String stored, double total) {
    final modes = stored
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (modes.isEmpty) {
      return [PaymentEntry(mode: PaymentMode.cash, amount: total)];
    }
    if (modes.length == 1) {
      return [
        PaymentEntry(mode: _paymentModeFromApi(modes.first), amount: total),
      ];
    }
    final share = total / modes.length;
    return modes
        .map(
          (mode) =>
              PaymentEntry(mode: _paymentModeFromApi(mode), amount: share),
        )
        .toList();
  }
}
