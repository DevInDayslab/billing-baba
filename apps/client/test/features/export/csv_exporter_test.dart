import 'dart:convert';

import 'package:billing_baba/features/export/data/csv_exporter.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvExporter', () {
    final exporter = CsvExporter();

    test('prefixes UTF-8 BOM', () {
      final bytes = exporter.export(
        ExportRequest.csv(
          sheet: ExportSheet.fromStrings(
            name: 'Test',
            headers: const ['Name'],
            rows: const [
              ['Acme'],
            ],
          ),
          filenameBase: 'test',
        ),
      );

      expect(bytes.length, greaterThanOrEqualTo(3));
      expect(bytes[0], 0xEF);
      expect(bytes[1], 0xBB);
      expect(bytes[2], 0xBF);
    });

    test('escapes commas and quotes', () {
      final bytes = exporter.export(
        ExportRequest.csv(
          sheet: ExportSheet.fromStrings(
            name: 'Test',
            headers: const ['Party', 'Note'],
            rows: const [
              ['Acme, Ltd', 'Said "hello"'],
            ],
          ),
          filenameBase: 'test',
        ),
      );

      final text = utf8.decode(bytes);
      expect(text, contains('Acme, Ltd'));
      expect(text, contains('"Said ""hello"""'));
    });

    test('escapes multiline text', () {
      final bytes = exporter.export(
        ExportRequest.csv(
          sheet: ExportSheet.fromStrings(
            name: 'Test',
            headers: const ['Note'],
            rows: const [
              ['Line1\nLine2'],
            ],
          ),
          filenameBase: 'test',
        ),
      );

      final text = utf8.decode(bytes);
      expect(text, contains('"Line1\nLine2"'));
    });

    test('preserves Unicode rupee and Devanagari', () {
      final bytes = exporter.export(
        ExportRequest.csv(
          sheet: ExportSheet.fromStrings(
            name: 'Test',
            headers: const ['Party', 'Amount'],
            rows: const [
              ['शर्मा ट्रेडर्स', '₹1,200.00'],
            ],
          ),
          filenameBase: 'test',
        ),
      );

      final text = utf8.decode(bytes);
      expect(text, contains('शर्मा ट्रेडर्स'));
      expect(text, contains('₹1,200.00'));
    });

    test('empty sheet returns BOM only', () {
      final bytes = exporter.export(
        ExportRequest.csv(
          sheet: const ExportSheet(name: 'Empty', columns: [], rows: []),
          filenameBase: 'empty',
        ),
      );

      expect(bytes.length, greaterThanOrEqualTo(3));
      expect(bytes[0], 0xEF);
      expect(bytes[1], 0xBB);
      expect(bytes[2], 0xBF);
    });
  });
}
