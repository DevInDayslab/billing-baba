import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';

class JobWorkOutRawMaterialItem {
  const JobWorkOutRawMaterialItem({
    required this.id,
    this.itemName = '',
    this.qty = 0,
    this.unit = 'NONE',
    this.purchasePrice = 0,
  });

  factory JobWorkOutRawMaterialItem.empty({required String id}) {
    return JobWorkOutRawMaterialItem(id: id);
  }

  final String id;
  final String itemName;
  final double qty;
  final String unit;
  final double purchasePrice;

  double get estimatedCost => qty * purchasePrice;

  JobWorkOutRawMaterialItem copyWith({
    String? itemName,
    double? qty,
    String? unit,
    double? purchasePrice,
  }) {
    return JobWorkOutRawMaterialItem(
      id: id,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }
}

class JobWorkOutAdditionalCost {
  const JobWorkOutAdditionalCost({
    required this.id,
    this.label = '',
    this.amount = 0,
  });

  final String id;
  final String label;
  final double amount;

  JobWorkOutAdditionalCost copyWith({String? label, double? amount}) {
    return JobWorkOutAdditionalCost(
      id: id,
      label: label ?? this.label,
      amount: amount ?? this.amount,
    );
  }
}

class JobWorkOutFormState {
  const JobWorkOutFormState({
    this.party = '',
    this.phoneNo = '',
    this.jobId = '',
    this.invoiceDate,
    this.deliveryDate,
    this.finishedGoodName = '',
    this.finishedGoodQty = 1,
    this.finishedGoodUnit = 'PCS',
    this.rawMaterials = const [],
    this.additionalCosts = const [],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.showValidationErrors = false,
  });

  final String party;
  final String phoneNo;
  final String jobId;
  final DateTime? invoiceDate;
  final DateTime? deliveryDate;
  final String finishedGoodName;
  final double finishedGoodQty;
  final String finishedGoodUnit;
  final List<JobWorkOutRawMaterialItem> rawMaterials;
  final List<JobWorkOutAdditionalCost> additionalCosts;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool showValidationErrors;

  double get rawMaterialsTotal =>
      rawMaterials.fold<double>(0, (sum, item) => sum + item.estimatedCost);

  double get additionalCostsTotal =>
      additionalCosts.fold<double>(0, (sum, cost) => sum + cost.amount);

  double get grandTotal => rawMaterialsTotal + additionalCostsTotal;

  bool get partyHasError => showValidationErrors && party.trim().isEmpty;

  bool get finishedGoodHasError =>
      showValidationErrors && finishedGoodName.trim().isEmpty;

  bool get isValid =>
      party.trim().isNotEmpty && finishedGoodName.trim().isNotEmpty;

  JobWorkOutFormState copyWith({
    String? party,
    String? phoneNo,
    String? jobId,
    DateTime? invoiceDate,
    DateTime? deliveryDate,
    String? finishedGoodName,
    double? finishedGoodQty,
    String? finishedGoodUnit,
    List<JobWorkOutRawMaterialItem>? rawMaterials,
    List<JobWorkOutAdditionalCost>? additionalCosts,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? showValidationErrors,
  }) {
    return JobWorkOutFormState(
      party: party ?? this.party,
      phoneNo: phoneNo ?? this.phoneNo,
      jobId: jobId ?? this.jobId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      finishedGoodName: finishedGoodName ?? this.finishedGoodName,
      finishedGoodQty: finishedGoodQty ?? this.finishedGoodQty,
      finishedGoodUnit: finishedGoodUnit ?? this.finishedGoodUnit,
      rawMaterials: rawMaterials ?? this.rawMaterials,
      additionalCosts: additionalCosts ?? this.additionalCosts,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      showValidationErrors:
          showValidationErrors ?? this.showValidationErrors,
    );
  }
}

enum JobWorkOutStatus { open, closed }

class SavedJobWorkOut {
  const SavedJobWorkOut({
    required this.id,
    required this.party,
    required this.phoneNo,
    required this.jobId,
    required this.invoiceDate,
    required this.deliveryDate,
    required this.finishedGoodName,
    required this.finishedGoodQty,
    required this.finishedGoodUnit,
    required this.rawMaterials,
    required this.additionalCosts,
    required this.description,
    required this.attachedImages,
    required this.attachedDocuments,
    required this.grandTotal,
    required this.status,
    required this.savedAt,
  });

  factory SavedJobWorkOut.fromFormState({
    required String id,
    required JobWorkOutFormState form,
  }) {
    return SavedJobWorkOut(
      id: id,
      party: form.party,
      phoneNo: form.phoneNo,
      jobId: form.jobId,
      invoiceDate: form.invoiceDate,
      deliveryDate: form.deliveryDate,
      finishedGoodName: form.finishedGoodName,
      finishedGoodQty: form.finishedGoodQty,
      finishedGoodUnit: form.finishedGoodUnit,
      rawMaterials: List<JobWorkOutRawMaterialItem>.from(form.rawMaterials),
      additionalCosts:
          List<JobWorkOutAdditionalCost>.from(form.additionalCosts),
      description: form.description,
      attachedImages: List<SaleFormAttachment>.from(form.attachedImages),
      attachedDocuments: List<SaleFormAttachment>.from(form.attachedDocuments),
      grandTotal: form.grandTotal,
      status: JobWorkOutStatus.open,
      savedAt: DateTime.now(),
    );
  }

  final String id;
  final String party;
  final String phoneNo;
  final String jobId;
  final DateTime? invoiceDate;
  final DateTime? deliveryDate;
  final String finishedGoodName;
  final double finishedGoodQty;
  final String finishedGoodUnit;
  final List<JobWorkOutRawMaterialItem> rawMaterials;
  final List<JobWorkOutAdditionalCost> additionalCosts;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final double grandTotal;
  final JobWorkOutStatus status;
  final DateTime savedAt;
}

int _savedJobWorkOutCounter = 0;

String nextSavedJobWorkOutId() {
  _savedJobWorkOutCounter += 1;
  return 'job_work_out_$_savedJobWorkOutCounter';
}

int _rawMaterialCounter = 0;

String nextRawMaterialId() {
  _rawMaterialCounter += 1;
  return 'raw_material_$_rawMaterialCounter';
}

int _additionalCostCounter = 0;

String nextAdditionalCostId() {
  _additionalCostCounter += 1;
  return 'additional_cost_$_additionalCostCounter';
}
