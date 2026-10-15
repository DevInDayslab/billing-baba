import 'package:billing_baba/features/export/application/adapters/report_export_adapter.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/export_actions.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/tax/definitions/tax_report_definitions.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:flutter/material.dart';

/// Excel/CSV export for definition-driven tax (and shared envelope) reports.
abstract final class DefinitionReportExportService {
  static void exportExcel({
    required BuildContext context,
    required TaxReportDefinition definition,
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
            for (final w in envelope.warnings)
              [w.code, w.message, '${w.count}'],
          ],
        ),
      );
    }
    ExportActions.exportAndNotify(
      context,
      ExportRequest.xlsx(
        sheets: sheets.cast(),
        filenameBase: definition.title,
      ),
    );
  }

  static void exportCsvSection({
    required BuildContext context,
    required TaxReportDefinition definition,
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
    reportExportTable(
      context: context,
      title: section.title,
      filename: '${definition.title}-$sectionKey',
      headers: columns.map((c) => c.label).toList(),
      rows: [
        for (final row in section.rows)
          columns.map((c) => row[c.key]?.toString() ?? '').toList(),
      ],
    );
  }
}
