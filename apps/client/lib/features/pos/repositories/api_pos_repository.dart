// TODO: implement when Fastify API is ready
// Endpoints will be:
//   GET  /api/items?businessId=X&search=Y
//   POST /api/sales
//   GET  /api/customers?businessId=X&search=Y
//   GET  /api/customers/:id

import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';

class ApiPosRepository implements PosRepository {
  const ApiPosRepository({
    required this.baseUrl,
    required this.businessId,
  });

  final String baseUrl;
  final String businessId;

  // TODO: inject http client (Dio or http package)

  @override
  Future<List<PosItem>> getItems() {
    // TODO: GET $baseUrl/api/items?businessId=$businessId
    throw UnimplementedError('API not ready yet');
  }

  @override
  Future<List<PosItem>> searchItems(String query) {
    // TODO: GET $baseUrl/api/items?businessId=$businessId&search=$query
    throw UnimplementedError('API not ready yet');
  }

  @override
  Future<String> submitSale({
    required PosCartState cart,
    required String businessId,
  }) {
    // TODO: POST $baseUrl/api/sales
    throw UnimplementedError('API not ready yet');
  }

  @override
  Future<List<PosCustomer>> searchCustomers(String query) {
    // TODO: GET $baseUrl/api/customers?businessId=$businessId&search=$query
    throw UnimplementedError('API not ready yet');
  }

  @override
  Future<PosCustomer?> getCustomer(String customerId) {
    // TODO: GET $baseUrl/api/customers/$customerId
    throw UnimplementedError('API not ready yet');
  }
}
