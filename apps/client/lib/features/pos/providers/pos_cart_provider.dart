import 'dart:async';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/pos/data/pos_local_data_source.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';
import 'package:billing_baba/features/pos/providers/pos_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_cart_provider.g.dart';

@Riverpod(keepAlive: true)
class PosCart extends _$PosCart {
  late final PosLocalDataSource _localDataSource;

  @override
  PosCartState build() {
    _localDataSource = PosLocalDataSource(ref.watch(appDatabaseProvider));
    unawaited(_loadHeldBills());
    return const PosCartState();
  }

  Future<void> _loadHeldBills() async {
    final bills = await _localDataSource.getHeldBills();
    state = state.copyWith(heldBills: bills);
  }

  void addItem(PosItem item) {
    final index = state.items.indexWhere((c) => c.item.id == item.id);
    if (index >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(item: item, quantity: 1),
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
    final updated = state.items.map((c) {
      if (c.item.id == itemId) {
        return c.copyWith(quantity: qty);
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
    final bill = HeldBill(
      id: 'HOLD-${DateTime.now().millisecondsSinceEpoch}',
      items: List<CartItem>.from(state.items),
      heldAt: DateTime.now(),
      payments: List<PaymentEntry>.from(state.payments),
      customerName: state.customerName,
    );
    await _localDataSource.saveHeldBill(bill);
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
    unawaited(_localDataSource.deleteHeldBill(bill.id));
    _syncSinglePaymentAmount();
  }

  Future<void> discardHeldBill(String id) async {
    await _localDataSource.deleteHeldBill(id);
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
      final sale = await repository.submitSale(
        cart: state,
        businessId: businessId,
      );
      clearCart();
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
