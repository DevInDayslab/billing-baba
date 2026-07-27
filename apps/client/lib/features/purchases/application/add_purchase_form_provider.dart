import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/purchases/application/pending_purchase_document_parse_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_document_item_factory.dart';
import 'package:billing_baba/features/purchases/application/purchase_document_parse_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_document_party_factory.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/data/purchase_bill_command_repository.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_document_draft_input.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/purchases/utils/purchase_line_item_catalog.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/documents/document_line_sync.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/shared/forms/transaction_party_link.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_purchase_form_provider.g.dart';

int _purchaseLineItemCounter = 0;

String _nextPurchaseLineItemId() {
  _purchaseLineItemCounter += 1;
  return 'purchase_line_$_purchaseLineItemCounter';
}

AddPurchaseFormState _defaultFormState({String? documentId}) {
  final now = DateTime.now();
  return AddPurchaseFormState(
    documentId: documentId,
    billNumber: 'Auto',
    billDate: DateTime(now.year, now.month, now.day),
    billTime: TimeOfDay.fromDateTime(now),
    dueDate: DateTime(now.year, now.month, now.day),
    items: [PurchaseLineItem.empty(id: _nextPurchaseLineItemId())],
    isLoading: documentId != null,
  );
}

@riverpod
class AddPurchaseForm extends _$AddPurchaseForm {
  @override
  AddPurchaseFormState build({String? billId}) {
    if (billId != null) {
      Future.microtask(() => _loadDocument(billId));
      return _defaultFormState(documentId: billId);
    }
    Future.microtask(_consumePendingParse);
    return _defaultFormState();
  }

  Future<void> _consumePendingParse() async {
    if (billId != null) return;
    final pending = ref
        .read(pendingPurchaseDocumentParseProvider.notifier)
        .take();
    if (pending == null) return;
    debugPrint('[PurchaseParse] consuming pending parse on Add Purchase mount');
    try {
      await applyParsedDocument(pending);
      debugPrint('[PurchaseParse] pending parse applied');
    } on Object catch (error, stackTrace) {
      debugPrint('[PurchaseParse] pending parse failed: $error\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        saveError: PurchaseErrorMapper.messageFor(error),
      );
    }
  }

  Future<void> applyParsedDocument(PurchaseDocumentParseDto parsed) async {
    debugPrint(
      '[PurchaseParse] applyParsedDocument start lines=${parsed.lines.length}',
    );
    try {
      final parties = await _partiesForParsedDocument(parsed);

      final mapped = PurchaseDocumentParseMapper.apply(
        base: state,
        parsed: parsed,
        parties: parties,
        itemNameToId: _itemNameToId(),
        nextLineId: _nextPurchaseLineItemId,
      );
      final linkedItems = await _ensureInventoryItemsForParsedLines(
        mapped.items,
      );
      final items = await _resolveItemNames(linkedItems);
      state = mapped.copyWith(
        items: items,
        isLoading: false,
        clearSaveError: true,
      );
      debugPrint(
        '[PurchaseParse] applyParsedDocument complete items=${items.length} partyId=${mapped.partyId}',
      );
    } on Object catch (error, stackTrace) {
      debugPrint(
        '[PurchaseParse] applyParsedDocument error: $error\n$stackTrace',
      );
      state = state.copyWith(
        isLoading: false,
        saveError: PurchaseErrorMapper.messageFor(error),
      );
    }
  }

  /// Resolves the supplier party list for mapping, creating the party via
  /// [partyServiceProvider] when the parsed vendor is not already known.
  ///
  /// Uses the service directly instead of [partyListProvider.notifier.createParty]
  /// so we do not invalidate [partyListProvider] from inside its own notifier
  /// (Riverpod assertion: a provider cannot depend on itself).
  Future<List<PartyModel>> _partiesForParsedDocument(
    PurchaseDocumentParseDto parsed,
  ) async {
    var parties = ref.read(partiesListProvider);
    if (!PurchaseDocumentPartyFactory.needsCreation(parsed, parties)) {
      return parties;
    }

    debugPrint('[PurchaseParse] creating supplier party from parsed bill');
    final partyResult = PurchaseDocumentPartyFactory.toAddPartyResult(parsed);
    final partyService = await ref.read(partyServiceProvider.future);

    try {
      final created = await partyService.createParty(partyResult);
      debugPrint('[PurchaseParse] supplier party created id=${created.id}');

      final existingIndex = parties.indexWhere(
        (party) => party.id == created.id,
      );
      if (existingIndex >= 0) {
        parties = List<PartyModel>.from(parties);
        parties[existingIndex] = created;
        return parties;
      }

      return [...parties, created];
    } on PartyOfflineException {
      debugPrint('[PurchaseParse] supplier party queued offline');
      final refreshed = await partyService.fetchParties();
      final match = PurchaseDocumentParseMapper.resolveParty(parsed, refreshed);
      if (match != null) return refreshed;
      return parties;
    } on Object catch (error, stackTrace) {
      debugPrint(
        '[PurchaseParse] supplier party creation failed, continuing form fill: $error\n$stackTrace',
      );
      try {
        final refreshed = await partyService.fetchParties();
        final match = PurchaseDocumentParseMapper.resolveParty(
          parsed,
          refreshed,
        );
        if (match != null) return refreshed;
      } on Object catch (refreshError, refreshStack) {
        debugPrint(
          '[PurchaseParse] party refresh after create failure: $refreshError\n$refreshStack',
        );
      }
      return parties;
    }
  }

  Future<void> _loadDocument(String documentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final loaded = await service.loadPurchaseBillForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      final attachments = await loadTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.purchase.apiValue,
        entityId: documentId,
      );
      state = loaded.copyWith(
        items: items,
        attachedImages: attachments.images,
        attachedDocuments: attachments.documents,
        isLoading: false,
        showValidationErrors: kResetValidationOnLoad,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: PurchaseErrorMapper.messageFor(error),
      );
    }
  }

  Future<List<PurchaseLineItem>> _resolveItemNames(
    List<PurchaseLineItem> items,
  ) async {
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

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return PurchaseDocumentItemFactory.buildNameToIdMap(items);
  }

  /// Links OCR lines to inventory, creating missing items once per unique name.
  Future<List<PurchaseLineItem>> _ensureInventoryItemsForParsedLines(
    List<PurchaseLineItem> items,
  ) async {
    if (items.isEmpty) return items;

    final inventory = ref.read(inventoryItemsProvider).value ?? [];
    final nameToId = PurchaseDocumentItemFactory.buildNameToIdMap(inventory);
    var lines = PurchaseDocumentItemFactory.assignItemIds(items, nameToId);

    final templates = PurchaseDocumentItemFactory.linesNeedingCreation(
      lines,
      nameToId,
    );
    if (templates.isEmpty) return lines;

    debugPrint(
      '[PurchaseParse] creating ${templates.length} inventory item(s) from parsed bill',
    );

    for (final template in templates) {
      final key = PurchaseDocumentItemFactory.normalizeName(template.itemName);
      if (key.isEmpty || nameToId.containsKey(key)) continue;

      final created = await _createInventoryItemFromParsedLine(template);
      if (created != null) {
        nameToId[key] = created.id;
        debugPrint(
          '[PurchaseParse] inventory item created id=${created.id} name=${created.name}',
        );
      }
    }

    lines = PurchaseDocumentItemFactory.assignItemIds(lines, nameToId);
    return lines;
  }

  Future<InventoryItem?> _createInventoryItemFromParsedLine(
    PurchaseLineItem line,
  ) async {
    try {
      final units = await ref.read(inventoryUnitsProvider.future);
      final form = PurchaseDocumentItemFactory.toAddItemFormState(
        line: line,
        units: units,
      );
      if (form == null) {
        debugPrint(
          '[PurchaseParse] skipped item create for "${line.itemName}": missing units or name',
        );
        return null;
      }

      return ref.read(inventoryItemsProvider.notifier).addItemFromForm(form);
    } on Object catch (error, stackTrace) {
      debugPrint(
        '[PurchaseParse] inventory item creation failed for "${line.itemName}", continuing form fill: $error\n$stackTrace',
      );
      return null;
    }
  }

  void updateParty(String value, {String? partyId}) {
    final change = unlinkedPartyNameChange(
      newName: value,
      previousName: state.party,
      currentPartyId: state.partyId,
    );
    state = state.copyWith(
      party: change.partyName,
      partyId: partyId,
      clearPartyId: partyId == null && change.clearPartyId,
      billingName: state.billingName.isEmpty ? value : state.billingName,
      isDirty: true,
      clearSaveError: true,
    );
  }

  void updateBillingName(String value) {
    state = state.copyWith(
      billingName: value,
      isDirty: true,
      clearSaveError: true,
    );
  }

  void updateEWayBillNo(String value) {
    state = state.copyWith(eWayBillNo: value, isDirty: true);
  }

  void updateBillNumber(String value) {
    state = state.copyWith(billNumber: value, isDirty: true);
  }

  void updateBillDate(DateTime date) {
    state = state.copyWith(billDate: date, isDirty: true);
  }

  void updateBillTime(TimeOfDay time) {
    state = state.copyWith(billTime: time, isDirty: true);
  }

  void updatePaymentTerms(String value) {
    state = state.copyWith(paymentTerms: value, isDirty: true);
  }

  void updateDueDate(DateTime? date) {
    state = state.copyWith(dueDate: date, isDirty: true);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value, isDirty: true);
  }

  void updateGodown(String value, {String? godownId}) {
    state = state.copyWith(
      godown: value,
      godownId: godownId ?? state.godownId,
      isDirty: true,
    );
  }

  void updateTermsTitle(String value) {
    state = state.copyWith(termsTitle: value, isDirty: true);
  }

  void updateTermsNotes(String value) {
    state = state.copyWith(termsNotes: value, isDirty: true);
  }

  void addLineItem() {
    final items = [
      ...state.items,
      PurchaseLineItem.empty(id: _nextPurchaseLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(PurchaseLineItem.empty(id: _nextPurchaseLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, PurchaseLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, isDirty: true);
  }

  void applyTaxPercentToAllLines(double taxPercent) {
    if (state.items.isEmpty) return;

    final items = [
      for (final item in state.items)
        item.copyWith(
          taxPercent: taxPercent,
          priceIsTaxInclusive: taxPercent > 0 || item.priceIsTaxInclusive,
        ),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void selectCatalogItem(int index, SaleItemOption catalogItem) {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    final applied = applyCatalogItemToPurchaseLine(line, catalogItem);
    final items = selectCatalogItemOnPurchaseLines(
      items: state.items,
      targetIndex: index,
      appliedLine: applied,
      nextLineId: _nextPurchaseLineItemId,
    );
    state = state.copyWith(items: items, isDirty: true);
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
      const SalePaymentEntry(type: 'UPI'),
    ];
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value, isDirty: true);
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

  void toggleRoundOff({required bool value}) {
    state = state.copyWith(roundOff: value, isDirty: true);
  }

  String? _validationError({bool finalize = false}) {
    return buildTransactionValidationError(
      hasValidLineItems: state.hasValidLineItems,
      hasValidParty: state.partyId != null && state.partyId!.isNotEmpty,
      requireParty: finalize,
    );
  }

  bool validate({bool finalize = false}) {
    final hasLines = state.hasValidLineItems;
    final hasParty = state.partyId != null && state.partyId!.isNotEmpty;

    final isValid = hasLines && (!finalize || hasParty);
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  Future<String?> _preparePartyForPurchase() async {
    final partyId = state.partyId;
    if (partyId == null || partyId.isEmpty) {
      state = state.copyWith(showValidationErrors: true);
      return 'Please select a party';
    }

    final partyService = await ref.read(partyServiceProvider.future);
    await partyService.ensureSupplierRole(partyId);
    return null;
  }

  Future<String?> saveDraft() async {
    if (state.isSaving) return null;
    if (!validate()) return _validationError();

    final partyError = await _preparePartyForPurchase();
    if (partyError != null) return partyError;

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final input = service.draftInputFromBillForm(
        state,
        documentType: PurchaseDocumentType.purchaseBill,
      );
      final document = await service.saveDocumentDraft(
        input.copyWith(partyId: state.partyId),
        itemNameToId: _itemNameToId(),
      );
      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.purchase.apiValue,
        entityId: document.id,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      state = state.copyWith(
        documentId: document.id,
        items: bindPurchaseServerLineIds(state.items, document.lines),
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
        isSaving: false,
        isDirty: false,
      );
      ref.invalidate(purchaseBillsProvider);
      await _refreshAfterPurchaseMutation();
      return null;
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<String?> saveBill({bool finalize = true}) async {
    if (state.isSaving) return null;
    if (!validate(finalize: finalize)) {
      return _validationError(finalize: finalize);
    }

    final partyError = await _preparePartyForPurchase();
    if (partyError != null) return partyError;

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final input = service.draftInputFromBillForm(
        state,
        documentType: PurchaseDocumentType.purchaseBill,
      );

      final PurchaseDocumentDto document;
      if (finalize) {
        FinalizePurchasePaymentCommand? payment;
        if (state.paymentAmount > 0) {
          final payAmount = state.paymentAmount
              .clamp(0, state.grandTotal)
              .toDouble();
          payment = FinalizePurchasePaymentCommand(
            amount: payAmount.toStringAsFixed(4),
            paymentMode: PurchasePaymentModes.toApi(state.paymentType),
          );
        }
        document = await service.finalizeDocumentDraft(
          input.copyWith(partyId: state.partyId),
          itemNameToId: _itemNameToId(),
          godownId: state.godownId,
          payment: payment,
        );
      } else {
        document = await service.saveDocumentDraft(
          input.copyWith(partyId: state.partyId),
          itemNameToId: _itemNameToId(),
        );
      }

      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.purchase.apiValue,
        entityId: document.id,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      state = state.copyWith(
        documentId: document.id,
        items: bindPurchaseServerLineIds(state.items, document.lines),
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
        isSaving: false,
        isDirty: false,
      );

      ref.invalidate(purchaseBillsProvider);
      await _refreshAfterPurchaseMutation();
      ref
          .read(purchaseBillSaveSuccessMessageProvider.notifier)
          .setMessage(
            billId == null
                ? 'Purchase bill saved successfully.'
                : 'Purchase bill updated successfully.',
          );
      ref.invalidateSelf();
      return null;
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<void> _refreshAfterPurchaseMutation() async {
    final itemIds = state.items
        .map((line) => line.itemId)
        .whereType<String>()
        .where((id) => id.isNotEmpty);
    await refreshAfterPurchaseMutation(
      ref,
      context: (
        partyId: state.partyId,
        itemIds: itemIds,
      ),
    );
  }
}

extension on PurchaseDocumentDraftInput {
  PurchaseDocumentDraftInput copyWith({String? partyId}) {
    return PurchaseDocumentDraftInput(
      documentId: documentId,
      partyId: partyId ?? this.partyId,
      documentType: documentType,
      documentSeries: documentSeries,
      documentDate: documentDate,
      dueDate: dueDate,
      supplierInvoiceNumber: supplierInvoiceNumber,
      notes: notes,
      godownId: godownId,
      isGstFormal: isGstFormal,
      convertedFromId: convertedFromId,
      items: items,
    );
  }
}

@riverpod
double addPurchaseTotalTax(Ref ref, {String? billId}) {
  final form = ref.watch(addPurchaseFormProvider(billId: billId));
  return form.totalTax;
}

@riverpod
double addPurchaseGrandTotal(Ref ref, {String? billId}) {
  final form = ref.watch(addPurchaseFormProvider(billId: billId));
  return form.grandTotal;
}
