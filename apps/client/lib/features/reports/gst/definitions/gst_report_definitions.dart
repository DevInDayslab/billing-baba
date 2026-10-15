import 'package:billing_baba/features/reports/models/gst_report_type.dart';

class GstReportColumnDef {
  const GstReportColumnDef(this.key, this.label);

  final String key;
  final String label;
}

class GstReportSectionDef {
  const GstReportSectionDef({
    required this.key,
    required this.title,
    required this.columns,
  });

  final String key;
  final String title;
  final List<GstReportColumnDef> columns;
}

class GstReportDefinition {
  const GstReportDefinition({
    required this.type,
    required this.sections,
  });

  final GstReportType type;
  final List<GstReportSectionDef> sections;

  GstReportSectionDef? sectionForKey(String key) {
    for (final section in sections) {
      if (section.key == key) return section;
    }
    return null;
  }
}

const _invoiceColumns = [
  GstReportColumnDef('gstin', 'GSTIN'),
  GstReportColumnDef('party_name', 'Party'),
  GstReportColumnDef('invoice_no', 'Invoice No.'),
  GstReportColumnDef('invoice_date', 'Date'),
  GstReportColumnDef('taxable_value', 'Taxable Value'),
  GstReportColumnDef('igst', 'IGST'),
  GstReportColumnDef('cgst', 'CGST'),
  GstReportColumnDef('sgst', 'SGST'),
  GstReportColumnDef('value', 'Invoice Value'),
];

const _hsnColumns = [
  GstReportColumnDef('hsn', 'HSN'),
  GstReportColumnDef('description', 'Description'),
  GstReportColumnDef('uqc', 'UQC'),
  GstReportColumnDef('quantity', 'Qty'),
  GstReportColumnDef('taxable_value', 'Taxable Value'),
  GstReportColumnDef('tax_rate', 'Rate %'),
  GstReportColumnDef('igst', 'IGST'),
  GstReportColumnDef('cgst', 'CGST'),
  GstReportColumnDef('sgst', 'SGST'),
];

GstReportDefinition definitionFor(GstReportType type) {
  return switch (type) {
    GstReportType.gstr1 => const GstReportDefinition(
      type: GstReportType.gstr1,
      sections: [
        GstReportSectionDef(key: 'b2b', title: 'B2B', columns: _invoiceColumns),
        GstReportSectionDef(key: 'b2cl', title: 'B2C Large', columns: _invoiceColumns),
        GstReportSectionDef(key: 'b2cs', title: 'B2C Small', columns: _invoiceColumns),
        GstReportSectionDef(key: 'cdnr', title: 'CDNR', columns: _invoiceColumns),
        GstReportSectionDef(key: 'cdnur', title: 'CDNUR', columns: _invoiceColumns),
        GstReportSectionDef(key: 'exports', title: 'Exports', columns: _invoiceColumns),
        GstReportSectionDef(
          key: 'nil_exempt',
          title: 'Nil / Exempt / Non-GST',
          columns: _invoiceColumns,
        ),
        GstReportSectionDef(
          key: 'hsn',
          title: 'Sale Summary By HSN',
          columns: _hsnColumns,
        ),
        GstReportSectionDef(key: 'doc_issue', title: 'Document Summary', columns: [
          GstReportColumnDef('document_series', 'Series'),
          GstReportColumnDef('from', 'From'),
          GstReportColumnDef('to', 'To'),
          GstReportColumnDef('cancelled', 'Cancelled'),
          GstReportColumnDef('net_issued', 'Net issued'),
        ]),
      ],
    ),
    GstReportType.gstr2 => const GstReportDefinition(
      type: GstReportType.gstr2,
      sections: [
        GstReportSectionDef(key: 'b2b', title: 'B2B', columns: [
          GstReportColumnDef('gstin', 'GSTIN'),
          GstReportColumnDef('party_name', 'Supplier'),
          GstReportColumnDef('bill_no', 'Bill No.'),
          GstReportColumnDef('bill_date', 'Date'),
          GstReportColumnDef('taxable_value', 'Taxable Value'),
          GstReportColumnDef('itc_eligible', 'ITC Eligible'),
        ]),
        GstReportSectionDef(key: 'itc_summary', title: 'ITC Summary', columns: [
          GstReportColumnDef('label', 'Component'),
          GstReportColumnDef('amount', 'Amount'),
        ]),
      ],
    ),
    GstReportType.gstr3b => const GstReportDefinition(
      type: GstReportType.gstr3b,
      sections: [
        GstReportSectionDef(key: 'outward', title: '3.1 Outward', columns: [
          GstReportColumnDef('nature', 'Nature'),
          GstReportColumnDef('taxable_value', 'Taxable'),
          GstReportColumnDef('igst', 'IGST'),
          GstReportColumnDef('cgst', 'CGST'),
          GstReportColumnDef('sgst', 'SGST'),
        ]),
        GstReportSectionDef(key: 'itc', title: '4 ITC', columns: [
          GstReportColumnDef('label', 'Description'),
          GstReportColumnDef('igst', 'IGST'),
          GstReportColumnDef('cgst', 'CGST'),
          GstReportColumnDef('sgst', 'SGST'),
        ]),
      ],
    ),
    GstReportType.gstr9 => const GstReportDefinition(
      type: GstReportType.gstr9,
      sections: [
        GstReportSectionDef(key: 'monthly', title: 'Monthly summary', columns: [
          GstReportColumnDef('month', 'Month'),
          GstReportColumnDef('taxable_outward', 'Outward taxable'),
          GstReportColumnDef('tax_paid', 'Tax paid'),
        ]),
      ],
    ),
    GstReportType.hsnSummary => const GstReportDefinition(
      type: GstReportType.hsnSummary,
      sections: [
        GstReportSectionDef(key: 'hsn', title: 'HSN Summary', columns: _hsnColumns),
      ],
    ),
    GstReportType.sacReport => GstReportDefinition(
      type: GstReportType.sacReport,
      sections: [
        GstReportSectionDef(
          key: 'sac',
          title: 'SAC Summary',
          columns: [
            const GstReportColumnDef('hsn', 'SAC'),
            ..._hsnColumns.skip(1),
          ],
        ),
      ],
    ),
  };
}
