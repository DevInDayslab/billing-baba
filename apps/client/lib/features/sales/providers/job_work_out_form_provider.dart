import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/sales/application/job_work_service.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/presentation/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/providers/job_work_orders_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'job_work_out_form_provider.g.dart';

JobWorkOutFormState _initialJobWorkOutFormState() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return JobWorkOutFormState(
    invoiceDate: today,
    deliveryDate: today,
    finishedGoodUnit: 'NONE',
    rawMaterials: [
      JobWorkOutRawMaterialItem.empty(id: nextRawMaterialId()),
      JobWorkOutRawMaterialItem.empty(id: nextRawMaterialId()),
    ],
  );
}

@riverpod
class JobWorkOutFormNotifier extends _$JobWorkOutFormNotifier {
  @override
  JobWorkOutFormState build() => _initialJobWorkOutFormState();

  Map<String, String> _itemNameToId() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.name.trim(): item.id};
  }

  Map<String, String> _itemIdToName() {
    final items = ref.read(inventoryItemsProvider).value ?? [];
    return {for (final item in items) item.id: item.name};
  }

  void resetForm() {
    state = _initialJobWorkOutFormState();
  }

  Future<void> prepareNewForm() async {
    resetForm();
    final orders = await ref.read(jobWorkOrdersListProvider.future);
    final nextJobId = (orders.totalItems + 1).toString();
    state = state.copyWith(jobId: nextJobId);
  }

  Future<void> loadOrder(String orderId) async {
    try {
      final service = await ref.read(jobWorkServiceProvider.future);
      final loaded = await service.loadOrderFormWithItems(
        orderId,
        _itemIdToName(),
      );
      state = loaded;
    } catch (error) {
      state = state.copyWith(saveError: SalesErrorMapper.messageFor(error));
    }
  }

  void updateParty(String value) {
    state = state.copyWith(party: value, clearSaveError: true);
  }

  void updatePartyWithId({required String partyId, required String partyName}) {
    state = state.copyWith(
      partyId: partyId,
      party: partyName,
      clearSaveError: true,
    );
  }

  void updatePhoneNo(String value) {
    state = state.copyWith(phoneNo: value);
  }

  void updateJobId(String value) {
    state = state.copyWith(jobId: value);
  }

  void updateInvoiceDate(DateTime date) {
    state = state.copyWith(invoiceDate: date);
  }

  void updateDeliveryDate(DateTime date) {
    state = state.copyWith(deliveryDate: date);
  }

  void updateFinishedGoodName(String value) {
    state = state.copyWith(
      finishedGoodName: value,
      clearSaveError: true,
    );
  }

  void selectFinishedGood(SaleItemOption item) {
    state = state.copyWith(
      finishedGoodItemId: item.id,
      finishedGoodName: item.name,
      finishedGoodUnit: saleItemDefaultUnit(item),
      clearSaveError: true,
    );
  }

  void selectRawMaterialItem(int index, SaleItemOption item) {
    if (index < 0 || index >= state.rawMaterials.length) return;
    final materials = [...state.rawMaterials];
    materials[index] = materials[index].copyWith(
      itemId: item.id,
      itemName: item.name,
      unit: saleItemDefaultUnit(item),
      purchasePrice: item.purchasePrice,
    );
    state = state.copyWith(rawMaterials: materials, clearSaveError: true);
  }

  void updateFinishedGoodQty(double value) {
    state = state.copyWith(finishedGoodQty: value);
  }

  void updateFinishedGoodUnit(String value) {
    state = state.copyWith(finishedGoodUnit: value);
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
      attachedImages: state.attachedImages
          .where((image) => image.id != id)
          .toList(),
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

  void addRawMaterialRow() {
    state = state.copyWith(
      rawMaterials: [
        ...state.rawMaterials,
        JobWorkOutRawMaterialItem.empty(id: nextRawMaterialId()),
      ],
    );
  }

  void removeRawMaterialRow(int index) {
    if (index < 0 || index >= state.rawMaterials.length) return;
    final materials = [...state.rawMaterials]..removeAt(index);
    if (materials.isEmpty) {
      materials.add(JobWorkOutRawMaterialItem.empty(id: nextRawMaterialId()));
    }
    state = state.copyWith(rawMaterials: materials);
  }

  void updateRawMaterial(int index, JobWorkOutRawMaterialItem item) {
    if (index < 0 || index >= state.rawMaterials.length) return;
    final materials = [...state.rawMaterials];
    materials[index] = item;
    state = state.copyWith(rawMaterials: materials, clearSaveError: true);
  }

  void addAdditionalCost() {
    state = state.copyWith(
      additionalCosts: [
        ...state.additionalCosts,
        JobWorkOutAdditionalCost(
          id: nextAdditionalCostId(),
          label: SaleDropdownOptions.jobWorkAdditionalCostCharges.first,
        ),
      ],
    );
  }

  void removeAdditionalCost(String id) {
    state = state.copyWith(
      additionalCosts: state.additionalCosts
          .where((cost) => cost.id != id)
          .toList(),
    );
  }

  void updateAdditionalCost(String id, JobWorkOutAdditionalCost cost) {
    state = state.copyWith(
      additionalCosts: [
        for (final item in state.additionalCosts)
          if (item.id == id) cost else item,
      ],
    );
  }

  bool validate() {
    final isValid = state.isValid;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  Future<String?> save() async {
    if (!validate()) return 'Please fill required fields';

    state = state.copyWith(isSaving: true, clearSaveError: true);
    try {
      final service = await ref.read(jobWorkServiceProvider.future);
      await service.saveOrder(state, itemNameToId: _itemNameToId());
      ref.invalidate(jobWorkOrdersListProvider);
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
double jobWorkOutGrandTotal(Ref ref) {
  final form = ref.watch(jobWorkOutFormProvider);
  return form.grandTotal;
}
