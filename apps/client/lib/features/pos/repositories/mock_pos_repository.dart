import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';

class MockPosRepository implements PosRepository {
  static const _mockItems = [
    PosItem(
      id: 'DAI-001',
      name: 'Amul Taaza Milk 1L',
      sku: 'DAI-001',
      category: 'Dairy',
      price: 65,
      stock: 24,
    ),
    PosItem(
      id: 'DAI-002',
      name: 'Amul Butter 500g',
      sku: 'DAI-002',
      category: 'Dairy',
      price: 245,
      stock: 8,
    ),
    PosItem(
      id: 'DAI-003',
      name: 'Amul Paneer 200g',
      sku: 'DAI-003',
      category: 'Dairy',
      price: 89,
      stock: 15,
    ),
    PosItem(
      id: 'BAK-002',
      name: 'Britannia Bread',
      sku: 'BAK-002',
      category: 'Bakery',
      price: 35,
      stock: 18,
    ),
    PosItem(
      id: 'BAK-009',
      name: 'Parle-G Biscuits',
      sku: 'BAK-009',
      category: 'Bakery',
      price: 10,
      stock: 35,
    ),
    PosItem(
      id: 'BAK-010',
      name: 'Good Day Biscuits',
      sku: 'BAK-010',
      category: 'Bakery',
      price: 30,
      stock: 20,
    ),
    PosItem(
      id: 'GRO-003',
      name: 'Aashirvaad Atta 1kg',
      sku: 'GRO-003',
      category: 'Grocery',
      price: 62,
      stock: 15,
    ),
    PosItem(
      id: 'GRO-005',
      name: 'Sugar 1kg',
      sku: 'GRO-005',
      category: 'Grocery',
      price: 45,
      stock: 30,
    ),
    PosItem(
      id: 'GRO-006',
      name: 'Fortune Sunflower Oil 1L',
      sku: 'GRO-006',
      category: 'Grocery',
      price: 145,
      stock: 12,
    ),
    PosItem(
      id: 'SNA-004',
      name: 'Maggi 2-Min Noodles',
      sku: 'SNA-004',
      category: 'Snacks',
      price: 14,
      stock: 40,
    ),
    PosItem(
      id: 'SNA-010',
      name: "Lay's Classic",
      sku: 'SNA-010',
      category: 'Snacks',
      price: 20,
      stock: 50,
    ),
    PosItem(
      id: 'SNA-011',
      name: 'Kurkure',
      sku: 'SNA-011',
      category: 'Snacks',
      price: 20,
      stock: 45,
    ),
  ];

  static const _mockCustomers = [
    PosCustomer(
      id: 'C001',
      name: 'Rajesh Sharma',
      phone: '9876543210',
      outstanding: 1500,
      creditLimit: 5000,
    ),
    PosCustomer(
      id: 'C002',
      name: 'Priya Singh',
      phone: '9123456789',
      outstanding: 0,
      creditLimit: 2000,
    ),
    PosCustomer(
      id: 'C003',
      name: 'Amit Kumar',
      phone: '9988776655',
      outstanding: 500,
      creditLimit: 3000,
    ),
    PosCustomer(
      id: 'C004',
      name: 'Sunita Devi',
      phone: '9765432100',
      outstanding: 0,
      creditLimit: 0,
    ),
    PosCustomer(
      id: 'C005',
      name: 'Vikram Patel',
      phone: '9654321000',
      outstanding: 2200,
      creditLimit: 5000,
    ),
  ];

  @override
  Future<List<PosItem>> getItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<PosItem>.from(_mockItems);
  }

  @override
  Future<List<PosItem>> searchItems(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final lower = query.toLowerCase();
    return _mockItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(lower) ||
              item.sku.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Future<String> submitSale({
    required PosCartState cart,
    required String businessId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // ignore: avoid_print
    print(
      'Sale submitted: ${cart.totalItems} items, '
      'total ₹${cart.totalPayable}, payments: ${cart.payments}',
    );
    return 'SALE-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<List<PosCustomer>> searchCustomers(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final lower = query.toLowerCase();
    return _mockCustomers
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(lower) ||
              (customer.phone?.contains(query) ?? false),
        )
        .toList();
  }

  @override
  Future<PosCustomer?> getCustomer(String customerId) async {
    for (final customer in _mockCustomers) {
      if (customer.id == customerId) return customer;
    }
    return null;
  }
}
