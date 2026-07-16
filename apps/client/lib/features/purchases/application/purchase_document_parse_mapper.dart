import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:flutter/material.dart';

typedef _LineTaxMapping = ({
  double unitPrice,
  double taxPercent,
  bool withTax,
});

/// Maps a parse-document API response onto [AddPurchaseFormState].
/// Only non-null parsed values are applied; nothing is guessed.
class PurchaseDocumentParseMapper {
  const PurchaseDocumentParseMapper._();

  static AddPurchaseFormState apply({
    required AddPurchaseFormState base,
    required PurchaseDocumentParseDto parsed,
    required List<PartyModel> parties,
    required Map<String, String> itemNameToId,
    required String Function() nextLineId,
  }) {
    var next = base;

    final partyMatch = resolveParty(parsed, parties);
    if (partyMatch != null) {
      next = next.copyWith(
        partyId: partyMatch.id,
        party: partyMatch.name,
        billingName: partyMatch.name,
      );
    } else if (parsed.vendorName != null) {
      next = next.copyWith(party: parsed.vendorName);
    }

    if (parsed.supplierInvoiceNumber != null) {
      next = next.copyWith(eWayBillNo: parsed.supplierInvoiceNumber!);
    }

    if (parsed.invoiceNumber != null &&
        (next.billNumber.isEmpty || next.billNumber == 'Auto')) {
      next = next.copyWith(billNumber: parsed.invoiceNumber!);
    }

    final invoiceDate = _parseDate(parsed.invoiceDate);
    if (invoiceDate != null) {
      next = next.copyWith(
        billDate: invoiceDate,
        billTime: TimeOfDay.fromDateTime(invoiceDate),
      );
    }

    final dueDate = _parseDate(parsed.dueDate);
    if (dueDate != null) {
      next = next.copyWith(dueDate: dueDate);
    }

    if (parsed.stateOfSupply != null) {
      next = next.copyWith(stateOfSupply: parsed.stateOfSupply!);
    }

    if (parsed.notes != null) {
      next = next.copyWith(description: parsed.notes!);
    }

    if (parsed.termsNotes != null) {
      next = next.copyWith(termsNotes: parsed.termsNotes!);
    }

    if (parsed.lines.isNotEmpty) {
      final items = <PurchaseLineItem>[];
      for (final line in parsed.lines) {
        final mapped = _mapLine(line, itemNameToId, nextLineId);
        if (mapped != null) {
          items.add(mapped);
        }
      }
      if (items.isNotEmpty) {
        next = next.copyWith(items: items);
      }
    }

    final paymentMode = _mapPaymentMode(parsed.paymentMode);
    final paymentAmount = parsed.paymentAmount ?? parsed.totalAmount;
    if (paymentMode != null || paymentAmount != null) {
      final current = next.payments.isNotEmpty
          ? next.payments.first
          : const SalePaymentEntry(type: 'Cash');
      next = next.copyWith(
        payments: [
          current.copyWith(
            type: paymentMode ?? current.type,
            amount: paymentAmount ?? current.amount,
          ),
        ],
      );
    }

    return next.copyWith(isDirty: true, clearSaveError: true);
  }

  static PartyModel? resolveParty(
    PurchaseDocumentParseDto parsed,
    List<PartyModel> parties,
  ) {
    if (parsed.partyId != null) {
      for (final party in parties) {
        if (party.id == parsed.partyId) return party;
      }
    }

    if (parsed.gstin != null) {
      final gstin = parsed.gstin!.trim().toUpperCase();
      for (final party in parties) {
        if (party.gstin.trim().toUpperCase() == gstin) return party;
      }
    }

    if (parsed.vendorName != null) {
      final name = parsed.vendorName!.trim().toLowerCase();
      for (final party in parties) {
        if (party.name.trim().toLowerCase() == name) return party;
      }
    }

    return null;
  }

  static PurchaseLineItem? _mapLine(
    PurchaseDocumentParseLineDto line,
    Map<String, String> itemNameToId,
    String Function() nextLineId,
  ) {
    final itemName = line.itemName?.trim();
    if (itemName == null || itemName.isEmpty) return null;

    final qty = line.quantity;
    if (qty == null || qty <= 0) return null;

    final price = line.unitPrice;
    if (price == null || price < 0) return null;

    String? itemId = line.itemId;
    itemId ??= itemNameToId[itemName];

    final tax = _resolveWithTaxMapping(line, qty, price);

    return PurchaseLineItem(
      id: nextLineId(),
      itemId: itemId,
      itemName: itemName,
      description: line.description ?? '',
      qty: qty,
      unit: line.unit ?? 'NONE',
      pricePerUnit: tax.unitPrice,
      taxPercent: tax.taxPercent,
      priceIsTaxInclusive: tax.withTax,
    );
  }

  /// When the bill has GST on a line, map it to **With Tax** mode and align the
  /// slab/amount with what is printed on the bill.
  static _LineTaxMapping _resolveWithTaxMapping(
    PurchaseDocumentParseLineDto line,
    double qty,
    double unitPrice,
  ) {
    final billTaxAmount = line.taxAmount;
    final rawRate = line.taxRate;
    final billInclusive = line.taxInclusive ?? false;
    final hasTaxRate = rawRate != null && rawRate > 0;
    final hasTaxAmount = billTaxAmount != null && billTaxAmount > 0;

    if (!hasTaxRate && !hasTaxAmount) {
      return (unitPrice: unitPrice, taxPercent: 0, withTax: false);
    }

    var taxPercent = hasTaxRate ? _normalizeToPurchaseTaxSlab(rawRate!) : 0.0;

    if (taxPercent <= 0 && hasTaxAmount && qty > 0 && unitPrice > 0) {
      taxPercent = billInclusive
          ? _deriveTaxPercentFromInclusiveAmount(
              qty: qty,
              inclusiveUnitPrice: unitPrice,
              taxAmount: billTaxAmount!,
            )
          : _deriveTaxPercentFromExclusiveAmount(
              qty: qty,
              unitPrice: unitPrice,
              taxAmount: billTaxAmount!,
            );
    }

    if (taxPercent <= 0) {
      return (unitPrice: unitPrice, taxPercent: 0, withTax: false);
    }

    final inclusiveUnitPrice = billInclusive
        ? unitPrice
        : unitPrice * (1 + taxPercent / 100);

    if (hasTaxAmount) {
      taxPercent = _resolveTaxPercentMatchingBillTax(
        qty: qty,
        inclusiveUnitPrice: inclusiveUnitPrice,
        taxAmount: billTaxAmount!,
        fallbackPercent: taxPercent,
      );
    }

    return (
      unitPrice: inclusiveUnitPrice,
      taxPercent: taxPercent,
      withTax: true,
    );
  }

  static double _normalizeToPurchaseTaxSlab(double rate) {
    const slabs = <double>[5, 12, 18, 28];

    for (final slab in slabs) {
      if ((rate - slab).abs() < 0.75) return slab;
      if ((rate - slab / 2).abs() < 0.75) return slab;
    }

    var best = 0.0;
    var bestDiff = double.infinity;
    for (final slab in slabs) {
      final diff = (rate - slab).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = slab;
      }
    }

    return bestDiff <= 2 ? best : rate;
  }

  static double _deriveTaxPercentFromExclusiveAmount({
    required double qty,
    required double unitPrice,
    required double taxAmount,
  }) {
    final subtotal = qty * unitPrice;
    if (subtotal <= 0) return 0;
    return _normalizeToPurchaseTaxSlab((taxAmount * 100) / subtotal);
  }

  static double _deriveTaxPercentFromInclusiveAmount({
    required double qty,
    required double inclusiveUnitPrice,
    required double taxAmount,
  }) {
    final gross = qty * inclusiveUnitPrice;
    if (gross <= taxAmount) return 0;
    return _normalizeToPurchaseTaxSlab((taxAmount * 100) / (gross - taxAmount));
  }

  static double _resolveTaxPercentMatchingBillTax({
    required double qty,
    required double inclusiveUnitPrice,
    required double taxAmount,
    required double fallbackPercent,
  }) {
    final derived = _deriveTaxPercentFromInclusiveAmount(
      qty: qty,
      inclusiveUnitPrice: inclusiveUnitPrice,
      taxAmount: taxAmount,
    );
    return derived > 0 ? derived : fallbackPercent;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static String? _mapPaymentMode(String? apiValue) {
    if (apiValue == null || apiValue.trim().isEmpty) return null;

    final uiLabel = PurchasePaymentModes.toUi(apiValue.trim().toLowerCase());
    if (SaleDropdownOptions.paymentTypes.contains(uiLabel)) {
      return uiLabel;
    }

    for (final type in SaleDropdownOptions.paymentTypes) {
      if (type.toLowerCase() == apiValue.trim().toLowerCase()) {
        return type;
      }
    }

    return null;
  }
}
