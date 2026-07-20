import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/pos/application/pos_sale_service.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';

class ApiPosRepository implements PosRepository {
  ApiPosRepository({
    required PosSaleService posSaleService,
    required InventoryService inventoryService,
  }) : _posSaleService = posSaleService,
       _inventoryService = inventoryService;

  final PosSaleService _posSaleService;
  final InventoryService _inventoryService;

  @override
  Future<List<PosItem>> getItems() async {
    final items = await _inventoryService.fetchItems();
    return items.map(_mapInventoryItem).toList();
  }

  @override
  Future<List<PosItem>> searchItems(String query) async {
    final items = await _inventoryService.fetchItems(searchQuery: query);
    return items.map(_mapInventoryItem).toList();
  }

  @override
  Future<PosSale> submitSale({
    required PosCartState cart,
    required String businessId,
  }) async {
    try {
      return await _posSaleService.completeSale(
        businessId: businessId,
        items: cart.items,
        payments: cart.payments,
        customerName: cart.customerName,
        notes: null,
      );
    } on PosRepositoryException {
      rethrow;
    } catch (error) {
      throw PosRepositoryException(message: error.toString());
    }
  }

  @override
  Future<List<PosCustomer>> searchCustomers(String query) async {
    // Customer search wired in a later phase; walk-in sales use null party_id.
    return const [];
  }

  @override
  Future<PosCustomer?> getCustomer(String customerId) async {
    return null;
  }

  PosItem _mapInventoryItem(InventoryItem item) {
    final stock = InventoryStockCalculator.metricsFromItem(
      item,
    ).availableForSale.round();
    return PosItem(
      id: item.id,
      name: item.name,
      sku: item.barcode ?? item.id,
      category: item.categoryId ?? 'General',
      price: item.salePrice ?? 0,
      stock: stock,
      unit: item.baseUnitShortName ?? 'pcs',
    );
  }
}
