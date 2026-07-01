import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_order_form_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_order_form_provider.g.dart';

int _saleOrderLineItemCounter = 0;

String _nextSaleOrderLineItemId() {
  _saleOrderLineItemCounter += 1;
  return 'order_line_$_saleOrderLineItemCounter';
}

SaleOrderFormState _initialSaleOrderFormState() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return SaleOrderFormState(
    orderDate: today,
    dueDate: today,
    items: [SaleLineItem.empty(id: _nextSaleOrderLineItemId())],
  );
}

@riverpod
class SaleOrderFormNotifier extends _$SaleOrderFormNotifier {
  @override
  SaleOrderFormState build() => _initialSaleOrderFormState();

  void openForm() {
    state = _initialSaleOrderFormState().copyWith(isFormOpen: true);
  }

  void resetForm() {
    state = _initialSaleOrderFormState();
  }

  void closeForm() {
    state = state.copyWith(isFormOpen: false);
  }

  void updateParty(String value) {
    state = state.copyWith(party: value);
  }

  void updateOrderNo(String value) {
    state = state.copyWith(orderNo: value);
  }

  void updateOrderDate(DateTime date) {
    state = state.copyWith(orderDate: date);
  }

  void updateDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value);
  }

  void updatePaymentType(String value) {
    state = state.copyWith(paymentType: value);
  }

  void updateAdvanceAmount(double value) {
    state = state.copyWith(advanceAmount: value);
  }

  void toggleRoundOff(bool value) {
    state = state.copyWith(roundOff: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void addImage(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedImages: [...state.attachedImages, attachment],
    );
  }

  void removeImage(String id) {
    state = state.copyWith(
      attachedImages:
          state.attachedImages.where((image) => image.id != id).toList(),
    );
  }

  void updateImage(String id, String name) {
    state = state.copyWith(
      attachedImages: [
        for (final image in state.attachedImages)
          if (image.id == id) image.copyWith(name: name) else image,
      ],
    );
  }

  void addDocument(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedDocuments: [...state.attachedDocuments, attachment],
    );
  }

  void removeDocument(String id) {
    state = state.copyWith(
      attachedDocuments: state.attachedDocuments
          .where((document) => document.id != id)
          .toList(),
    );
  }

  void updateDocument(String id, String name) {
    state = state.copyWith(
      attachedDocuments: [
        for (final document in state.attachedDocuments)
          if (document.id == id) document.copyWith(name: name) else document,
      ],
    );
  }

  void loadSavedOrder(SavedSaleOrder saved) {
    state = SaleOrderFormState(
      isFormOpen: true,
      party: saved.party,
      orderNo: saved.orderNo,
      orderDate: saved.orderDate,
      dueDate: saved.dueDate,
      stateOfSupply: saved.stateOfSupply,
      items: saved.items.isEmpty
          ? [SaleLineItem.empty(id: _nextSaleOrderLineItemId())]
          : List<SaleLineItem>.from(saved.items),
      paymentType: saved.paymentType,
      advanceAmount: saved.advanceAmount,
    );
  }

  void addLineItem() {
    final items = [
      ...state.items,
      SaleLineItem.empty(id: _nextSaleOrderLineItemId()),
    ];
    state = state.copyWith(items: items);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleLineItem.empty(id: _nextSaleOrderLineItemId()));
    }
    state = state.copyWith(items: items);
  }

  void updateLineItem(int index, SaleLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items);
  }

  bool validate() {
    final isValid = state.isValid;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  bool save() {
    if (!validate()) return false;
    final saved = SavedSaleOrder.fromFormState(
      id: nextSavedSaleOrderId(),
      form: state,
    );
    ref.read(savedSaleOrdersProvider.notifier).addOrder(saved);
    resetForm();
    return true;
  }
}

@riverpod
class SavedSaleOrdersNotifier extends _$SavedSaleOrdersNotifier {
  @override
  List<SavedSaleOrder> build() => [];

  void addOrder(SavedSaleOrder order) {
    state = [order, ...state];
  }

  void removeOrder(String id) {
    state = state.where((order) => order.id != id).toList();
  }
}

@riverpod
double saleOrderGrandTotal(Ref ref) {
  final form = ref.watch(saleOrderFormProvider);
  return form.total;
}
