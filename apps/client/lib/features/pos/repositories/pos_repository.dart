import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';

abstract class PosRepository {
  /// Fetch all available items (with stock levels)
  Future<List<PosItem>> getItems();

  /// Search items by name or SKU
  Future<List<PosItem>> searchItems(String query);

  /// Submit a completed sale — deducts stock, creates ledger entry
  Future<String> submitSale({
    required PosCartState cart,
    required String businessId,
  });

  /// Search customers by name or phone
  Future<List<PosCustomer>> searchCustomers(String query);

  /// Fetch single customer by ID
  Future<PosCustomer?> getCustomer(String customerId);
}

class PosCustomer {
  const PosCustomer({
    required this.id,
    required this.name,
    this.phone,
    this.outstanding = 0,
    this.creditLimit = 0,
  });

  final String id;
  final String name;
  final String? phone;
  final double outstanding;
  final double creditLimit;
}
