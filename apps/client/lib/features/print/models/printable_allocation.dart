/// Enriched payment allocation row for voucher PDF output.
class PrintableAllocation {
  const PrintableAllocation({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.allocatedAmount,
    this.balance,
  });

  final String invoiceNumber;
  final String invoiceDate;
  final String allocatedAmount;
  final String? balance;
}
