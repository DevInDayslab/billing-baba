import 'package:billing_baba/features/sales/models/dto/sale_fa_dto.dart';
import 'package:billing_baba/features/sales/models/requests/sale_fa_requests.dart';
import 'package:billing_baba/features/sales/models/sale_fa_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/shared/documents/document_line_id.dart';
import 'package:flutter/material.dart';

class SaleFaMapper {
  static SaleFaModel toModel(
    SaleFaBatchListDto dto, {
    String partyName = '',
  }) {
    final amount = double.tryParse(dto.totalAmount) ?? 0;
    final balanceDue = double.tryParse(dto.balanceDue) ?? 0;
    final saleDate = DateTime.tryParse(dto.saleDate) ?? DateTime.now();
    final createdAt = DateTime.tryParse(dto.createdAt) ?? saleDate;
    final dueDate = dto.dueDate != null
        ? DateTime.tryParse(dto.dueDate!) ?? saleDate
        : saleDate;

    return SaleFaModel(
      id: dto.id,
      batchId: dto.id,
      partyId: dto.partyId,
      invoiceNo: dto.referenceNumber ?? dto.id.substring(0, 8),
      date: saleDate,
      partyName: partyName.isNotEmpty ? partyName : dto.partyName,
      paymentType: SalesPaymentModes.toUi(dto.paymentMode ?? 'cash'),
      status: _mapStatus(dto.status),
      amount: amount,
      balanceDue: balanceDue,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  static AddSaleFaFormState toFormState(SaleFaBatchDto dto) {
    final saleDate = DateTime.tryParse(dto.saleDate) ?? DateTime.now();
    final dueDate = dto.dueDate != null
        ? DateTime.tryParse(dto.dueDate!)
        : null;
    final totalAmount = double.tryParse(dto.totalAmount) ?? 0;
    final balanceDue = double.tryParse(dto.balanceDue) ?? 0;
    final paidAmount = (totalAmount - balanceDue)
        .clamp(0, totalAmount)
        .toDouble();

    final items = dto.assets.isEmpty
        ? [SaleFixedAssetLineItem.empty(id: newDocumentLineId())]
        : dto.assets
              .map(
                (asset) => SaleFixedAssetLineItem(
                  id: asset.id,
                  assetName: asset.assetName,
                  itemCode: asset.itemCode ?? '',
                  description: asset.description ?? '',
                  qty: double.tryParse(asset.qty) ?? 1,
                  pricePerUnit: double.tryParse(asset.salePrice) ?? 0,
                  taxPercent: double.tryParse(asset.taxRate) ?? 0,
                ),
              )
              .toList();

    return AddSaleFaFormState(
      batchId: dto.id,
      partyId: dto.partyId,
      party: dto.partyName,
      billingName: dto.partyName,
      invoiceNumber: dto.referenceNumber ?? '',
      saleDate: DateTime(saleDate.year, saleDate.month, saleDate.day),
      saleTime: TimeOfDay.fromDateTime(saleDate),
      dueDate: dueDate != null
          ? DateTime(dueDate.year, dueDate.month, dueDate.day)
          : null,
      description: dto.description ?? '',
      termsNotes: dto.notes ?? '',
      items: items,
      payments: [
        SalePaymentEntry(
          type: SalesPaymentModes.toUi(dto.paymentMode ?? 'cash'),
          amount: paidAmount,
        ),
      ],
    );
  }

  static CreateSaleFaRequest toCreateRequest(AddSaleFaFormState form) {
    return CreateSaleFaRequest(
      partyId: form.partyId!,
      referenceNumber: form.invoiceNumber.trim().isEmpty
          ? null
          : form.invoiceNumber.trim(),
      saleDate: _formatDate(form.saleDate ?? DateTime.now()),
      dueDate: form.dueDate != null ? _formatDate(form.dueDate!) : null,
      paymentMode: SalesPaymentModes.toApi(form.paymentType),
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

  static UpdateSaleFaRequest toUpdateRequest(AddSaleFaFormState form) {
    return UpdateSaleFaRequest(
      partyId: form.partyId,
      referenceNumber: form.invoiceNumber.trim().isEmpty
          ? null
          : form.invoiceNumber.trim(),
      saleDate: form.saleDate != null ? _formatDate(form.saleDate!) : null,
      dueDate: form.dueDate != null ? _formatDate(form.dueDate!) : null,
      paymentMode: SalesPaymentModes.toApi(form.paymentType),
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

  static List<CreateSaleFaAssetRequest> _assetRequests(
    AddSaleFaFormState form,
  ) {
    final assets = <CreateSaleFaAssetRequest>[];
    for (var i = 0; i < form.items.length; i++) {
      final item = form.items[i];
      if (item.assetName.trim().isEmpty || item.qty <= 0) continue;

      final taxPercent = effectiveSaleFaLineTaxPercent(
        taxOption: form.taxOption,
        lineTaxPercent: item.taxPercent,
      );
      final taxableItem = item.copyWith(taxPercent: taxPercent);

      assets.add(
        CreateSaleFaAssetRequest(
          id: _isUuid(item.id) ? item.id : null,
          assetName: item.assetName.trim(),
          itemCode: item.itemCode.trim().isEmpty ? null : item.itemCode.trim(),
          description: item.description.trim().isEmpty
              ? null
              : item.description.trim(),
          salePrice: item.pricePerUnit.toStringAsFixed(4),
          qty: item.qty.toStringAsFixed(4),
          taxRate: taxPercent.toStringAsFixed(4),
          taxAmount: taxableItem.lineTax.toStringAsFixed(4),
          lineTotal: taxableItem.amount.toStringAsFixed(4),
          sortOrder: i,
        ),
      );
    }
    return assets;
  }

  static SaleFaStatus _mapStatus(String value) => switch (value) {
    'paid' => SaleFaStatus.paid,
    'unpaid' => SaleFaStatus.unpaid,
    'partially_paid' => SaleFaStatus.partiallyPaid,
    'overdue' => SaleFaStatus.overdue,
    'cancelled' => SaleFaStatus.cancelled,
    _ => SaleFaStatus.unpaid,
  };

  static String _statusApiValue(AddSaleFaFormState form) {
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
