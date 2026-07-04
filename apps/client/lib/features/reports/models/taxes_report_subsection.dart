enum TaxesReportSubSection {
  gstReport('GST Report'),
  gstRateReport('GST Rate Report'),
  formNo27Eq('Form No 27EQ'),
  tcsReceivable('TCS Receivable'),
  tdsPayable('TDS Payable'),
  tdsReceivable('TDS Receivable');

  const TaxesReportSubSection(this.label);

  final String label;

  String get pageTitle => switch (this) {
        TaxesReportSubSection.gstReport => 'GST TAX REPORT',
        TaxesReportSubSection.gstRateReport => 'GST TAX RATE REPORT',
        TaxesReportSubSection.formNo27Eq => 'All Form No. 27EQ Invoices',
        TaxesReportSubSection.tcsReceivable => 'All TCS Receivable Invoices',
        TaxesReportSubSection.tdsPayable => 'All TDS Payable Invoices',
        TaxesReportSubSection.tdsReceivable => 'All TDS Receivable Invoices',
      };

  String get emptyMessage =>
      'No data is available for $label. Please try again after making relevant changes.';
}
