import 'package:billing_baba/features/pos/application/pos_sale_service.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';

class ApiPosRepository implements PosRepository {
  ApiPosRepository({required this._posSaleService});

  final PosSaleService _posSaleService;

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
}
