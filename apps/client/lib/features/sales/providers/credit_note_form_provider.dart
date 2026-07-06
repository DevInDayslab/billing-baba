import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/credit_note_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credit_note_form_provider.g.dart';

int _creditNoteLineItemCounter = 0;

String _nextCreditNoteLineItemId() {
  _creditNoteLineItemCounter += 1;
  return 'credit_note_line_$_creditNoteLineItemCounter';
}

CreditNoteFormState _initialCreditNoteFormState() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return CreditNoteFormState(
    returnDate: today,
    items: [SaleLineItem.empty(id: _nextCreditNoteLineItemId())],
  );
}

@riverpod
class CreditNoteForm extends _$CreditNoteForm {
  @override
  CreditNoteFormState build() => _initialCreditNoteFormState();

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  void resetForm() {
    state = _initialCreditNoteFormState();
  }

  Future<void> loadDocument(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleDocumentForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      state = CreditNoteFormState(
        documentId: loaded.documentId,
        partyId: loaded.partyId,
        party: loaded.party,
        returnNo: loaded.refNo,
        returnDate: loaded.invoiceDate,
        stateOfSupply: loaded.stateOfSupply,
        items: items,
        description: loaded.description,
      );
    } catch (error) {
      state = state.copyWith(saveError: SalesErrorMapper.messageFor(error));
    }
  }

  Future<List<SaleLineItem>> _resolveItemNames(List<SaleLineItem> items) async {
    final inventory = ref.read(inventoryItemsProvider).value ?? [];
    final itemNames = {for (final item in inventory) item.id: item.name};
    return [
      for (final line in items)
        if (line.itemId != null && line.itemName.isEmpty)
          line.copyWith(itemName: itemNames[line.itemId] ?? '')
        else
          line,
    ];
  }

  void updateParty(String value) {
    state = state.copyWith(party: value, isDirty: true, clearSaveError: true);
  }

  void updatePartyWithId({required String partyId, required String partyName}) {
    state = state.copyWith(
      partyId: partyId,
      party: partyName,
      isDirty: true,
      clearSaveError: true,
    );
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value, isDirty: true);
  }

  void updateReturnNo(String value) {
    state = state.copyWith(returnNo: value, isDirty: true);
  }

  void updateOriginalInvoiceNo(String value) {
    state = state.copyWith(originalInvoiceNo: value, isDirty: true);
  }

  void updateOriginalInvoiceDate(DateTime? date) {
    state = state.copyWith(originalInvoiceDate: date, isDirty: true);
  }

  void updateReturnDate(DateTime date) {
    state = state.copyWith(returnDate: date, isDirty: true);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value, isDirty: true);
  }

  void toggleRoundOff({required bool value}) {
    state = state.copyWith(roundOff: value, isDirty: true);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value, isDirty: true);
  }

  void updatePaymentType(String type) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(SalePaymentEntry(type: type));
    } else {
      payments[0] = payments[0].copyWith(type: type);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updatePaymentAmount(double amount) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(SalePaymentEntry(type: 'Cash', amount: amount));
    } else {
      payments[0] = payments[0].copyWith(amount: amount);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void addPaymentType() {
    final payments = [
      ...state.payments,
      const SalePaymentEntry(type: 'Cash'),
    ];
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void addImage(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedImages: [...state.attachedImages, attachment],
      isDirty: true,
    );
  }

  void removeImage(String id) {
    state = state.copyWith(
      attachedImages: state.attachedImages
          .where((image) => image.id != id)
          .toList(),
      isDirty: true,
    );
  }

  void updateImage(String id, String name) {
    state = state.copyWith(
      attachedImages: [
        for (final image in state.attachedImages)
          if (image.id == id) image.copyWith(name: name) else image,
      ],
      isDirty: true,
    );
  }

  void addDocument(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedDocuments: [...state.attachedDocuments, attachment],
      isDirty: true,
    );
  }

  void removeDocument(String id) {
    state = state.copyWith(
      attachedDocuments: state.attachedDocuments
          .where((document) => document.id != id)
          .toList(),
      isDirty: true,
    );
  }

  void updateDocument(String id, String name) {
    state = state.copyWith(
      attachedDocuments: [
        for (final document in state.attachedDocuments)
          if (document.id == id) document.copyWith(name: name) else document,
      ],
      isDirty: true,
    );
  }

  void addLineItem() {
    final items = [
      ...state.items,
      SaleLineItem.empty(id: _nextCreditNoteLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleLineItem.empty(id: _nextCreditNoteLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, SaleLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, isDirty: true, clearSaveError: true);
  }

  bool validate() {
    final isValid = state.isValid;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  SalesDocumentDraftInput _draftInput() => SalesDocumentDraftInput(
    documentId: state.documentId,
    partyId: state.partyId,
    documentType: SalesDocumentType.salesReturn,
    documentSeries: SalesConstants.creditNoteSeries,
    documentDate: state.returnDate,
    notes: state.description,
    items: state.items,
  );

  Future<String?> save() async {
    if (!validate()) return 'Please fill required fields';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.saveDocumentDraft(
        _draftInput(),
        itemNameToId: _itemNameToId(),
      );
      ref.invalidate(salesDocumentsListProvider(salesReturnListScope()));
      refreshAfterSaleReturn(ref);
      resetForm();
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<String?> finalize() async {
    if (!validate()) return 'Please fill required fields';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.finalizeDocumentDraft(
        _draftInput(),
        itemNameToId: _itemNameToId(),
      );
      ref.invalidate(salesDocumentsListProvider(salesReturnListScope()));
      refreshAfterSaleReturn(ref);
      resetForm();
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }
}

@riverpod
double creditNoteGrandTotal(Ref ref) {
  final form = ref.watch(creditNoteFormProvider);
  return form.total;
}
