import 'package:billing_baba/features/export/models/export_format.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';

/// Request to generate an export file.
class ExportRequest {
  const ExportRequest({
    required this.sheets,
    required this.format,
    required this.filenameBase,
  });

  factory ExportRequest.csv({
    required ExportSheet sheet,
    required String filenameBase,
  }) {
    return ExportRequest(
      sheets: [sheet],
      format: ExportFormat.csv,
      filenameBase: filenameBase,
    );
  }

  factory ExportRequest.xlsx({
    required List<ExportSheet> sheets,
    required String filenameBase,
  }) {
    return ExportRequest(
      sheets: sheets,
      format: ExportFormat.xlsx,
      filenameBase: filenameBase,
    );
  }

  factory ExportRequest.xlsxSingle({
    required ExportSheet sheet,
    required String filenameBase,
  }) {
    return ExportRequest.xlsx(sheets: [sheet], filenameBase: filenameBase);
  }

  final List<ExportSheet> sheets;
  final ExportFormat format;
  final String filenameBase;
}
