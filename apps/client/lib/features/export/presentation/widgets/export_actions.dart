import 'package:billing_baba/core/utils/output_error_mapper.dart';
import 'package:billing_baba/features/export/application/export_exception.dart';
import 'package:billing_baba/features/export/application/export_output_service.dart';
import 'package:billing_baba/features/export/application/export_service.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/presentation/providers/export_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI helpers for save/share export via [ExportService].
abstract final class ExportActions {
  static Future<void> save(
    BuildContext context,
    ExportRequest request,
  ) {
    return _run(context, (service, output) async {
      final file = service.generate(request);
      final path = await output.save(file);
      if (!context.mounted) return;
      final message = path != null ? 'Saved to $path' : 'File saved';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  static Future<void> share(
    BuildContext context,
    ExportRequest request,
  ) {
    return _run(context, (service, output) async {
      final file = service.generate(request);
      await output.share(file);
    });
  }

  /// Generate and save on desktop, share on mobile.
  static Future<void> exportAndNotify(
    BuildContext context,
    ExportRequest request,
  ) {
    return _run(context, (service, output) async {
      final file = service.generate(request);
      final path = await output.exportAndNotify(file: file);
      if (!context.mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export ready to share')),
        );
      }
    });
  }

  static Future<void> exportXlsx(
    BuildContext context, {
    required ExportSheet sheet,
    required String filenameBase,
  }) {
    return exportAndNotify(
      context,
      ExportRequest.xlsxSingle(sheet: sheet, filenameBase: filenameBase),
    );
  }

  static Future<void> exportCsv(
    BuildContext context, {
    required ExportSheet sheet,
    required String filenameBase,
  }) {
    return exportAndNotify(
      context,
      ExportRequest.csv(sheet: sheet, filenameBase: filenameBase),
    );
  }

  static Future<void> exportReportXlsx(
    BuildContext context, {
    required String sheetName,
    required String filenameBase,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return exportXlsx(
      context,
      sheet: ExportSheet.fromStrings(
        name: sheetName,
        headers: headers,
        rows: rows,
      ),
      filenameBase: filenameBase,
    );
  }

  static Future<void> exportReportCsv(
    BuildContext context, {
    required String sheetName,
    required String filenameBase,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return exportCsv(
      context,
      sheet: ExportSheet.fromStrings(
        name: sheetName,
        headers: headers,
        rows: rows,
      ),
      filenameBase: filenameBase,
    );
  }

  static Future<void> _run(
    BuildContext context,
    Future<void> Function(
      ExportService service,
      ExportOutputService output,
    )
    action,
  ) async {
    try {
      final container = ProviderScope.containerOf(context);
      final service = container.read(exportServiceProvider);
      final output = container.read(exportOutputServiceProvider);
      await action(service, output);
    } on ExportException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OutputErrorMapper.exportMessage(error))),
      );
    }
  }
}
