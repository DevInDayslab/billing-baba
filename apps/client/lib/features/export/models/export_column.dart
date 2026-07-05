/// Cell type for formatting in CSV and Excel exporters.
enum ExportCellType {
  text,
  number,
  currency,
  date,
  datetime,
}

/// Column definition for an export sheet.
class ExportColumn {
  const ExportColumn({
    required this.header,
    this.type = ExportCellType.text,
  });

  final String header;
  final ExportCellType type;
}
