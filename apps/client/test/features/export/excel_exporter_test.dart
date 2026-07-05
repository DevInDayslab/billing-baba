import 'package:billing_baba/features/export/data/excel_exporter.dart';
import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_format.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExcelExporter', () {
    final exporter = ExcelExporter();

    ExportRequest request({
      required List<ExportSheet> sheets,
    }) {
      return ExportRequest(
        sheets: sheets,
        format: ExportFormat.xlsx,
        filenameBase: 'test',
      );
    }

    test('produces non-empty xlsx bytes with headers and typed rows', () {
      final bytes = exporter.export(
        request(
          sheets: [
            ExportSheet(
              name: 'Sales',
              columns: const [
                ExportColumn(header: 'Party'),
                ExportColumn(header: 'Amount', type: ExportCellType.currency),
                ExportColumn(header: 'Date', type: ExportCellType.date),
              ],
              rows: [
                ExportRow([
                  'शर्मा ट्रेडर्स',
                  1200.5,
                  DateTime(2026, 7, 5),
                ]),
              ],
            ),
          ],
        ),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test('supports headers-only sheet', () {
      final bytes = exporter.export(
        request(
          sheets: [
            const ExportSheet(
              name: 'Empty',
              columns: [
                ExportColumn(header: 'Date'),
                ExportColumn(header: 'Amount', type: ExportCellType.currency),
              ],
              rows: [],
            ),
          ],
        ),
      );

      expect(bytes, isNotEmpty);
    });

    test('supports multiline and comma text', () {
      final bytes = exporter.export(
        request(
          sheets: [
            const ExportSheet(
              name: 'Notes',
              columns: [ExportColumn(header: 'Note')],
              rows: [
                ExportRow(['Line1\nLine2, with comma']),
              ],
            ),
          ],
        ),
      );

      expect(bytes, isNotEmpty);
    });

    test('supports multiple worksheets', () {
      final bytes = exporter.export(
        request(
          sheets: [
            const ExportSheet(
              name: 'SheetA',
              columns: [ExportColumn(header: 'A')],
              rows: [ExportRow(['1'])],
            ),
            const ExportSheet(
              name: 'SheetB',
              columns: [ExportColumn(header: 'B')],
              rows: [ExportRow(['2'])],
            ),
          ],
        ),
      );

      expect(bytes, isNotEmpty);
    });

    test('handles large row counts', () {
      final rows = <ExportRow>[
        for (var i = 0; i < 1000; i++) ExportRow(['Row $i', i * 10.5]),
      ];

      final bytes = exporter.export(
        request(
          sheets: [
            ExportSheet(
              name: 'Large',
              columns: const [
                ExportColumn(header: 'Label'),
                ExportColumn(header: 'Value', type: ExportCellType.number),
              ],
              rows: rows,
            ),
          ],
        ),
      );

      expect(bytes.length, greaterThan(5000));
    });
  });
}
