import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';
import 'package:billing_baba/features/pos/providers/pos_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_cart_provider.g.dart';

@Riverpod(keepAlive: true)
class PosCart extends _$PosCart {
  @override
  PosCartState build() => const PosCartState();

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
        items: [...state.items, CartItem(item: item, quantity: 1)],
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

    final newPayments = [...state.payments, PaymentEntry(mode: mode, amount: 0)];
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

  void holdBill() {
    if (state.items.isEmpty) return;
    final bill = HeldBill(
      id: 'HOLD-${DateTime.now().millisecondsSinceEpoch}',
      items: List<CartItem>.from(state.items),
      heldAt: DateTime.now(),
    );
    state = state.copyWith(
      heldBills: [...state.heldBills, bill],
      items: [],
      payments: [],
    );
  }

  void resumeBill(String heldBillId) {
    final bill = state.heldBills.firstWhere((b) => b.id == heldBillId);
    state = state.copyWith(
      items: List<CartItem>.from(bill.items),
      heldBills: state.heldBills.where((b) => b.id != heldBillId).toList(),
      payments: [],
    );
    _syncSinglePaymentAmount();
  }

  void clearCart() {
    state = state.copyWith(items: [], payments: []);
  }

  void setCustomerName(String? name) {
    state = state.copyWith(
      customerName: name,
      clearCustomerName: name == null,
    );
  }

  Future<String> completeSale() async {
    final repository = ref.read(posRepositoryProvider);
    try {
      final saleId = await repository.submitSale(
        cart: state,
        businessId: 'mock-business-id', // TODO: read from active business provider
      );
      clearCart();
      return saleId;
    } catch (e) {
      rethrow;
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
