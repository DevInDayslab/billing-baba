class PurchaseDocumentParseLineDto {
  const PurchaseDocumentParseLineDto({
    this.itemName,
    this.itemId,
    this.description,
    this.quantity,
    this.unit,
    this.unitPrice,
    this.taxRate,
    this.taxInclusive,
    this.taxAmount,
    this.discountAmount,
  });

  factory PurchaseDocumentParseLineDto.fromJson(Map<String, dynamic> json) {
    return PurchaseDocumentParseLineDto(
      itemName: _nullableString(json['item_name']),
      itemId: _nullableString(json['item_id']),
      description: _nullableString(json['description']),
      quantity: _nullableDouble(json['quantity']),
      unit: _nullableString(json['unit']),
      unitPrice: _nullableDouble(json['unit_price']),
      taxRate: _nullableDouble(json['tax_rate']),
      taxInclusive: _nullableBool(json['tax_inclusive']),
      taxAmount: _nullableDouble(json['tax_amount']),
      discountAmount: _nullableDouble(json['discount_amount']),
    );
  }

  final String? itemName;
  final String? itemId;
  final String? description;
  final double? quantity;
  final String? unit;
  final double? unitPrice;
  final double? taxRate;
  final bool? taxInclusive;
  final double? taxAmount;
  final double? discountAmount;
}

class PurchaseDocumentParseDto {
  const PurchaseDocumentParseDto({
    this.vendorName,
    this.partyId,
    this.gstin,
    this.vendorPhone,
    this.vendorEmail,
    this.vendorAddress,
    this.vendorCity,
    this.vendorPincode,
    this.vendorState,
    this.eWayBillNumber,
    this.supplierInvoiceNumber,
    this.invoiceNumber,
    this.invoiceDate,
    this.dueDate,
    this.stateOfSupply,
    this.paymentMode,
    this.paymentAmount,
    this.notes,
    this.termsNotes,
    this.subtotal,
    this.discountTotal,
    this.taxAmount,
    this.totalAmount,
    this.lines = const [],
  });

  factory PurchaseDocumentParseDto.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    final lines = rawLines is List
        ? rawLines
              .whereType<Map<String, dynamic>>()
              .map(PurchaseDocumentParseLineDto.fromJson)
              .toList()
        : const <PurchaseDocumentParseLineDto>[];

    return PurchaseDocumentParseDto(
      vendorName: _nullableString(json['vendor_name']),
      partyId: _nullableString(json['party_id']),
      gstin: _nullableString(json['gstin']),
      vendorPhone: _nullableString(json['vendor_phone']),
      vendorEmail: _nullableString(json['vendor_email']),
      vendorAddress: _nullableString(json['vendor_address']),
      vendorCity: _nullableString(json['vendor_city']),
      vendorPincode: _nullableString(json['vendor_pincode']),
      vendorState: _nullableString(json['vendor_state']),
      eWayBillNumber: _nullableString(json['e_way_bill_number']),
      supplierInvoiceNumber: _nullableString(json['supplier_invoice_number']),
      invoiceNumber: _nullableString(json['invoice_number']),
      invoiceDate: _nullableString(json['invoice_date']),
      dueDate: _nullableString(json['due_date']),
      stateOfSupply: _nullableString(json['state_of_supply']),
      paymentMode: _nullableString(json['payment_mode']),
      paymentAmount: _nullableDouble(json['payment_amount']),
      notes: _nullableString(json['notes']),
      termsNotes: _nullableString(json['terms_notes']),
      subtotal: _nullableDouble(json['subtotal']),
      discountTotal: _nullableDouble(json['discount_total']),
      taxAmount: _nullableDouble(json['tax_amount']),
      totalAmount: _nullableDouble(json['total_amount']),
      lines: lines,
    );
  }

  final String? vendorName;
  final String? partyId;
  final String? gstin;
  final String? vendorPhone;
  final String? vendorEmail;
  final String? vendorAddress;
  final String? vendorCity;
  final String? vendorPincode;
  final String? vendorState;
  final String? eWayBillNumber;
  final String? supplierInvoiceNumber;
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? dueDate;
  final String? stateOfSupply;
  final String? paymentMode;
  final double? paymentAmount;
  final String? notes;
  final String? termsNotes;
  final double? subtotal;
  final double? discountTotal;
  final double? taxAmount;
  final double? totalAmount;
  final List<PurchaseDocumentParseLineDto> lines;
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

double? _nullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _nullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  final text = value.toString().trim().toLowerCase();
  if (text == 'true') return true;
  if (text == 'false') return false;
  return null;
}
