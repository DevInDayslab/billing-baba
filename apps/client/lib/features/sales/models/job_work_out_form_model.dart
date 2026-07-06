import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';

class JobWorkOutRawMaterialItem {
  const JobWorkOutRawMaterialItem({
    required this.id,
    this.itemId,
    this.itemName = '',
    this.qty = 0,
    this.unit = 'NONE',
    this.purchasePrice = 0,
  });

  factory JobWorkOutRawMaterialItem.empty({required String id}) {
    return JobWorkOutRawMaterialItem(id: id);
  }

  final String id;
  final String? itemId;
  final String itemName;
  final double qty;
  final String unit;
  final double purchasePrice;

  double get estimatedCost => qty * purchasePrice;

  JobWorkOutRawMaterialItem copyWith({
    String? itemId,
    String? itemName,
    double? qty,
    String? unit,
    double? purchasePrice,
  }) {
    return JobWorkOutRawMaterialItem(
      id: id,
      itemId: itemId ?? this.itemId,
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
    this.orderId,
    this.partyId,
    this.party = '',
    this.phoneNo = '',
    this.jobId = '',
    this.invoiceDate,
    this.deliveryDate,
    this.finishedGoodName = '',
    this.finishedGoodItemId,
    this.finishedGoodQty = 1,
    this.finishedGoodUnit = 'PCS',
    this.rawMaterials = const [],
    this.additionalCosts = const [],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.showValidationErrors = false,
    this.isSaving = false,
    this.saveError,
  });

  final String? orderId;
  final String? partyId;
  final String party;
  final String phoneNo;
  final String jobId;
  final DateTime? invoiceDate;
  final DateTime? deliveryDate;
  final String finishedGoodName;
  final String? finishedGoodItemId;
  final double finishedGoodQty;
  final String finishedGoodUnit;
  final List<JobWorkOutRawMaterialItem> rawMaterials;
  final List<JobWorkOutAdditionalCost> additionalCosts;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool showValidationErrors;
  final bool isSaving;
  final String? saveError;

  double get rawMaterialsTotal =>
      rawMaterials.fold<double>(0, (sum, item) => sum + item.estimatedCost);

  double get additionalCostsTotal =>
      additionalCosts.fold<double>(0, (sum, cost) => sum + cost.amount);

  double get grandTotal => rawMaterialsTotal + additionalCostsTotal;

  bool get partyHasError => showValidationErrors && party.trim().isEmpty;

  bool get finishedGoodHasError =>
      showValidationErrors && finishedGoodName.trim().isEmpty;

  bool get isValid =>
      party.trim().isNotEmpty &&
      partyId != null &&
      partyId!.isNotEmpty &&
      finishedGoodName.trim().isNotEmpty;

  JobWorkOutFormState copyWith({
    String? orderId,
    String? partyId,
    String? party,
    String? phoneNo,
    String? jobId,
    DateTime? invoiceDate,
    DateTime? deliveryDate,
    String? finishedGoodName,
    String? finishedGoodItemId,
    double? finishedGoodQty,
    String? finishedGoodUnit,
    List<JobWorkOutRawMaterialItem>? rawMaterials,
    List<JobWorkOutAdditionalCost>? additionalCosts,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? showValidationErrors,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return JobWorkOutFormState(
      orderId: orderId ?? this.orderId,
      partyId: partyId ?? this.partyId,
      party: party ?? this.party,
      phoneNo: phoneNo ?? this.phoneNo,
      jobId: jobId ?? this.jobId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      finishedGoodName: finishedGoodName ?? this.finishedGoodName,
      finishedGoodItemId: finishedGoodItemId ?? this.finishedGoodItemId,
      finishedGoodQty: finishedGoodQty ?? this.finishedGoodQty,
      finishedGoodUnit: finishedGoodUnit ?? this.finishedGoodUnit,
      rawMaterials: rawMaterials ?? this.rawMaterials,
      additionalCosts: additionalCosts ?? this.additionalCosts,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}

enum JobWorkOutStatus { open, closed, cancelled }

class JobWorkOrderListItem {
  const JobWorkOrderListItem({
    required this.id,
    required this.party,
    required this.jobId,
    required this.invoiceDate,
    required this.deliveryDate,
    required this.status,
    required this.grandTotal,
  });

  final String id;
  final String party;
  final String jobId;
  final DateTime? invoiceDate;
  final DateTime? deliveryDate;
  final JobWorkOutStatus status;
  final double grandTotal;
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
