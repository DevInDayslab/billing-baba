import 'dart:async';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/providers/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:billing_baba/features/pos/data/pos_local_data_source.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';
import 'package:billing_baba/features/pos/providers/pos_repository_provider.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_cart_provider.g.dart';

@Riverpod(keepAlive: true)
class PosCart extends _$PosCart {
  late final PosLocalDataSource _localDataSource;

  @override
  PosCartState build() {
    _localDataSource = PosLocalDataSource(ref.watch(appDatabaseProvider));
    ref.listen(currentBusinessProvider, (previous, next) {
      final previousId = previous?.id;
      final nextId = next?.id;
      if (previousId != nextId) {
        state = const PosCartState();
        unawaited(_loadHeldBills());
      }
    });
    unawaited(_loadHeldBills());
    return const PosCartState();
  }

  String? get _businessId => ref.read(currentBusinessProvider)?.id;

  PosItem? _livePosItem(PosItem item) {
    final inventoryItems = ref.read(inventoryItemsProvider).value;
    if (inventoryItems == null) return item;
    final categories = ref.read(inventoryCategoriesProvider).value ?? const [];
    return findLivePosItem(
          itemId: item.id,
          inventoryItems: inventoryItems,
          categoryNamesById: categoryNamesById(categories),
        ) ??
        item;
  }

  int _cartQuantityFor(String itemId) {
    return state.items
        .where((cartItem) => cartItem.item.id == itemId)
        .fold<int>(0, (sum, cartItem) => sum + cartItem.quantity);
  }

  bool _canAddQuantity(PosItem item, int additionalQty) {
    final live = _livePosItem(item);
    if (live == null || live.stock <= 0) return false;
    return _cartQuantityFor(item.id) + additionalQty <= live.stock;
  }

  Future<void> _loadHeldBills() async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) {
      state = state.copyWith(heldBills: const []);
      return;
    }
    final bills = await _localDataSource.getHeldBills(businessId);
    state = state.copyWith(heldBills: bills);
  }

  void addItem(PosItem item) {
    if (!_canAddQuantity(item, 1)) return;

    final live = _livePosItem(item) ?? item;
    final index = state.items.indexWhere((c) => c.item.id == live.id);
    if (index >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[index] = updated[index].copyWith(
        item: live,
        quantity: updated[index].quantity + 1,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(item: live, quantity: 1),
        ],
      );
    }
    _syncSinglePaymentAmount();
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((c) => c.item.id != itemId).toList(),
    );
    _syncSinglePaymentAmount();
  }

  void updateQuantity(String itemId, int qty) {
    if (qty <= 0) {
      removeItem(itemId);
      return;
    }

    final cartItem = state.items.where((c) => c.item.id == itemId).firstOrNull;
    var nextQty = qty;
    if (cartItem != null &&
        !_canAddQuantity(cartItem.item, nextQty - cartItem.quantity)) {
      final live = _livePosItem(cartItem.item);
      nextQty = live?.stock ?? cartItem.item.stock;
      if (nextQty <= 0) {
        removeItem(itemId);
        return;
      }
    }

    final updated = state.items.map((c) {
      if (c.item.id == itemId) {
        final live = _livePosItem(c.item) ?? c.item;
        return c.copyWith(item: live, quantity: nextQty);
      }
      return c;
    }).toList();
    state = state.copyWith(items: updated);
    _syncSinglePaymentAmount();
  }

  void updateDiscount(String itemId, double percent) {
    final updated = state.items.map((c) {
      if (c.item.id == itemId) {
        return c.copyWith(discountPercent: percent);
      }
      return c;
    }).toList();
    state = state.copyWith(items: updated);
    _syncSinglePaymentAmount();
  }

  void addPayment(PaymentEntry entry) {
    state = state.copyWith(payments: [...state.payments, entry]);
  }

  void removePayment(int index) {
    if (index < 0 || index >= state.payments.length) return;
    final updated = List<PaymentEntry>.from(state.payments)..removeAt(index);
    state = state.copyWith(payments: updated);
  }

  void removePaymentByMode(PaymentMode mode) {
    state = state.copyWith(
      payments: state.payments.where((p) => p.mode != mode).toList(),
    );
  }

  void updatePaymentAmount(PaymentMode mode, double amount) {
    final updated = state.payments.map((p) {
      if (p.mode == mode) {
        return p.copyWith(amount: amount);
      }
      return p;
    }).toList();
    state = state.copyWith(payments: updated);
  }

  void togglePaymentMode(PaymentMode mode) {
    final exists = state.payments.any((p) => p.mode == mode);
    if (exists) {
      removePaymentByMode(mode);
      return;
    }

    final newPayments = [
      ...state.payments,
      PaymentEntry(mode: mode, amount: 0),
    ];
    state = state.copyWith(payments: newPayments);

    if (newPayments.length == 1) {
      _syncSinglePaymentAmount();
    }
  }

  bool isPaymentModeSelected(PaymentMode mode) {
    return state.payments.any((p) => p.mode == mode);
  }

  void clearPayments() {
    state = state.copyWith(payments: []);
  }

  Future<void> holdBill() async {
    if (state.items.isEmpty) return;
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return;

    final bill = HeldBill(
      id: 'HOLD-${DateTime.now().millisecondsSinceEpoch}',
      items: List<CartItem>.from(state.items),
      heldAt: DateTime.now(),
      payments: List<PaymentEntry>.from(state.payments),
      customerName: state.customerName,
    );
    await _localDataSource.saveHeldBill(businessId, bill);
    state = state.copyWith(
      heldBills: [...state.heldBills, bill],
      items: [],
      payments: [],
      billDiscountPercent: 0,
      clearCustomerName: true,
    );
  }

  void resumeBill(HeldBill bill) {
    state = state.copyWith(
      items: List<CartItem>.from(bill.items),
      heldBills: state.heldBills.where((b) => b.id != bill.id).toList(),
      payments: List<PaymentEntry>.from(bill.payments),
      customerName: bill.customerName,
      clearCustomerName: bill.customerName == null,
    );
    unawaited(_localDataSource.deleteHeldBill(_businessId ?? '', bill.id));
    _syncSinglePaymentAmount();
  }

  Future<void> discardHeldBill(String id) async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return;

    await _localDataSource.deleteHeldBill(businessId, id);
    state = state.copyWith(
      heldBills: state.heldBills.where((b) => b.id != id).toList(),
    );
  }

  void updateBillDiscount(double percent) {
    final clamped = percent.clamp(0, 100).toDouble();
    state = state.copyWith(billDiscountPercent: clamped);
    _syncSinglePaymentAmount();
  }

  void clearCart() {
    state = state.copyWith(items: [], payments: [], billDiscountPercent: 0);
  }

  void setCustomerName(String? name) {
    state = state.copyWith(
      customerName: name,
      clearCustomerName: name == null,
    );
  }

  Future<PosSale> completeSale() async {
    if (state.items.isEmpty) {
      throw const PosRepositoryException(message: 'Cart is empty');
    }

    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId == null || businessId.isEmpty) {
      throw const PosRepositoryException(
        message: 'No active business selected. Open a business first.',
      );
    }

    final repository = await ref.read(posRepositoryProvider.future);
    try {
      final itemIds = state.items.map((cartItem) => cartItem.item.id).toList();
      final sale = await repository.submitSale(
        cart: state,
        businessId: businessId,
      );
      clearCart();
      await refreshAfterSaleMutation(
        ref,
        context: (
          partyId: sale.partyId,
          itemIds: itemIds,
        ),
      );
      return sale;
    } on PosRepositoryException {
      rethrow;
    } catch (error) {
      throw PosRepositoryException(message: error.toString());
    }
  }

  void _syncSinglePaymentAmount() {
    if (state.payments.length == 1) {
      final mode = state.payments.first.mode;
      state = state.copyWith(
        payments: [PaymentEntry(mode: mode, amount: state.totalPayable)],
      );
    }
  }
}
