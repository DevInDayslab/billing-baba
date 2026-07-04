import 'package:billing_baba/features/purchases/models/dto/purchase_fa_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_fa_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';

class PurchaseFaMapper {
  static PurchaseFaModel toModel(
    PurchaseFaBatchListDto dto, {
    String partyName = '',
  }) {
    final amount = double.tryParse(dto.totalAmount) ?? 0;
    final balanceDue = double.tryParse(dto.balanceDue) ?? 0;
    final purchaseDate =
        DateTime.tryParse(dto.purchaseDate) ?? DateTime.now();
    final dueDate = dto.dueDate != null
        ? DateTime.tryParse(dto.dueDate!) ?? purchaseDate
        : purchaseDate;

    return PurchaseFaModel(
      id: dto.id,
      batchId: dto.id,
      partyId: dto.partyId,
      invoiceNo: dto.referenceNumber ?? dto.id.substring(0, 8),
      date: purchaseDate,
      partyName: partyName.isNotEmpty ? partyName : dto.partyName,
      paymentType: PurchasePaymentModes.toUi(dto.paymentMode ?? 'cash'),
      status: _mapStatus(dto.status),
      amount: amount,
      balanceDue: balanceDue,
      dueDate: dueDate,
    );
  }

  static AddPurchaseFaFormState toFormState(PurchaseFaBatchDto dto) {
    final purchaseDate =
        DateTime.tryParse(dto.purchaseDate) ?? DateTime.now();
    final dueDate = dto.dueDate != null
        ? DateTime.tryParse(dto.dueDate!)
        : null;
    final totalAmount = double.tryParse(dto.totalAmount) ?? 0;
    final balanceDue = double.tryParse(dto.balanceDue) ?? 0;
    final paidAmount =
        (totalAmount - balanceDue).clamp(0, totalAmount).toDouble();

    final items = dto.assets.isEmpty
        ? [FixedAssetLineItem.empty(id: 'line_1')]
        : dto.assets
              .map(
                (asset) => FixedAssetLineItem(
                  id: asset.id,
                  assetName: asset.assetName,
                  description: asset.description ?? '',
                  qty: double.tryParse(asset.qty) ?? 1,
                  pricePerUnit: double.tryParse(asset.purchasePrice) ?? 0,
                  taxPercent: double.tryParse(asset.taxRate) ?? 0,
                ),
              )
              .toList();

    return AddPurchaseFaFormState(
      batchId: dto.id,
      partyId: dto.partyId,
      party: dto.partyName,
      billingName: dto.partyName,
      eWayBillNo: '',
      billNumber: dto.referenceNumber ?? '',
      billDate: DateTime(
        purchaseDate.year,
        purchaseDate.month,
        purchaseDate.day,
      ),
      billTime: TimeOfDay.fromDateTime(purchaseDate),
      dueDate: dueDate != null
          ? DateTime(dueDate.year, dueDate.month, dueDate.day)
          : null,
      description: dto.description ?? '',
      termsNotes: dto.notes ?? '',
      items: items,
      payments: [
        SalePaymentEntry(
          type: PurchasePaymentModes.toUi(dto.paymentMode ?? 'cash'),
          amount: paidAmount,
        ),
      ],
    );
  }

  static CreatePurchaseFaRequest toCreateRequest(AddPurchaseFaFormState form) {
    return CreatePurchaseFaRequest(
      partyId: form.partyId!,
      referenceNumber: form.billNumber.trim().isEmpty
          ? null
          : form.billNumber.trim(),
      purchaseDate: _formatDate(form.billDate ?? DateTime.now()),
      dueDate: form.dueDate != null ? _formatDate(form.dueDate!) : null,
      paymentMode: PurchasePaymentModes.toApi(form.paymentType),
      status: _statusApiValue(form),
      notes: form.termsNotes.trim().isEmpty ? null : form.termsNotes.trim(),
      description: form.description.trim().isEmpty
          ? null
          : form.description.trim(),
      subtotal: form.subtotal.toStringAsFixed(4),
      taxAmount: form.totalTax.toStringAsFixed(4),
      totalAmount: form.grandTotal.toStringAsFixed(4),
      balanceDue: form.balanceAmount.toStringAsFixed(4),
      assets: _assetRequests(form),
    );
  }

  static UpdatePurchaseFaRequest toUpdateRequest(AddPurchaseFaFormState form) {
    return UpdatePurchaseFaRequest(
      partyId: form.partyId,
      referenceNumber: form.billNumber.trim().isEmpty
          ? null
          : form.billNumber.trim(),
      purchaseDate: form.billDate != null
          ? _formatDate(form.billDate!)
          : null,
      dueDate: form.dueDate != null ? _formatDate(form.dueDate!) : null,
      paymentMode: PurchasePaymentModes.toApi(form.paymentType),
      status: _statusApiValue(form),
      notes: form.termsNotes.trim().isEmpty ? null : form.termsNotes.trim(),
      description: form.description.trim().isEmpty
          ? null
          : form.description.trim(),
      subtotal: form.subtotal.toStringAsFixed(4),
      taxAmount: form.totalTax.toStringAsFixed(4),
      totalAmount: form.grandTotal.toStringAsFixed(4),
      balanceDue: form.balanceAmount.toStringAsFixed(4),
      assets: _assetRequests(form),
    );
  }

  static List<CreatePurchaseFaAssetRequest> _assetRequests(
    AddPurchaseFaFormState form,
  ) {
    final assets = <CreatePurchaseFaAssetRequest>[];
    for (var i = 0; i < form.items.length; i++) {
      final item = form.items[i];
      if (item.assetName.trim().isEmpty || item.qty <= 0) continue;

      assets.add(
        CreatePurchaseFaAssetRequest(
          id: _isUuid(item.id) ? item.id : null,
          assetName: item.assetName.trim(),
          description: item.description.trim().isEmpty
              ? null
              : item.description.trim(),
          purchasePrice: item.pricePerUnit.toStringAsFixed(4),
          qty: item.qty.toStringAsFixed(4),
          taxRate: item.taxPercent.toStringAsFixed(4),
          taxAmount: item.lineTax.toStringAsFixed(4),
          lineTotal: item.amount.toStringAsFixed(4),
          sortOrder: i,
        ),
      );
    }
    return assets;
  }

  static PurchaseFaStatus _mapStatus(String value) => switch (value) {
    'paid' => PurchaseFaStatus.paid,
    'unpaid' => PurchaseFaStatus.unpaid,
    'partially_paid' => PurchaseFaStatus.partiallyPaid,
    'overdue' => PurchaseFaStatus.overdue,
    'cancelled' => PurchaseFaStatus.cancelled,
    _ => PurchaseFaStatus.unpaid,
  };

  static String _statusApiValue(AddPurchaseFaFormState form) {
    final balance = form.balanceAmount;
    final paid = form.paymentAmount;
    if (balance <= 0) return 'paid';
    if (paid > 0) return 'partially_paid';
    return 'unpaid';
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static bool _isUuid(String value) => RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  ).hasMatch(value);
}
