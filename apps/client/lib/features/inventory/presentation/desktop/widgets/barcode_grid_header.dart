import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/barcode_items_grid.dart';
import 'package:flutter/material.dart';

/// Column header row for the barcode import spreadsheet grid.
class BarcodeGridHeader extends StatelessWidget {
  const BarcodeGridHeader({
    required this.columnWidths,
    super.key,
  });

  final BarcodeGridColumnWidths columnWidths;

  static const _labelStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: BarcodeGridLayout.headerBackground,
        border: Border(
          bottom: BorderSide(color: BarcodeGridLayout.gridBorderColor),
        ),
      ),
      child: SizedBox(
        height: BarcodeGridLayout.rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderCell(width: columnWidths.index, label: '#'),
            _HeaderCell(width: columnWidths.itemCode, label: 'ITEM CODE'),
            _HeaderCell(width: columnWidths.itemName, label: 'ITEM NAME*'),
            _HeaderCell(width: columnWidths.category, label: 'CATEGORY'),
            _HeaderCell(width: columnWidths.hsnCode, label: 'HSN CODE'),
            _HeaderCell(
              width: columnWidths.defaultMrp,
              label: 'DEFAULT MRP(₹)',
            ),
            _HeaderCell(
              width: columnWidths.salePrice,
              label: 'SALE PRICE(₹)',
            ),
            _HeaderCell(width: columnWidths.incTax, label: 'INC. TAX'),
            _HeaderCell(width: columnWidths.taxPercent, label: 'TAX(%)'),
            _HeaderCell(
              width: columnWidths.baseUnit,
              label: 'BASE UNIT',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.width,
    required this.label,
    this.isLast = false,
  });

  final double width;
  final String label;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    if (isLast) {
      return SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: BarcodeGridHeader._labelStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      );
    }

    return BarcodeGridCell(
      width: width,
      child: Text(
        label,
        style: BarcodeGridHeader._labelStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}
