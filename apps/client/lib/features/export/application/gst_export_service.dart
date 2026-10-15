import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/export_actions.dart';
import 'package:billing_baba/features/reports/gst/definitions/gst_report_definitions.dart';
import 'package:billing_baba/features/reports/models/gst_report_type.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/export/application/adapters/report_export_adapter.dart';
import 'package:flutter/material.dart';

abstract final class GstExportService {
  static void exportCsv({
    required BuildContext context,
    required GstReportDefinition definition,
    required GstReportEnvelopeDto envelope,
    required String sectionKey,
  }) {
    final section = envelope.sections.firstWhere(
      (s) => s.key == sectionKey,
      orElse: () => envelope.sections.first,
    );
    final sectionDef =
        definition.sectionForKey(section.key) ?? definition.sections.first;
    final columns = sectionDef.columns;
    final headers = columns.map((c) => c.label).toList();
    final rows = [
      for (final row in section.rows)
        columns.map((c) => row[c.key]?.toString() ?? '').toList(),
    ];
    reportExportTable(
      context: context,
      title: section.title,
      filename: '${definition.type.title}-$sectionKey',
      headers: headers,
      rows: rows,
    );
  }

  static void exportExcel({
    required BuildContext context,
    required GstReportDefinition definition,
    required GstReportEnvelopeDto envelope,
  }) {
    final sheets = <dynamic>[];
    for (final section in envelope.sections) {
      final sectionDef = definition.sectionForKey(section.key);
      if (sectionDef == null) continue;
      final columns = sectionDef.columns;
      sheets.add(
        buildReportExportSheet(
          sheetName: section.title,
          headers: columns.map((c) => c.label).toList(),
          rows: [
            for (final row in section.rows)
              columns.map((c) => row[c.key]?.toString() ?? '').toList(),
          ],
        ),
      );
    }
    if (envelope.warnings.isNotEmpty) {
      sheets.add(
        buildReportExportSheet(
          sheetName: 'Warnings',
          headers: const ['Code', 'Message', 'Count'],
          rows: [
            for (final w in envelope.warnings) [w.code, w.message, '${w.count}'],
          ],
        ),
      );
    }
    ExportActions.exportAndNotify(
      context,
      ExportRequest.xlsx(
        sheets: sheets.cast(),
        filenameBase: definition.type.title,
      ),
    );
  }

  static void printReport({
    required BuildContext context,
    required GstReportDefinition definition,
    required GstReportEnvelopeDto envelope,
    required String sectionKey,
  }) {
    final section = envelope.sections.firstWhere(
      (s) => s.key == sectionKey,
      orElse: () => envelope.sections.first,
    );
    final sectionDef =
        definition.sectionForKey(section.key) ?? definition.sections.first;
    final columns = sectionDef.columns;
    reportPrintTable(
      context: context,
      title: section.title,
      filename: '${definition.type.title}-$sectionKey',
      headers: columns.map((c) => c.label).toList(),
      rows: [
        for (final row in section.rows)
          columns.map((c) => row[c.key]?.toString() ?? '').toList(),
      ],
    );
  }
}
