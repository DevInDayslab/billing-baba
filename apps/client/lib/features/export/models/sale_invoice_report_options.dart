/// Column selections for sale invoice Excel export.
class SaleInvoiceReportOptions {
  const SaleInvoiceReportOptions({
    this.includeDate = true,
    this.includeInvoiceNo = true,
    this.includePartyName = true,
    this.includeTotal = true,
    this.includePaymentType = true,
    this.includeReceivedPaid = true,
    this.includeBalanceDue = true,
    this.includeItemDetails = false,
    this.includeDescription = false,
    this.includePaymentStatus = false,
    this.includeOrderNumber = false,
    this.includePartyPhone = false,
    this.includePaymentBreakup = false,
    this.includePartyGstin = true,
  });

  final bool includeDate;
  final bool includeInvoiceNo;
  final bool includePartyName;
  final bool includeTotal;
  final bool includePaymentType;
  final bool includeReceivedPaid;
  final bool includeBalanceDue;
  final bool includeItemDetails;
  final bool includeDescription;
  final bool includePaymentStatus;
  final bool includeOrderNumber;
  final bool includePartyPhone;
  final bool includePaymentBreakup;
  final bool includePartyGstin;

  bool get hasAnySelected =>
      includeDate ||
      includeInvoiceNo ||
      includePartyName ||
      includeTotal ||
      includePaymentType ||
      includeReceivedPaid ||
      includeBalanceDue ||
      includeItemDetails ||
      includeDescription ||
      includePaymentStatus ||
      includeOrderNumber ||
      includePartyPhone ||
      includePaymentBreakup ||
      includePartyGstin;

  SaleInvoiceReportOptions copyWith({
    bool? includeDate,
    bool? includeInvoiceNo,
    bool? includePartyName,
    bool? includeTotal,
    bool? includePaymentType,
    bool? includeReceivedPaid,
    bool? includeBalanceDue,
    bool? includeItemDetails,
    bool? includeDescription,
    bool? includePaymentStatus,
    bool? includeOrderNumber,
    bool? includePartyPhone,
    bool? includePaymentBreakup,
    bool? includePartyGstin,
  }) {
    return SaleInvoiceReportOptions(
      includeDate: includeDate ?? this.includeDate,
      includeInvoiceNo: includeInvoiceNo ?? this.includeInvoiceNo,
      includePartyName: includePartyName ?? this.includePartyName,
      includeTotal: includeTotal ?? this.includeTotal,
      includePaymentType: includePaymentType ?? this.includePaymentType,
      includeReceivedPaid: includeReceivedPaid ?? this.includeReceivedPaid,
      includeBalanceDue: includeBalanceDue ?? this.includeBalanceDue,
      includeItemDetails: includeItemDetails ?? this.includeItemDetails,
      includeDescription: includeDescription ?? this.includeDescription,
      includePaymentStatus: includePaymentStatus ?? this.includePaymentStatus,
      includeOrderNumber: includeOrderNumber ?? this.includeOrderNumber,
      includePartyPhone: includePartyPhone ?? this.includePartyPhone,
      includePaymentBreakup:
          includePaymentBreakup ?? this.includePaymentBreakup,
      includePartyGstin: includePartyGstin ?? this.includePartyGstin,
    );
  }
}
