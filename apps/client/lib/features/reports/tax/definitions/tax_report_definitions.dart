import 'package:billing_baba/features/reports/gst/definitions/gst_report_definitions.dart';
import 'package:billing_baba/features/reports/models/tax_report_kind.dart';

class TaxReportDefinition {
  const TaxReportDefinition({
    required this.kind,
    required this.title,
    required this.sections,
  });

  final TaxReportKind kind;
  final String title;
  final List<GstReportSectionDef> sections;

  GstReportSectionDef? sectionForKey(String key) {
    for (final section in sections) {
      if (section.key == key) return section;
    }
    return null;
  }
}

TaxReportDefinition definitionForTaxReport(TaxReportKind kind) {
  return switch (kind) {
    TaxReportKind.gstRegister => const TaxReportDefinition(
      kind: TaxReportKind.gstRegister,
      title: 'GST TAX REPORT',
      sections: [
        GstReportSectionDef(
          key: 'register',
          title: 'Register',
          columns: [
            GstReportColumnDef('date', 'Date'),
            GstReportColumnDef('document_no', 'Invoice No.'),
            GstReportColumnDef('transaction_type', 'Type'),
            GstReportColumnDef('party_name', 'Party'),
            GstReportColumnDef('gstin', 'GSTIN'),
            GstReportColumnDef('place_of_supply', 'Place of Supply'),
            GstReportColumnDef('taxable_value', 'Taxable'),
            GstReportColumnDef('tax_rate', 'Rate'),
            GstReportColumnDef('cgst', 'CGST'),
            GstReportColumnDef('sgst', 'SGST'),
            GstReportColumnDef('igst', 'IGST'),
            GstReportColumnDef('cess', 'Cess'),
            GstReportColumnDef('total_tax', 'Total Tax'),
            GstReportColumnDef('document_total', 'Total'),
          ],
        ),
      ],
    ),
    TaxReportKind.gstRateSummary => const TaxReportDefinition(
      kind: TaxReportKind.gstRateSummary,
      title: 'GST TAX RATE REPORT',
      sections: [
        GstReportSectionDef(
          key: 'rate_summary',
          title: 'By rate',
          columns: [
            GstReportColumnDef('tax_name', 'Tax'),
            GstReportColumnDef('taxable_sale', 'Taxable Sale'),
            GstReportColumnDef('sale_total_tax', 'Tax In'),
            GstReportColumnDef('taxable_purchase', 'Taxable Purchase'),
            GstReportColumnDef('purchase_total_tax', 'Tax Out'),
          ],
        ),
      ],
    ),
    TaxReportKind.form27eq => const TaxReportDefinition(
      kind: TaxReportKind.form27eq,
      title: 'Form No 27EQ',
      sections: [
        GstReportSectionDef(
          key: 'collections',
          title: 'Collections',
          columns: [
            GstReportColumnDef('party_name', 'Party'),
            GstReportColumnDef('party_pan', 'PAN'),
            GstReportColumnDef('section_code', 'Section'),
            GstReportColumnDef('entry_date', 'Date'),
            GstReportColumnDef('base_amount', 'Base'),
            GstReportColumnDef('rate', 'Rate'),
            GstReportColumnDef('tax_amount', 'TCS'),
          ],
        ),
      ],
    ),
    TaxReportKind.tcsReceivable => const TaxReportDefinition(
      kind: TaxReportKind.tcsReceivable,
      title: 'TCS Receivable',
      sections: [
        GstReportSectionDef(
          key: 'summary',
          title: 'Party summary',
          columns: [
            GstReportColumnDef('party_name', 'Party'),
            GstReportColumnDef('party_pan', 'PAN'),
            GstReportColumnDef('entry_count', 'Count'),
            GstReportColumnDef('base_amount', 'Base'),
            GstReportColumnDef('tax_amount', 'TCS'),
            GstReportColumnDef('pending', 'Pending'),
          ],
        ),
      ],
    ),
    TaxReportKind.tdsPayable => const TaxReportDefinition(
      kind: TaxReportKind.tdsPayable,
      title: 'TDS Payable',
      sections: [
        GstReportSectionDef(
          key: 'summary',
          title: 'Party summary',
          columns: [
            GstReportColumnDef('party_name', 'Party'),
            GstReportColumnDef('party_pan', 'PAN'),
            GstReportColumnDef('entry_count', 'Count'),
            GstReportColumnDef('base_amount', 'Base'),
            GstReportColumnDef('tax_amount', 'TDS'),
            GstReportColumnDef('pending', 'Pending'),
          ],
        ),
      ],
    ),
    TaxReportKind.tdsReceivable => const TaxReportDefinition(
      kind: TaxReportKind.tdsReceivable,
      title: 'TDS Receivable',
      sections: [
        GstReportSectionDef(
          key: 'summary',
          title: 'Party summary',
          columns: [
            GstReportColumnDef('party_name', 'Party'),
            GstReportColumnDef('party_pan', 'PAN'),
            GstReportColumnDef('entry_count', 'Count'),
            GstReportColumnDef('base_amount', 'Base'),
            GstReportColumnDef('tax_amount', 'TDS'),
            GstReportColumnDef('pending', 'Pending'),
          ],
        ),
      ],
    ),
  };
}
