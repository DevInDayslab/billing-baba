import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/barcode_import_provider.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/barcode_grid_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/barcode_grid_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proportional column widths shared by header and data rows.
class BarcodeGridColumnWidths {
  const BarcodeGridColumnWidths({
    required this.index,
    required this.itemCode,
    required this.itemName,
    required this.category,
    required this.hsnCode,
    required this.defaultMrp,
    required this.salePrice,
    required this.incTax,
    required this.taxPercent,
    required this.baseUnit,
  });

  final double index;
  final double itemCode;
  final double itemName;
  final double category;
  final double hsnCode;
  final double defaultMrp;
  final double salePrice;
  final double incTax;
  final double taxPercent;
  final double baseUnit;

  double get totalWidth =>
      index +
      itemCode +
      itemName +
      category +
      hsnCode +
      defaultMrp +
      salePrice +
      incTax +
      taxPercent +
      baseUnit;
}

/// Fixed column sizing for the barcode import spreadsheet grid.
abstract final class BarcodeGridLayout {
  static const gridBorderColor = Color(0xFFE0E0E0);
  static const headerBackground = Color(0xFFF5F7FA);
  static const activeRowBackground = Color(0xFFE8F0FE);
  static const Color activeRowBorderColor = AppColors.primary;
  static const rowHeight = 40.0;
  static const placeholderColor = Color(0xFFBDBDBD);

  static const minTotalWidth = 900.0;
  static const indexWidth = 40.0;

  static const flexItemCode = 2.0;
  static const flexItemName = 3.0;
  static const flexCategory = 2.0;
  static const flexHsnCode = 1.5;
  static const flexDefaultMrp = 1.5;
  static const flexSalePrice = 1.5;
  static const flexIncTax = 1.0;
  static const flexTaxPercent = 1.0;
  static const flexBaseUnit = 1.5;

  static const double _totalFlex =
      flexItemCode +
      flexItemName +
      flexCategory +
      flexHsnCode +
      flexDefaultMrp +
      flexSalePrice +
      flexIncTax +
      flexTaxPercent +
      flexBaseUnit;

  static BarcodeGridColumnWidths columnWidthsFor(double availableWidth) {
    final contentWidth = math.max(availableWidth, minTotalWidth);
    final flexSpace = contentWidth - indexWidth;

    double flexColumn(double flex) => flexSpace * flex / _totalFlex;

    return BarcodeGridColumnWidths(
      index: indexWidth,
      itemCode: flexColumn(flexItemCode),
      itemName: flexColumn(flexItemName),
      category: flexColumn(flexCategory),
      hsnCode: flexColumn(flexHsnCode),
      defaultMrp: flexColumn(flexDefaultMrp),
      salePrice: flexColumn(flexSalePrice),
      incTax: flexColumn(flexIncTax),
      taxPercent: flexColumn(flexTaxPercent),
      baseUnit: flexColumn(flexBaseUnit),
    );
  }
}

/// Spreadsheet-style grid for bulk barcode item entry.
class BarcodeItemsGrid extends ConsumerStatefulWidget {
  const BarcodeItemsGrid({
    required this.rows,
    required this.activeRowIndex,
    this.onFieldChanged,
    this.onSetManualEntry,
    super.key,
  });

  final List<BarcodeImportRow> rows;
  final int activeRowIndex;
  final void Function(int rowIndex, String field, String value)? onFieldChanged;
  final void Function(int rowIndex)? onSetManualEntry;

  @override
  ConsumerState<BarcodeItemsGrid> createState() => _BarcodeItemsGridState();
}

class _BarcodeItemsGridState extends ConsumerState<BarcodeItemsGrid> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: BarcodeGridLayout.gridBorderColor),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final columnWidths =
              BarcodeGridLayout.columnWidthsFor(availableWidth);
          final needsHorizontalScroll =
              availableWidth < BarcodeGridLayout.minTotalWidth;

          final grid = SizedBox(
            width: columnWidths.totalWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarcodeGridHeader(columnWidths: columnWidths),
                for (final row in widget.rows)
                  BarcodeGridRow(
                    row: row,
                    rowNumber: row.index + 1,
                    isActive: row.index == widget.activeRowIndex,
                    columnWidths: columnWidths,
                    onFieldChanged: widget.onFieldChanged,
                    onSetManualEntry: widget.onSetManualEntry,
                    onDelete: () => ref
                        .read(barcodeImportProvider.notifier)
                        .deleteRow(row.index),
                  ),
              ],
            ),
          );

          return SingleChildScrollView(
            controller: _verticalController,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: needsHorizontalScroll
                  ? null
                  : const NeverScrollableScrollPhysics(),
              child: grid,
            ),
          );
        },
      ),
    );
  }
}

/// Shared cell wrapper for header and data rows.
class BarcodeGridCell extends StatelessWidget {
  const BarcodeGridCell({
    required this.width,
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    super.key,
  });

  final double width;
  final Widget child;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: BarcodeGridLayout.gridBorderColor),
          ),
        ),
        child: Padding(
          padding: padding,
          child: Align(
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }
}
