import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

String purchaseMoney(double value) => value.toStringAsFixed(2);

Map<String, dynamic> buildPurchaseDocumentRowPayload({
  required String documentType,
  required String documentSeries,
  required String partyId,
  required bool isGstFormal,
  required String documentDate, required String subtotal, required String discountTotal, required String taxAmount, required String totalAmount, String? documentNumber,
  String? convertedFromId,
  String? supplierInvoiceNumber,
  String? dueDate,
  String? notes,
}) {
  return {
    'document_type': documentType,
    'status': 'draft',
    'document_series': documentSeries,
    'party_id': partyId,
    'is_gst_formal': isGstFormal,
    'document_number': ?documentNumber,
    'document_date': documentDate,
    'converted_from_id': ?convertedFromId,
    'supplier_invoice_number': ?supplierInvoiceNumber,
    'due_date': ?dueDate,
    'notes': ?notes,
    'subtotal': subtotal,
    'discount_total': discountTotal,
    'tax_amount': taxAmount,
    'total_amount': totalAmount,
  };
}

Map<String, dynamic> buildPurchaseLineRowPayload({
  required String purchaseDocumentId,
  required String itemId,
  required PurchaseLineItem item,
  required int sortOrder,
}) {
  final taxType = item.taxPercent > 0 ? 'gst' : 'none';
  final lineTax = item.lineTax;
  final halfTax = purchaseMoney(lineTax / 2);

  return {
    'purchase_document_id': purchaseDocumentId,
    'item_id': itemId,
    'quantity': purchaseMoney(item.qty),
    'unit': item.unit,
    'unit_price': purchaseMoney(item.pricePerUnit),
    'discount_amount': '0',
    'tax_type': taxType,
    'tax_rate': purchaseMoney(item.taxPercent),
    'cgst_amount': halfTax,
    'sgst_amount': halfTax,
    'igst_amount': '0',
    'line_total': purchaseMoney(item.amount),
    'sort_order': sortOrder,
  };
}

({String subtotal, String discountTotal, String taxAmount, String totalAmount})
    computePurchaseTotals(List<PurchaseLineItem> items) {
  final subtotalValue =
      items.fold<double>(0, (sum, item) => sum + item.lineSubtotal);
  final taxValue = items.fold<double>(0, (sum, item) => sum + item.lineTax);
  final totalValue = subtotalValue + taxValue;
  return (
    subtotal: purchaseMoney(subtotalValue),
    discountTotal: '0',
    taxAmount: purchaseMoney(taxValue),
    totalAmount: purchaseMoney(totalValue),
  );
}

String purchaseApiDocumentDate({
  DateTime? documentDate,
  TimeOfDay? documentTime,
}) {
  final date = documentDate ?? DateTime.now();
  final time = documentTime ?? TimeOfDay.fromDateTime(date);
  final combined = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  return DateTimeUtils.toApiIso(combined);
}
