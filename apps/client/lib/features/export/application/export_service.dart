import 'package:billing_baba/features/export/application/export_exception.dart';
import 'package:billing_baba/features/export/data/csv_exporter.dart';
import 'package:billing_baba/features/export/data/excel_exporter.dart';
import 'package:billing_baba/features/export/models/export_file.dart';
import 'package:billing_baba/features/export/models/export_format.dart';
import 'package:billing_baba/features/export/models/export_request.dart';

/// Orchestrates export generation via format-specific exporters.
class ExportService {
  ExportService({
    CsvExporter? csvExporter,
    ExcelExporter? excelExporter,
  }) : _csvExporter = csvExporter ?? CsvExporter(),
       _excelExporter = excelExporter ?? ExcelExporter();

  final CsvExporter _csvExporter;
  final ExcelExporter _excelExporter;

  ExportFile generate(ExportRequest request) {
    if (request.sheets.isEmpty) {
      throw ExportException('No data to export');
    }

    return switch (request.format) {
      ExportFormat.csv => _csvExporter.exportFile(request),
      ExportFormat.xlsx => _excelExporter.exportFile(request),
    };
  }
}
