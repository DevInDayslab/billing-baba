import 'package:billing_baba/features/sales/models/dto/job_work_order_dto.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';

class JobWorkOrderMapper {
  static JobWorkOutStatus _mapStatus(String status) => switch (status) {
    'closed' => JobWorkOutStatus.closed,
    'cancelled' => JobWorkOutStatus.cancelled,
    _ => JobWorkOutStatus.open,
  };

  static JobWorkOrderListItem toListItem(
    JobWorkOrderDto dto, {
    String partyName = '',
  }) {
    final status = _mapStatus(dto.status);
    final closedAt = status == JobWorkOutStatus.closed
        ? DateTime.tryParse(dto.updatedAt)
        : null;

    return JobWorkOrderListItem(
      id: dto.id,
      party: partyName,
      jobId: dto.jobNumber ?? dto.id.substring(0, 8),
      invoiceDate: DateTime.tryParse(dto.orderDate),
      deliveryDate: dto.deliveryDate != null
          ? DateTime.tryParse(dto.deliveryDate!)
          : null,
      status: status,
      grandTotal: double.tryParse(dto.grandTotal) ?? 0,
      closedAt: closedAt,
      convertedInvoiceNumber: _parseConvertedInvoiceNumber(dto.notes),
    );
  }

  static String? _parseConvertedInvoiceNumber(String? notes) {
    if (notes == null || notes.isEmpty) return null;
    final match = RegExp(
      r'converted[_\s-]*to[_\s-]*invoice[_\s#:]*(\d+)',
      caseSensitive: false,
    ).firstMatch(notes);
    return match?.group(1);
  }

  static JobWorkOutFormState toFormState(
    JobWorkOrderDto dto, {
    String partyName = '',
    Map<String, String> itemNames = const {},
  }) {
    final rawMaterials = dto.rawMaterials.isEmpty
        ? [JobWorkOutRawMaterialItem.empty(id: nextRawMaterialId())]
        : [
            for (final material in dto.rawMaterials)
              JobWorkOutRawMaterialItem(
                id: material.id,
                itemId: material.itemId,
                itemName: itemNames[material.itemId] ?? '',
                qty: double.tryParse(material.quantity) ?? 0,
                unit: material.unit,
                purchasePrice: double.tryParse(material.purchasePrice) ?? 0,
              ),
          ];

    final additionalCosts = [
      for (final cost in dto.additionalCosts)
        JobWorkOutAdditionalCost(
          id: cost.id,
          label: cost.label,
          amount: double.tryParse(cost.amount) ?? 0,
        ),
    ];

    return JobWorkOutFormState(
      orderId: dto.id,
      partyId: dto.partyId,
      party: partyName,
      jobId: dto.jobNumber ?? '',
      invoiceDate: DateTime.tryParse(dto.orderDate),
      deliveryDate: dto.deliveryDate != null
          ? DateTime.tryParse(dto.deliveryDate!)
          : null,
      finishedGoodName: dto.finishedGoodName,
      finishedGoodQty: double.tryParse(dto.finishedGoodQuantity) ?? 1,
      finishedGoodUnit: dto.finishedGoodUnit,
      rawMaterials: rawMaterials,
      additionalCosts: additionalCosts,
      description: dto.notes ?? '',
    );
  }
}
