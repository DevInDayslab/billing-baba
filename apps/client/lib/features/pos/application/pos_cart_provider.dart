import 'dart:async';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:billing_baba/features/pos/application/pos_repository_provider.dart';
import 'package:billing_baba/features/pos/data/pos_local_data_source.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_cart_provider.g.dart';

/// Default cart session for the POS module; sale screen uses per-tab session keys.
const defaultPosCartSessionKey = 'default';

@Riverpod(keepAlive: true)
class PosCart extends _$PosCart {
  PosLocalDataSource get _localDataSource =>
      PosLocalDataSource(ref.read(appDatabaseProvider));

  void _scheduleLoadHeldBills() {
    unawaited(
      Future(() {
        if (!ref.mounted) return;
        unawaited(_loadHeldBills());
      }),
    );
  }

  void _scheduleResetForBusinessChange() {
    unawaited(
      Future(() {
        if (!ref.mounted) return;
        state = const PosCartState();
        unawaited(_loadHeldBills());
      }),
    );
  }

  @override
  PosCartState build({String sessionKey = defaultPosCartSessionKey}) {
    ref.listen(currentBusinessProvider, (previous, next) {
      final previousId = previous?.id;
      final nextId = next?.id;
      if (previousId != nextId) {
        _scheduleResetForBusinessChange();
      }
    });
    // Defer so we never mutate state while the widget tree is building.
    _scheduleLoadHeldBills();
    return const PosCartState();
  }

  String? get _businessId => ref.read(currentBusinessProvider)?.id;

  PosItem? _livePosItem(PosItem item) {
    final inventoryItems = ref.read(inventoryItemListProvider);
    if (inventoryItems.isEmpty) return item;
    final categories = ref.read(inventoryCategoriesProvider).value ?? const [];
    return findLivePosItem(
          itemId: item.id,
          inventoryItems: inventoryItems,
          categoryNamesById: categoryNamesById(categories),
        ) ??
        item;
  }

  bool _canAddQuantity(
    PosItem item,
    int targetTotalQty, {
    bool allowInsufficientStock = false,
  }) {
    if (allowInsufficientStock) return true;
    final live = _livePosItem(item);
    if (live == null || live.stock <= 0) return false;
    return targetTotalQty <= live.stock;
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

  /// Reload held bills from local storage (e.g. after resume/discard on another tab).
  Future<void> refreshHeldBills() => _loadHeldBills();

  void addItem(PosItem item, {bool allowInsufficientStock = false}) {
    final live = _livePosItem(item) ?? item;
    final index = state.items.indexWhere((c) => c.item.id == live.id);
    final existing = index >= 0 ? state.items[index] : null;
    final allowStock =
        allowInsufficientStock || (existing?.allowInsufficientStock ?? false);
    final nextQty = (existing?.quantity ?? 0) + 1;
    if (!_canAddQuantity(
      live,
      nextQty,
      allowInsufficientStock: allowStock,
    )) {
      return;
    }

    if (index >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[index] = updated[index].copyWith(
        item: live,
        quantity: nextQty,
        allowInsufficientStock: allowStock,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            item: live,
            quantity: 1,
            allowInsufficientStock: allowInsufficientStock,
          ),
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

  /// Swaps a cart line's product while keeping qty, discount, and stock flags.
  void replaceLineItem(String oldItemId, PosItem newItem) {
    final index = state.items.indexWhere((c) => c.item.id == oldItemId);
    if (index < 0) return;

    final existing = state.items[index];
    final live = _livePosItem(newItem) ?? newItem;
    final updated = List<CartItem>.from(state.items);
    updated[index] = CartItem(
      item: live,
      quantity: existing.quantity,
      discountPercent: existing.discountPercent,
      allowInsufficientStock: existing.allowInsufficientStock,
    );
    state = state.copyWith(items: updated);
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
        !_canAddQuantity(
          cartItem.item,
          nextQty,
          allowInsufficientStock: cartItem.allowInsufficientStock,
        )) {
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

  void updateUnitPrice(String itemId, double price) {
    if (price < 0) return;

    final updated = state.items.map((c) {
      if (c.item.id != itemId) return c;
      final catalogPrice = _livePosItem(c.item)?.price ?? c.item.price;
      final matchesCatalog = (price - catalogPrice).abs() < 0.0001;
      if (matchesCatalog) {
        return c.copyWith(clearUnitPriceOverride: true);
      }
      return c.copyWith(unitPriceOverride: price);
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
    final index = state.payments.indexWhere((payment) => payment.mode == mode);
    if (index < 0) return;

    final updated = applySplitPaymentCascade(
      payments: state.payments,
      editedIndex: index,
      amount: amount,
      totalPayable: state.totalPayable,
    );
    state = state.copyWith(payments: updated);
  }

  void updatePaymentBankAccount(PaymentMode mode, String? bankAccountId) {
    final index = state.payments.indexWhere((payment) => payment.mode == mode);
    if (index < 0) return;
    final updated = [...state.payments];
    updated[index] = updated[index].copyWith(bankAccountId: bankAccountId);
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

  Future<PosSale> completeSale({bool clearCartOnSuccess = true}) async {
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
      if (clearCartOnSuccess) {
        clearCart();
      }
      unawaited(
        refreshAfterSaleMutation(
          ref,
          context: (
            partyId: sale.partyId,
            itemIds: itemIds,
          ),
        ),
      );
      return sale;
    } on PosRepositoryException {
      rethrow;
    } catch (error) {
      throw PosRepositoryException(
        message: OfflineUiMessages.messageFor(error),
      );
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
