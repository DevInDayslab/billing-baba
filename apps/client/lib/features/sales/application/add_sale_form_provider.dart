import 'dart:async';

import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/core/documents/document_line_sync.dart';
import 'package:billing_baba/core/forms/transaction_form_validation.dart';
import 'package:billing_baba/core/forms/transaction_party_link.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/loyalty/application/loyalty_service.dart';
import 'package:billing_baba/features/loyalty/loyalty_points_calculator.dart';
import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/pricing/application/item_api_tier_prices_provider.dart';
import 'package:billing_baba/features/pricing/application/local_item_tier_prices_provider.dart';
import 'package:billing_baba/features/sales/application/invoice_tax_fallback_provider.dart';
import 'package:billing_baba/features/sales/application/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/add_sale_save_result.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
import 'package:billing_baba/features/settings/services/whatsapp_auto_notify.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_sale_form_provider.g.dart';

int _lineItemCounter = 0;

String _nextLineItemId() {
  _lineItemCounter += 1;
  return 'line_$_lineItemCounter';
}

AddSaleFormState _defaultFormState({String? documentId}) {
  final now = DateTime.now();
  return AddSaleFormState(
    documentId: documentId,
    invoiceNumber: 'Auto',
    invoiceDate: DateTime(now.year, now.month, now.day),
    invoiceTime: TimeOfDay.fromDateTime(now),
    items: [SaleLineItem.empty(id: _nextLineItemId())],
    isLoading: documentId != null,
  );
}

@riverpod
class AddSaleForm extends _$AddSaleForm {
  @override
  AddSaleFormState build({String sessionKey = 'default'}) {
    ref.watch(invoiceFallbackTaxPercentProvider);
    return _defaultFormState();
  }

  Future<void> loadDocument(String documentId) => _loadDocument(documentId);

  Future<void> _loadDocument(String documentId) async {
    if (state.documentId == documentId && !state.isLoading) return;

    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      await ref.read(localItemTierPricesProvider.notifier).ensureInitialized();
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleForm(documentId);
      final items = await _resolveItemNames(loaded.items);
      final attachments = await loadTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.sale.apiValue,
        entityId: documentId,
      );
      state = _withResolvedPartyTier(
        loaded.copyWith(
          items: items,
          attachedImages: attachments.images,
          attachedDocuments: attachments.documents,
          isLoading: false,
          showValidationErrors: kResetValidationOnLoad,
        ),
      );
      _scheduleHiddenLedgerBalanceRefresh();
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: SalesErrorMapper.messageFor(error),
      );
    }
  }

  Future<void> duplicateDocument(String sourceDocumentId) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      await ref.read(localItemTierPricesProvider.notifier).ensureInitialized();
      final service = await ref.read(salesServiceProvider.future);
      final loaded = await service.loadSaleForm(sourceDocumentId);
      final items = await _resolveItemNames(loaded.items);
      final now = DateTime.now();
      state = _withResolvedPartyTier(
        loaded.copyWith(
          clearDocumentId: true,
          invoiceNumber: 'Auto',
          invoiceNumberMode: InvoiceNumberMode.auto,
          invoiceDate: DateTime(now.year, now.month, now.day),
          invoiceTime: TimeOfDay.fromDateTime(now),
          items: _cloneLineItemsForDuplicate(items),
          attachedImages: const [],
          attachedDocuments: const [],
          clearAttachedSaleOrderIds: true,
          isLoading: false,
          isDirty: false,
          showValidationErrors: false,
        ),
      );
      _scheduleHiddenLedgerBalanceRefresh();
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: SalesErrorMapper.messageFor(error),
      );
    }
  }

  Future<void> attachSaleOrders(List<String> orderIds) async {
    if (orderIds.isEmpty) return;

    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      await ref.read(localItemTierPricesProvider.notifier).ensureInitialized();
      final service = await ref.read(salesServiceProvider.future);
      final loadedForms = <AddSaleFormState>[];
      for (final orderId in orderIds) {
        loadedForms.add(await service.loadSaleForm(orderId));
      }

      final mergedItems = <SaleLineItem>[];
      for (final form in loadedForms) {
        mergedItems.addAll(_cloneFilledLineItems(form.items));
      }

      final items = mergedItems.isEmpty
          ? [SaleLineItem.empty(id: _nextLineItemId())]
          : [
              ...await _resolveItemNames(mergedItems),
              SaleLineItem.empty(id: _nextLineItemId()),
            ];

      final first = loadedForms.first;
      final now = DateTime.now();
      state = _withResolvedPartyTier(
        first.copyWith(
          clearDocumentId: true,
          invoiceNumber: 'Auto',
          invoiceNumberMode: InvoiceNumberMode.auto,
          invoiceDate: DateTime(now.year, now.month, now.day),
          invoiceTime: TimeOfDay.fromDateTime(now),
          items: items,
          attachedImages: const [],
          attachedDocuments: const [],
          attachedSaleOrderIds: orderIds,
          isLoading: false,
          isDirty: false,
          showValidationErrors: false,
        ),
      );
      _scheduleHiddenLedgerBalanceRefresh();
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: SalesErrorMapper.messageFor(error),
      );
    }
  }

  List<SaleLineItem> _cloneLineItemsForDuplicate(List<SaleLineItem> items) {
    final cloned = _cloneFilledLineItems(items);
    if (cloned.isEmpty) {
      return [SaleLineItem.empty(id: _nextLineItemId())];
    }

    return [
      ...cloned,
      SaleLineItem.empty(id: _nextLineItemId()),
    ];
  }

  List<SaleLineItem> _cloneFilledLineItems(List<SaleLineItem> items) {
    final filled = items
        .where((line) => line.itemName.trim().isNotEmpty || line.qty > 0)
        .toList();

    return [
      for (final line in filled)
        SaleLineItem(
          id: _nextLineItemId(),
          itemId: line.itemId,
          itemName: line.itemName,
          serialNo: line.serialNo,
          description: line.description,
          batchNo: line.batchNo,
          modelNo: line.modelNo,
          expDate: line.expDate,
          mfgDate: line.mfgDate,
          mrp: line.mrp,
          size: line.size,
          qty: line.qty,
          unit: line.unit,
          pricePerUnit: line.pricePerUnit,
          priceIsTaxInclusive: line.priceIsTaxInclusive,
          discountPercent: line.discountPercent,
          taxPercent: line.taxPercent,
          isConfirmed: true,
          priceManuallyOverridden: line.priceManuallyOverridden,
        ),
    ];
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

  Future<PartyModel?> _resolveParty(String partyId) async {
    final fromList = ref
        .read(partiesListProvider)
        .where((party) => party.id == partyId)
        .firstOrNull;
    if (fromList != null) return fromList;

    return (await ref.read(
      partyPickerListProvider.future,
    )).where((party) => party.id == partyId).firstOrNull;
  }

  SaleLoyaltyResultDto? _resolveSaleLoyalty({
    required PartyModel? party,
    required SaleLoyaltyResultDto? apiLoyalty,
    required double invoiceTotal,
    required double loyaltyPointsUsed,
    required double loyaltyPointsAvailable,
  }) {
    if (!LoyaltyRules.isEligibleParty(party)) return apiLoyalty;

    if (apiLoyalty != null) return apiLoyalty;

    final earned = LoyaltyPointsCalculator.earnedForSpend(invoiceTotal);
    if (earned <= 0) return null;

    final available = loyaltyPointsAvailable - loyaltyPointsUsed + earned;
    return SaleLoyaltyResultDto(
      earnedPoints: earned.toString(),
      redeemedPoints: loyaltyPointsUsed.toStringAsFixed(0),
      pointsAvailable: available.toStringAsFixed(0),
    );
  }

  Future<void> _applyLoyaltyAfterSale({
    required String partyId,
    required SaleLoyaltyResultDto loyalty,
  }) async {
    applySaleLoyaltyToCache(
      ref,
      partyId: partyId,
      loyalty: loyalty,
    );
    ref.invalidate(partyLoyaltyBalanceProvider(partyId));
    unawaited(ref.read(partyLoyaltyBalanceProvider(partyId).future));
    await _refreshLoyaltyAvailable(partyId);
  }

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  String? _partyTierForId(String? partyId) {
    if (partyId == null || partyId.isEmpty) return null;
    return ref
        .read(partiesListProvider)
        .where((party) => party.id == partyId)
        .map((party) => party.defaultPriceTier)
        .firstOrNull;
  }

  AddSaleFormState _withResolvedPartyTier(AddSaleFormState form) {
    final tier = _partyTierForId(form.partyId);
    return form.copyWith(
      partyPriceTier: tier,
      clearPartyPriceTier: tier == null,
    );
  }

  void updateBillingName(String value) {
    final clearPartyId = shouldClearPartyIdOnNameEdit(
      newName: value,
      previousName: state.billingName,
      currentPartyId: state.partyId,
    );
    state = state.copyWith(
      billingName: value,
      isDirty: true,
      clearSaveError: true,
      clearPartyId: clearPartyId,
    );
    if (value.trim().isEmpty) {
      clearPartyLink();
    }
  }

  void updatePhone(String value) {
    final sanitized = Validators.sanitizePhoneInput(value);
    state = state.copyWith(phone: sanitized, isDirty: true, clearSaveError: true);
    _tryMatchPartyByPhone(sanitized);
  }

  void _tryMatchPartyByPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return;

    final parties = ref.read(partiesListProvider);
    final match = parties.where((party) {
      final partyDigits = party.phone.replaceAll(RegExp(r'\D'), '');
      return partyDigits == digits ||
          (partyDigits.length >= 10 &&
              digits.length >= 10 &&
              partyDigits.endsWith(digits.substring(digits.length - 10)));
    }).firstOrNull;

    if (match != null) {
      applyPartyDetails(match);
      unawaited(_refreshLoyaltyAvailable(match.id, party: match));
    }
  }

  double _cachedLoyaltyAvailable(String partyId) {
    return ref
            .read(partyLoyaltyBalanceCacheProvider)[partyId]
            ?.availablePoints ??
        0;
  }

  Future<void> _refreshLoyaltyAvailable(
    String partyId, {
    PartyModel? party,
  }) async {
    try {
      final resolvedParty =
          party ??
          ref
              .read(partiesListProvider)
              .where((item) => item.id == partyId)
              .firstOrNull ??
          (await ref.read(
            partyPickerListProvider.future,
          )).where((item) => item.id == partyId).firstOrNull;

      if (resolvedParty != null &&
          !LoyaltyRules.isEligibleParty(resolvedParty)) {
        if (!ref.mounted) return;
        state = state.copyWith(
          loyaltyPointsAvailable: 0,
          loyaltyPointsUsed: 0,
          loyaltyPointsEnabled: false,
        );
        return;
      }

      final cachedAvailable = _cachedLoyaltyAvailable(partyId);
      if (cachedAvailable > 0 && ref.mounted) {
        state = state.copyWith(loyaltyPointsAvailable: cachedAvailable);
      }

      final balance = await ref.read(
        partyLoyaltyBalanceProvider(partyId).future,
      );
      if (!ref.mounted) return;
      state = state.copyWith(loyaltyPointsAvailable: balance.availablePoints);
    } on Object {
      final cachedAvailable = _cachedLoyaltyAvailable(partyId);
      if (!ref.mounted) return;
      if (cachedAvailable > 0) {
        state = state.copyWith(loyaltyPointsAvailable: cachedAvailable);
      }
    }
  }

  void updateGstin(String value) {
    state = state.copyWith(gstin: value, isDirty: true);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, isDirty: true);
  }

  void updateBusinessName(String value) {
    state = state.copyWith(businessName: value, isDirty: true);
  }

  void updateParty({required String partyId, required String partyName}) {
    final parties = ref.read(partiesListProvider);
    final party = parties.where((item) => item.id == partyId).firstOrNull;
    if (party != null) {
      applyPartyDetails(party);
      unawaited(_refreshLoyaltyAvailable(party.id, party: party));
      return;
    }

    state = state.copyWith(
      partyId: partyId,
      billingName: partyName,
      clearPartyPriceTier: true,
      loyaltyPointsAvailable: _cachedLoyaltyAvailable(partyId),
      loyaltyPointsUsed: 0,
      loyaltyPointsEnabled: false,
      isDirty: true,
      clearSaveError: true,
    );
    unawaited(_repriceLineItemsForPartyTierAsync());
    unawaited(_refreshLoyaltyAvailable(partyId));
    unawaited(_refreshHiddenLedgerBalance(partyId));
  }

  void applyPartyDetails(PartyModel party) {
    final canViewHiddenLedger =
        ref.read(permissionServiceProvider).canViewHiddenLedger;
    final loyaltyAvailable = LoyaltyRules.isEligibleParty(party)
        ? _cachedLoyaltyAvailable(party.id)
        : 0.0;

    state = state.copyWith(
      partyId: party.id,
      billingName: party.name,
      phone: Validators.normalizeIndianPhone(party.phone) ?? '',
      billingAddress: party.billingAddress.isNotEmpty
          ? party.billingAddress
          : party.addressLine,
      shippingAddress: party.shippingAddress.isNotEmpty
          ? party.shippingAddress
          : party.shippingAddressLine,
      stateOfSupply: party.state.isNotEmpty ? party.state : state.stateOfSupply,
      gstin: party.gstin,
      email: party.email,
      businessName: party.additionalField1.isNotEmpty
          ? party.additionalField1
          : party.name,
      creditLimit: PartyModel.displayCreditLimit(
        hasCustomCreditLimit: party.hasCustomCreditLimit,
        creditLimit: party.creditLimit,
      ),
      outstanding: PartyModel.displayOutstanding(party.balance),
      partyPriceTier: party.defaultPriceTier,
      loyaltyPointsAvailable: loyaltyAvailable,
      loyaltyPointsUsed: 0,
      loyaltyPointsEnabled: false,
      hiddenLedgerBalance:
          canViewHiddenLedger ? party.unrecoveredAmount : 0,
      clearHiddenLedgerBalance: !canViewHiddenLedger,
      isDirty: true,
      clearSaveError: true,
    );
    unawaited(_repriceLineItemsForPartyTierAsync());
    unawaited(_refreshLoyaltyAvailable(party.id, party: party));
    unawaited(_refreshHiddenLedgerBalance(party.id));
  }

  void _scheduleHiddenLedgerBalanceRefresh() {
    final partyId = state.partyId;
    if (partyId == null || partyId.isEmpty) return;
    unawaited(_refreshHiddenLedgerBalance(partyId));
  }

  Future<void> _refreshHiddenLedgerBalance(String partyId) async {
    if (!ref.read(permissionServiceProvider).canViewHiddenLedger) {
      state = state.copyWith(clearHiddenLedgerBalance: true);
      return;
    }

    try {
      final service = await ref.read(hiddenLedgerServiceProvider.future);
      final summary = await service.getPartySummary(partyId);
      if (!ref.mounted) return;
      state = state.copyWith(hiddenLedgerBalance: summary.hiddenLedgerBalance);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(clearHiddenLedgerBalance: true);
    }
  }

  Future<void> _repriceLineItemsForPartyTierAsync() async {
    await ref.read(localItemTierPricesProvider.notifier).ensureInitialized();
    final inventory = ref.read(inventoryItemsProvider).value ?? [];
    if (inventory.isNotEmpty) {
      await ref
          .read(itemApiTierPricesProvider.notifier)
          .preloadForItemIds(inventory.map((item) => item.id));
    }
    _repriceLineItemsForPartyTier();
  }

  Future<void> _repriceLineItemsForPartyTier() async {
    final partyTier = state.partyPriceTier;
    final fallback = await readInvoiceFallbackTaxPercent(ref);
    final localStore = ref.read(localItemTierPricesProvider);
    final apiStore = ref.read(itemApiTierPricesProvider);
    final inventory = ref.read(inventoryItemsProvider).value ?? [];
    final inventoryById = {for (final item in inventory) item.id: item};

    final items = state.items.map((line) {
      if (line.priceManuallyOverridden || line.itemId == null) return line;

      final inventoryItem = inventoryById[line.itemId];
      if (inventoryItem == null) return line;

      final catalogItem = saleItemOptionFromInventory(
        inventoryItem,
        tierPrices: mergedTierPricesForItem(
          apiStore: apiStore,
          localStore: localStore,
          itemId: line.itemId!,
        ),
      );
      return applyCatalogItemToLine(
        line,
        catalogItem,
        partyPriceTier: partyTier,
        resetQtyWhenEmpty: false,
        fallbackTaxPercent: fallback,
      );
    }).toList();

    state = state.copyWith(items: items);
  }

  void clearPartyLink() {
    state = state.copyWith(
      clearPartyId: true,
      phone: '',
      billingAddress: '',
      shippingAddress: '',
      gstin: '',
      email: '',
      businessName: '',
      creditLimit: '',
      outstanding: '',
      clearPartyPriceTier: true,
      loyaltyPointsAvailable: 0,
      loyaltyPointsUsed: 0,
      loyaltyPointsEnabled: false,
      isDirty: true,
      clearHiddenLedgerBalance: true,
    );
    unawaited(_repriceLineItemsForPartyTierAsync());
  }

  void updateAddresses({String? billing, String? shipping}) {
    state = state.copyWith(
      billingAddress: billing ?? state.billingAddress,
      shippingAddress: shipping ?? state.shippingAddress,
      isDirty: true,
    );
  }

  void toggleSaleType(SaleType type) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(const SalePaymentEntry(type: 'Cash'));
    }

    state = state.copyWith(
      saleType: type,
      dueDate: type == SaleType.cash ? null : state.dueDate,
      receivedEnabled: type == SaleType.credit && state.receivedEnabled,
      payments: type == SaleType.cash
          ? [payments.first.copyWith(type: 'Cash', amount: state.invoiceTotal)]
          : payments,
      isDirty: true,
    );
  }

  void updateInvoiceNumber(String value) {
    state = state.copyWith(invoiceNumber: value, isDirty: true);
  }

  void toggleInvoiceNumberMode(InvoiceNumberMode mode) {
    if (mode == InvoiceNumberMode.auto) {
      state = state.copyWith(
        invoiceNumberMode: mode,
        invoiceNumber: 'Auto',
        isDirty: true,
      );
    } else {
      state = state.copyWith(invoiceNumberMode: mode, isDirty: true);
    }
  }

  void updateInvoiceDate(DateTime date) {
    state = state.copyWith(invoiceDate: date, isDirty: true);
  }

  void updateDueDate(DateTime? date) {
    state = state.copyWith(dueDate: date, isDirty: true);
  }

  void updateInvoiceTime(TimeOfDay time) {
    state = state.copyWith(invoiceTime: time, isDirty: true);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value, isDirty: true);
  }

  void updateEWayBillNo(String value) {
    state = state.copyWith(eWayBillNo: value, isDirty: true);
  }

  void updateTermsTitle(String value) {
    state = state.copyWith(termsTitle: value, isDirty: true);
  }

  void updateTermsText(String value) {
    state = state.copyWith(termsText: value, isDirty: true);
  }

  void updateGodown(String value, {String? godownId}) {
    state = state.copyWith(
      godown: value,
      godownId: godownId,
      isDirty: true,
    );
  }

  void updateTaxOption(String value) {
    state = state.copyWith(
      taxOption: value,
      items: applyBillTaxOptionToSaleItems(state.items, value),
      isDirty: true,
      clearSaveError: true,
    );
  }

  void addLineItem() {
    final items = [...state.items, SaleLineItem.empty(id: _nextLineItemId())];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(SaleLineItem.empty(id: _nextLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, SaleLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final previous = state.items[index];
    final items = [...state.items];
    items[index] = item;
    final clearBillTax =
        item.taxPercent > 0 && isBillLevelTaxActive(state.taxOption);
    state = state.copyWith(
      items: items,
      taxOption: clearBillTax ? 'NONE' : state.taxOption,
      isDirty: true,
      clearSaveError: true,
    );
    rememberInvoiceLineTaxIfChanged(ref, previous, item);
  }

  Future<void> selectCatalogItem(int index, SaleItemOption catalogItem) async {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    final applied = (await applyCatalogItemWithInvoiceTaxFallback(
      ref,
      line,
      catalogItem,
      partyPriceTier: state.partyPriceTier,
    )).copyWith(mrp: catalogItem.salePrice);
    final items = selectCatalogItemOnSaleLines(
      items: state.items,
      targetIndex: index,
      appliedLine: applied,
      nextLineId: _nextLineItemId,
    );
    state = state.copyWith(items: items, isDirty: true, clearSaveError: true);
  }

  void confirmLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = items[index].copyWith(isConfirmed: true);
    if (index == items.length - 1) {
      items.add(SaleLineItem.empty(id: _nextLineItemId()));
    }
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

  void updateReceivedAmount(double value) {
    state = state.copyWith(receivedAmount: value, isDirty: true);
  }

  void toggleReceived({required bool enabled}) {
    state = state.copyWith(
      receivedEnabled: enabled,
      receivedAmount: enabled ? state.receivedAmount : 0,
      isDirty: true,
    );
  }

  void toggleLoyaltyPoints({required bool enabled}) {
    state = state.copyWith(
      loyaltyPointsEnabled: enabled,
      loyaltyPointsUsed: enabled ? state.loyaltyPointsUsed : 0,
      isDirty: true,
    );
  }

  void updateLoyaltyPointsUsed(double value) {
    final max = state.maxRedeemablePoints;
    final clamped = value.clamp(0, max).toDouble();
    state = state.copyWith(
      loyaltyPointsUsed: clamped,
      loyaltyPointsEnabled: clamped > 0,
      isDirty: true,
    );
  }

  void useMaxLoyaltyPoints() {
    final max = state.maxRedeemablePoints;
    state = state.copyWith(
      loyaltyPointsUsed: max,
      loyaltyPointsEnabled: max > 0,
      isDirty: true,
    );
  }

  bool validate({bool finalize = false}) {
    final hasLines = state.hasValidLineItems;
    final hasParty = state.partyId != null && state.partyId!.isNotEmpty;
    final hasPhone = state.hasValidPhone;

    final isValid = hasLines && hasPhone && (!finalize || hasParty);
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  String? _validationError({bool finalize = false}) {
    return buildTransactionValidationError(
      hasValidLineItems: state.hasValidLineItems,
      hasValidPhone: state.hasValidPhone,
      hasValidParty: state.partyId != null && state.partyId!.isNotEmpty,
      requirePhone: true,
      requireParty: finalize,
    );
  }

  Future<String?> saveDraft() async {
    if (state.isSaving) return null;
    if (!validate()) return _validationError();

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.saveDraft(
        state,
        itemNameToId: _itemNameToId(),
      );
      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.sale.apiValue,
        entityId: document.id,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      state = state.copyWith(
        documentId: document.id,
        items: bindSaleServerLineIds(state.items, document.lines),
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
        isSaving: false,
        isDirty: false,
      );
      await _refreshAfterSaleMutation();
      return null;
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }

  Future<void> _refreshAfterSaleMutation() async {
    final itemIds = state.items
        .map((line) => line.itemId)
        .whereType<String>()
        .where((id) => id.isNotEmpty);
    await refreshAfterSaleMutation(
      ref,
      context: (
        partyId: state.partyId,
        itemIds: itemIds,
      ),
    );
  }

  Future<AddSaleSaveResult> saveInvoice({
    bool finalize = true,
    String? shortPaymentHandling,
    double? shortfallAmount,
    double hiddenLedgerRecoveryAmount = 0,
  }) async {
    if (state.isSaving) return const AddSaleSaveResult();

    if (!validate(finalize: finalize)) {
      return AddSaleSaveResult(error: _validationError(finalize: finalize));
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(salesServiceProvider.future);
      final partyId = state.partyId;

      var earnedLoyaltyPoints = 0;
      var pointsAvailable = 0.0;
      var loyaltyPointsUsedForExpense = 0.0;
      if (finalize) {
        final invoiceTotal = state.invoiceTotal;
        final loyaltyPointsUsed = state.loyaltyPointsUsed;
        loyaltyPointsUsedForExpense = loyaltyPointsUsed;
        final loyaltyPointsAvailable = state.loyaltyPointsAvailable;
        final party = partyId != null ? await _resolveParty(partyId) : null;

        final result = await service.createAndFinalizeSale(
          state,
          partyId: partyId,
          itemNameToId: _itemNameToId(),
          godownId: state.godownId,
          loyaltyPointsRedeemed: loyaltyPointsUsed,
          shortPaymentHandling: shortPaymentHandling,
          shortfallAmount: shortfallAmount,
        );

        if (partyId != null &&
            partyId.isNotEmpty &&
            hiddenLedgerRecoveryAmount > 0) {
          final hiddenLedgerService =
              await ref.read(hiddenLedgerServiceProvider.future);
          await hiddenLedgerService.recoverFromSale(
            partyId: partyId,
            saleId: result.document.id,
            amount: hiddenLedgerRecoveryAmount,
          );
          ref.invalidate(partyHiddenLedgerSummaryProvider(partyId));
        }

        final loyalty = _resolveSaleLoyalty(
          party: party,
          apiLoyalty: result.loyalty,
          invoiceTotal: invoiceTotal,
          loyaltyPointsUsed: loyaltyPointsUsed,
          loyaltyPointsAvailable: loyaltyPointsAvailable,
        );

        earnedLoyaltyPoints =
            loyalty?.earnedPointsInt ?? result.earnedLoyaltyPoints;
        pointsAvailable =
            loyalty?.availablePoints ?? result.loyalty?.availablePoints ?? 0;

        final synced = await syncTransactionAttachments(
          ref,
          entityType: DocumentAttachmentEntityType.sale.apiValue,
          entityId: result.document.id,
          images: state.attachedImages,
          documents: state.attachedDocuments,
        );

        state = state.copyWith(
          documentId: result.document.id,
          items: bindSaleServerLineIds(state.items, result.document.lines),
          attachedImages: synced?.images ?? state.attachedImages,
          attachedDocuments: synced?.documents ?? state.attachedDocuments,
          isSaving: false,
          isDirty: false,
        );

        if (partyId != null && partyId.isNotEmpty && loyalty != null) {
          await _applyLoyaltyAfterSale(partyId: partyId, loyalty: loyalty);
        }

        // ignore: unawaited_futures
        WhatsAppAutoNotify.afterSaleFinalize(
          ref,
          documentId: result.document.id,
        );
      } else {
        final document = await service.saveDraft(
          state,
          itemNameToId: _itemNameToId(),
        );
        final synced = await syncTransactionAttachments(
          ref,
          entityType: DocumentAttachmentEntityType.sale.apiValue,
          entityId: document.id,
          images: state.attachedImages,
          documents: state.attachedDocuments,
        );
        state = state.copyWith(
          documentId: document.id,
          items: bindSaleServerLineIds(state.items, document.lines),
          attachedImages: synced?.images ?? state.attachedImages,
          attachedDocuments: synced?.documents ?? state.attachedDocuments,
          isSaving: false,
          isDirty: false,
        );
      }

      await _refreshAfterSaleMutation();
      if (finalize && loyaltyPointsUsedForExpense > 0) {
        refreshAfterExpense(
          ref,
          context: (partyId: state.partyId, itemIds: const []),
        );
      }
      if (state.attachedSaleOrderIds.isNotEmpty) {
        ref.invalidate(saleOrdersProvider);
      }
      ref.invalidateSelf();
      return AddSaleSaveResult(
        earnedLoyaltyPoints: earnedLoyaltyPoints,
        pointsAvailable: pointsAvailable,
      );
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return AddSaleSaveResult(error: message);
    }
  }
}

@riverpod
double addSaleSubtotal(Ref ref, {String sessionKey = 'default'}) {
  final form = ref.watch(addSaleFormProvider(sessionKey: sessionKey));
  return form.subtotal;
}

@riverpod
double addSaleTotalTax(Ref ref, {String sessionKey = 'default'}) {
  final form = ref.watch(addSaleFormProvider(sessionKey: sessionKey));
  return form.totalTax;
}

@riverpod
double addSaleGrandTotal(Ref ref, {String sessionKey = 'default'}) {
  final form = ref.watch(addSaleFormProvider(sessionKey: sessionKey));
  return form.invoiceTotal;
}
