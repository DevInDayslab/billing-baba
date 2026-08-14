import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/shared/documents/document_line_id.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

String money(double value) => value.toStringAsFixed(2);

Map<String, dynamic> buildSalesDocumentRowPayload({
  required String documentType,
  required String documentSeries,
  required bool isGstFormal,
  required String documentDate,
  required String subtotal,
  required String discountTotal,
  required String taxAmount,
  required String totalAmount,
  String? partyId,
  String? documentNumber,
  String? convertedFromId,
  String? notes,
  String? posSessionId,
}) {
  return {
    'document_type': documentType,
    'status': 'draft',
    'document_series': documentSeries,
    'party_id': ?partyId,
    'is_gst_formal': isGstFormal,
    'document_number': ?documentNumber,
    'document_date': documentDate,
    'converted_from_id': ?convertedFromId,
    'notes': ?notes,
    'pos_session_id': ?posSessionId,
    'subtotal': subtotal,
    'discount_total': discountTotal,
    'tax_amount': taxAmount,
    'total_amount': totalAmount,
  };
}

Map<String, dynamic> buildSalesLineRowPayload({
  required String salesDocumentId,
  required String itemId,
  required SaleLineItem item,
  required int sortOrder,
  required String taxOption,
}) {
  final taxPercent = effectiveSaleLineTaxPercent(
    taxOption: taxOption,
    lineTaxPercent: item.taxPercent,
  );
  final taxType = taxPercent > 0 ? 'gst' : 'none';
  final lineTax = item.lineTax;
  final halfTax = money(lineTax / 2);

  return {
    'sales_document_id': salesDocumentId,
    'item_id': itemId,
    'quantity': money(item.qty),
    'unit': item.unit,
    'unit_price': money(item.pricePerUnit),
    if (item.mrp > 0) 'market_price': money(item.mrp),
    'discount_amount': money(
      item.qty * item.pricePerUnit * item.discountPercent / 100,
    ),
    'tax_type': taxType,
    'tax_rate': money(taxPercent),
    'cgst_amount': halfTax,
    'sgst_amount': halfTax,
    'igst_amount': '0',
    'line_total': money(item.amount),
    'sort_order': sortOrder,
  };
}

({String subtotal, String discountTotal, String taxAmount, String totalAmount})
computeSalesTotals({
  required List<SaleLineItem> items,
  required String taxOption,
}) {
  final subtotalValue = items.fold<double>(
    0,
    (sum, item) => sum + item.lineSubtotal,
  );
  final taxValue = resolveSaleTotalTax(
    taxOption: taxOption,
    subtotal: subtotalValue,
    items: items,
  );
  final totalValue = resolveSaleRawGrandTotal(
    taxOption: taxOption,
    subtotal: subtotalValue,
    items: items,
  );
  return (
    subtotal: money(subtotalValue),
    discountTotal: '0',
    taxAmount: money(taxValue),
    totalAmount: money(totalValue),
  );
}

String apiDocumentDateFromInput({
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

String newLineId() => newDocumentLineId();
