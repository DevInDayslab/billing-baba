import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:intl/intl.dart';

/// Shared formatting for export cell values.
abstract final class ExportFormatters {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  static final _numberFormat = NumberFormat('#,##0.##', 'en_IN');

  static String formatCell(Object? value, ExportCellType type) {
    if (value == null) return '';

    return switch (type) {
      ExportCellType.text => value.toString(),
      ExportCellType.number => _formatNumber(value),
      ExportCellType.currency => _formatCurrency(value),
      ExportCellType.date => _formatDate(value),
      ExportCellType.datetime => _formatDateTime(value),
    };
  }

  static String _formatNumber(Object value) {
    if (value is num) return _numberFormat.format(value);
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return _numberFormat.format(parsed);
    }
    return value.toString();
  }

  static String _formatCurrency(Object value) {
    if (value is num) return _currencyFormat.format(value);
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return _currencyFormat.format(parsed);
    }
    return value.toString();
  }

  static String _formatDate(Object value) {
    if (value is DateTime) return _dateFormat.format(value);
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return _dateFormat.format(parsed);
    }
    return value.toString();
  }

  static String _formatDateTime(Object value) {
    if (value is DateTime) return _dateTimeFormat.format(value);
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return _dateTimeFormat.format(parsed);
    }
    return value.toString();
  }

  /// Format a full row for CSV output.
  static List<String> formatRow(ExportSheet sheet, ExportRow row) {
    final cells = <String>[];
    for (var i = 0; i < sheet.columns.length; i++) {
      final column = sheet.columns[i];
      final value = i < row.cells.length ? row.cells[i] : null;
      cells.add(formatCell(value, column.type));
    }
    return cells;
  }
}
