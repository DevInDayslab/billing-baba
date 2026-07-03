enum GstReportSubSection {
  gstr1('GSTR 1'),
  gstr2('GSTR 2'),
  gstr3b('GSTR 3 B'),
  gstr9('GSTR 9'),
  saleSummaryByHsn('Sale Summary By HSN');

  const GstReportSubSection(this.label);

  final String label;
}
