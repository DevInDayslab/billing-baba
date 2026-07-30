import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';

/// Tabular data for one export sheet (CSV section or Excel worksheet).
class ExportSheet {
  const ExportSheet({
    required this.name,
    required this.columns,
    required this.rows,
  });

  /// Build from plain string headers and rows (reports compatibility).
  factory ExportSheet.fromStrings({
    required String name,
    required List<String> headers,
    required List<List<String>> rows,
    List<ExportCellType>? columnTypes,
  }) {
    final columns = [
      for (var i = 0; i < headers.length; i++)
        ExportColumn(
          header: headers[i],
          type: columnTypes != null && i < columnTypes.length
              ? columnTypes[i]
              : ExportCellType.text,
        ),
    ];
    return ExportSheet(
      name: name,
      columns: columns,
      rows: [
        for (final row in rows)
          ExportRow([
            for (final cell in row) cell,
          ]),
      ],
    );
  }

  final String name;
  final List<ExportColumn> columns;
  final List<ExportRow> rows;
}
