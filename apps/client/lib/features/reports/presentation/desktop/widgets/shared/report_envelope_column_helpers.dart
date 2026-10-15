import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:billing_baba/features/reports/gst/definitions/gst_report_definitions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_data_row.dart';

const reportEnvelopeAmountColumnWidth = 112.0;

bool reportEnvelopeColumnIsNumeric(String key) {
  return key.contains('value') ||
      key.contains('amount') ||
      key.contains('tax') ||
      key == 'igst' ||
      key == 'cgst' ||
      key == 'sgst' ||
      key == 'cess' ||
      key == 'rate' ||
      key == 'quantity' ||
      key == 'tax_rate';
}

bool reportEnvelopeColumnUsesFlexWidth(String key) {
  return key == 'nature' ||
      key == 'label' ||
      key == 'description' ||
      key == 'party_name';
}

double? reportEnvelopeColumnFixedWidth(String key) {
  if (reportEnvelopeColumnIsNumeric(key)) return reportEnvelopeAmountColumnWidth;
  if (key == 'gstin') return 152;
  if (key.contains('date')) return 104;
  if (key == 'invoice_no' || key == 'document_no' || key == 'bill_no') {
    return 120;
  }
  if (key == 'hsn') return 88;
  if (key == 'uqc') return 72;
  return null;
}

ReportSimpleCell reportEnvelopeColumnCell({
  required GstReportColumnDef column,
  required String text,
  required TextStyle style,
}) {
  final key = column.key;
  final numeric = reportEnvelopeColumnIsNumeric(key);
  final flexLabel = reportEnvelopeColumnUsesFlexWidth(key);
  final alignment = numeric ? Alignment.centerRight : Alignment.centerLeft;

  final child = Text(
    text,
    style: style,
    textAlign: numeric ? TextAlign.right : TextAlign.left,
    softWrap: true,
    maxLines: flexLabel ? 4 : (numeric ? 1 : 2),
    overflow: flexLabel ? TextOverflow.clip : TextOverflow.ellipsis,
  );

  if (flexLabel) {
    return ReportSimpleCell(
      expanded: true,
      alignment: alignment,
      child: child,
    );
  }

  return ReportSimpleCell(
    width: reportEnvelopeColumnFixedWidth(key) ?? 120,
    alignment: alignment,
    child: child,
  );
}
