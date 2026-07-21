import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';

abstract class PosRepository {
  /// Submit a completed sale — deducts stock, creates ledger entry.
  Future<PosSale> submitSale({
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
