import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';

/// Common payload for saving any sales document with line items.
class SalesDocumentDraftInput {
  const SalesDocumentDraftInput({
    required this.documentType,
    required this.documentSeries,
    required this.items,
    this.documentId,
    this.partyId,
    this.documentDate,
    this.documentTime,
    this.notes,
    this.godownId,
    this.isGstFormal = false,
    this.convertedFromId,
  });

  final String? documentId;
  final String? partyId;
  final SalesDocumentType documentType;
  final String documentSeries;
  final DateTime? documentDate;
  final TimeOfDay? documentTime;
  final String? notes;
  final String? godownId;
  final bool isGstFormal;
  final String? convertedFromId;
  final List<SaleLineItem> items;
}
