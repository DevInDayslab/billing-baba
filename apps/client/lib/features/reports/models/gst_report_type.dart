import 'package:billing_baba/features/reports/models/gst_report_subsection.dart';

enum GstReportType {
  gstr1,
  gstr2,
  gstr3b,
  gstr9,
  hsnSummary,
  sacReport,
}

extension GstReportSubSectionMapper on GstReportSubSection {
  GstReportType toGstReportType() => switch (this) {
    GstReportSubSection.gstr1 => GstReportType.gstr1,
    GstReportSubSection.gstr2 => GstReportType.gstr2,
    GstReportSubSection.gstr3b => GstReportType.gstr3b,
    GstReportSubSection.gstr9 => GstReportType.gstr9,
    GstReportSubSection.saleSummaryByHsn => GstReportType.hsnSummary,
    GstReportSubSection.sacReport => GstReportType.sacReport,
  };
}

extension GstReportTypeLabels on GstReportType {
  String get title => switch (this) {
    GstReportType.gstr1 => 'GSTR-1',
    GstReportType.gstr2 => 'GSTR-2',
    GstReportType.gstr3b => 'GSTR-3B',
    GstReportType.gstr9 => 'GSTR-9',
    GstReportType.hsnSummary => 'Sale Summary By HSN',
    GstReportType.sacReport => 'SAC Report',
  };

  bool get supportsNonTaxAsExempt => this == GstReportType.gstr3b;

  bool get supportsGstnJsonExport =>
      this == GstReportType.gstr1 || this == GstReportType.gstr3b;

  bool get isDiscontinuedFiling => this == GstReportType.gstr2;
}
