import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PurchaseSimpleDataTable extends StatelessWidget {
  const PurchaseSimpleDataTable({
    required this.columns,
    required this.rows,
    super.key,
  });

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.background),
          columns: [
            for (final col in columns)
              DataColumn(
                label: Text(
                  col.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
          rows: [
            for (final row in rows)
              DataRow(
                cells: [
                  for (final cell in row) DataCell(Text(cell)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
