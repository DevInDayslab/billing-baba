/// Aggregated tax totals for a printable document.
class PrintableTaxSummary {
  const PrintableTaxSummary({
    required this.cgstTotal,
    required this.sgstTotal,
    required this.igstTotal,
    required this.taxTotal,
  });

  final String cgstTotal;
  final String sgstTotal;
  final String igstTotal;
  final String taxTotal;

  static const zero = PrintableTaxSummary(
    cgstTotal: '0',
    sgstTotal: '0',
    igstTotal: '0',
    taxTotal: '0',
  );
}
