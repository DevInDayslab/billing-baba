import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:flutter/material.dart';

class PurchaseDocumentDraftInput {
  const PurchaseDocumentDraftInput({
    required this.documentType,
    required this.documentSeries,
    this.documentId,
    this.partyId,
    this.documentDate,
    this.documentTime,
    this.dueDate,
    this.supplierInvoiceNumber,
    this.notes,
    this.godownId,
    this.isGstFormal = true,
    this.convertedFromId,
    this.items = const [],
  });

  final String? documentId;
  final String? partyId;
  final PurchaseDocumentType documentType;
  final String documentSeries;
  final DateTime? documentDate;
  final TimeOfDay? documentTime;
  final DateTime? dueDate;
  final String? supplierInvoiceNumber;
  final String? notes;
  final String? godownId;
  final bool isGstFormal;
  final String? convertedFromId;
  final List<PurchaseLineItem> items;
}
