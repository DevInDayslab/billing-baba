/// Supported export output formats.
enum ExportFormat {
  csv,
  xlsx;

  // Future-ready (not implemented in Phase 1E):
  // pdf, json, xml

  String get extension => switch (this) {
    ExportFormat.csv => 'csv',
    ExportFormat.xlsx => 'xlsx',
  };

  String get mimeType => switch (this) {
    ExportFormat.csv => 'text/csv',
    ExportFormat.xlsx =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  };
}
