import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'job_work_out_form_provider.g.dart';

JobWorkOutFormState _initialJobWorkOutFormState() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return JobWorkOutFormState(
    invoiceDate: today,
    deliveryDate: today,
    rawMaterials: [JobWorkOutRawMaterialItem.empty(id: nextRawMaterialId())],
  );
}

@riverpod
class JobWorkOutFormNotifier extends _$JobWorkOutFormNotifier {
  @override
  JobWorkOutFormState build() => _initialJobWorkOutFormState();

  void resetForm() {
    state = _initialJobWorkOutFormState();
  }

  void loadSaved(SavedJobWorkOut saved) {
    state = JobWorkOutFormState(
      party: saved.party,
      phoneNo: saved.phoneNo,
      jobId: saved.jobId,
      invoiceDate: saved.invoiceDate,
      deliveryDate: saved.deliveryDate,
      finishedGoodName: saved.finishedGoodName,
      finishedGoodQty: saved.finishedGoodQty,
      finishedGoodUnit: saved.finishedGoodUnit,
      rawMaterials: saved.rawMaterials.isEmpty
          ? [JobWorkOutRawMaterialItem.empty(id: nextRawMaterialId())]
          : List<JobWorkOutRawMaterialItem>.from(saved.rawMaterials),
      additionalCosts: List<JobWorkOutAdditionalCost>.from(
        saved.additionalCosts,
      ),
      description: saved.description,
      attachedImages: List<SaleFormAttachment>.from(saved.attachedImages),
      attachedDocuments: List<SaleFormAttachment>.from(saved.attachedDocuments),
    );
  }

  void updateParty(String value) {
    state = state.copyWith(party: value);
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
    state = state.copyWith(finishedGoodName: value);
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
    state = state.copyWith(rawMaterials: materials);
  }

  void addAdditionalCost() {
    state = state.copyWith(
      additionalCosts: [
        ...state.additionalCosts,
        JobWorkOutAdditionalCost(id: nextAdditionalCostId()),
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

  bool save() {
    if (!validate()) return false;
    final saved = SavedJobWorkOut.fromFormState(
      id: nextSavedJobWorkOutId(),
      form: state,
    );
    ref.read(savedJobWorkOutsProvider.notifier).addJobWorkOut(saved);
    resetForm();
    return true;
  }
}

@riverpod
class SavedJobWorkOutsNotifier extends _$SavedJobWorkOutsNotifier {
  @override
  List<SavedJobWorkOut> build() => [];

  void addJobWorkOut(SavedJobWorkOut jobWorkOut) {
    state = [jobWorkOut, ...state];
  }

  void removeJobWorkOut(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

@riverpod
double jobWorkOutGrandTotal(Ref ref) {
  final form = ref.watch(jobWorkOutFormProvider);
  return form.grandTotal;
}
