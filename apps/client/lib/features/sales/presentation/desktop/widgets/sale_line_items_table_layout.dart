import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/sale_line_item_table_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_line_item_columns.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';

/// Shared column sizing for sale line-item tables so rows fit the viewport.
class SaleLineItemTableLayout {
  const SaleLineItemTableLayout._();

  static const cellGap = 0.0;
  static const horizontalPadding = 0.0;
  static const rowHeight = 44.0;

  /// White input chrome — matches [rowHeight] so fields fill the grid row.
  static const double cellFieldHeight = rowHeight;
  static const gridBorderColor = Color(0xFFE0E0E0);
  static const headerBackground = Color(0xFFF5F7FA);
  static const activeRowBackground = Color(0xFFE8F0FE);
  static const zebraRowBackground = Color(0xFFFAFAFA);
  static Color get confirmButtonColor => AppColors.primary;

  static SaleLineItemColumnWidths columnWidthsFor(
    double availableWidth, {
    SaleLineItemColumnVisibility visibility =
        SaleLineItemColumnVisibility.defaults,
    SaleLineItemTableSettings tableSettings = const SaleLineItemTableSettings(),
  }) {
    final contentWidth = math.max<double>(
      availableWidth - horizontalPadding * 2,
      320,
    );
    var widths = _columnWidthsFor(contentWidth);
    if (tableSettings.allowInclusiveExclusiveTax) {
      widths = widths.copyWith(price: widths.price + 76);
    }
    return widths
        .applyVisibility(visibility)
        .rescaleToFit(contentWidth, visibility);
  }

  /// Smallest width needed to render all visible columns at their floor sizes.
  static double minimumVisibleWidth(
    SaleLineItemColumnVisibility visibility,
  ) {
    return SaleLineItemColumnWidths.minimum
        .applyVisibility(visibility)
        .visibleTotalWithGaps(visibility);
  }

  static SaleLineItemColumnWidths _columnWidthsFor(double availableWidth) {
    const preferred = SaleLineItemColumnWidths.preferred;
    const gap = cellGap;
    final contentWidth = math.max<double>(
      availableWidth - horizontalPadding * 2,
      320,
    );
    final preferredTotal = preferred.totalWithGaps(gap);

    if (contentWidth >= preferredTotal) {
      final extra = contentWidth - preferredTotal;
      return preferred.copyWith(
        item: preferred.item + extra * 0.40,
        description: preferred.description + extra * 0.22,
        price: preferred.price + extra * 0.12,
        taxPercent: preferred.taxPercent + extra * 0.08,
        unit: preferred.unit + extra * 0.05,
        taxAmount: preferred.taxAmount + extra * 0.05,
        amount: preferred.amount + extra * 0.08,
      );
    }

    final scale = contentWidth / preferredTotal;
    return preferred.scaled(scale);
  }
}

class SaleLineItemColumnWidths {
  const SaleLineItemColumnWidths({
    required this.index,
    required this.item,
    required this.serial,
    required this.description,
    required this.batch,
    required this.model,
    required this.expDate,
    required this.mfgDate,
    required this.mrp,
    required this.size,
    required this.qty,
    required this.freeQty,
    required this.count,
    required this.unit,
    required this.price,
    required this.discount,
    required this.taxPercent,
    required this.taxAmount,
    required this.amount,
    required this.actions,
  });

  static const preferred = SaleLineItemColumnWidths(
    index: 28,
    item: 140,
    serial: 76,
    description: 88,
    batch: 68,
    model: 68,
    expDate: 68,
    mfgDate: 68,
    mrp: 52,
    size: 52,
    qty: 44,
    freeQty: 44,
    count: 44,
    unit: 72,
    price: 100,
    discount: 52,
    taxPercent: 72,
    taxAmount: 68,
    amount: 68,
    actions: 28,
  );

  static const _minimum = SaleLineItemColumnWidths(
    index: 20,
    item: 72,
    serial: 52,
    description: 56,
    batch: 48,
    model: 48,
    expDate: 52,
    mfgDate: 52,
    mrp: 40,
    size: 40,
    qty: 36,
    freeQty: 36,
    count: 36,
    unit: 60,
    price: 80,
    discount: 40,
    taxPercent: 68,
    taxAmount: 52,
    amount: 52,
    actions: 24,
  );

  static const SaleLineItemColumnWidths minimum = _minimum;

  final double index;
  final double item;
  final double serial;
  final double description;
  final double batch;
  final double model;
  final double expDate;
  final double mfgDate;
  final double mrp;
  final double size;
  final double qty;
  final double freeQty;
  final double count;
  final double unit;
  final double price;
  final double discount;
  final double taxPercent;
  final double taxAmount;
  final double amount;
  final double actions;

  double widthFor(SaleLineItemColumn column) => switch (column) {
    SaleLineItemColumn.serialNo => serial,
    SaleLineItemColumn.description => description,
    SaleLineItemColumn.batch => batch,
    SaleLineItemColumn.model => model,
    SaleLineItemColumn.expDate => expDate,
    SaleLineItemColumn.mfgDate => mfgDate,
    SaleLineItemColumn.mrp => mrp,
    SaleLineItemColumn.size => size,
    SaleLineItemColumn.freeQty => freeQty,
    SaleLineItemColumn.count => count,
    SaleLineItemColumn.unit => unit,
    SaleLineItemColumn.price => price,
    SaleLineItemColumn.discount => discount,
    SaleLineItemColumn.taxPercent => taxPercent,
    SaleLineItemColumn.taxAmount => taxAmount,
  };

  SaleLineItemColumnWidths applyVisibility(
    SaleLineItemColumnVisibility visibility,
  ) {
    var hiddenTotal = 0.0;
    for (final column in SaleLineItemColumn.values) {
      if (!visibility.isVisible(column)) {
        hiddenTotal += widthFor(column);
      }
    }

    if (hiddenTotal <= 0) return this;

    final growWeights = <double>[
      item,
      ...SaleLineItemColumn.values.where(visibility.isVisible).map(widthFor),
    ];
    final growTotal = growWeights.fold<double>(0, (sum, value) => sum + value);
    if (growTotal <= 0) return this;

    double grow(double current, {required bool visible}) {
      if (!visible) return 0;
      return current + hiddenTotal * (current / growTotal);
    }

    return copyWith(
      item: grow(item, visible: true),
      description: grow(
        description,
        visible: visibility.isVisible(SaleLineItemColumn.description),
      ),
      serial: grow(
        serial,
        visible: visibility.isVisible(SaleLineItemColumn.serialNo),
      ),
      batch: grow(
        batch,
        visible: visibility.isVisible(SaleLineItemColumn.batch),
      ),
      model: grow(
        model,
        visible: visibility.isVisible(SaleLineItemColumn.model),
      ),
      expDate: grow(
        expDate,
        visible: visibility.isVisible(SaleLineItemColumn.expDate),
      ),
      mfgDate: grow(
        mfgDate,
        visible: visibility.isVisible(SaleLineItemColumn.mfgDate),
      ),
      mrp: grow(mrp, visible: visibility.isVisible(SaleLineItemColumn.mrp)),
      size: grow(size, visible: visibility.isVisible(SaleLineItemColumn.size)),
      freeQty: grow(
        freeQty,
        visible: visibility.isVisible(SaleLineItemColumn.freeQty),
      ),
      count: grow(
        count,
        visible: visibility.isVisible(SaleLineItemColumn.count),
      ),
      unit: grow(unit, visible: visibility.isVisible(SaleLineItemColumn.unit)),
      price: grow(
        price,
        visible: visibility.isVisible(SaleLineItemColumn.price),
      ),
      discount: grow(
        discount,
        visible: visibility.isVisible(SaleLineItemColumn.discount),
      ),
      taxPercent: grow(
        taxPercent,
        visible: visibility.isVisible(SaleLineItemColumn.taxPercent),
      ),
      taxAmount: grow(
        taxAmount,
        visible: visibility.isVisible(SaleLineItemColumn.taxAmount),
      ),
    );
  }

  double totalWithGaps(double gap) {
    final values = _values;
    return values.fold<double>(0, (sum, value) => sum + value) +
        gap * (values.length - 1);
  }

  double visibleTotalWithGaps(
    SaleLineItemColumnVisibility visibility, {
    double gap = SaleLineItemTableLayout.cellGap,
  }) {
    final values = <double>[
      index,
      item,
      qty,
      if (visibility.isVisible(SaleLineItemColumn.freeQty)) freeQty,
      if (visibility.isVisible(SaleLineItemColumn.count)) count,
      amount,
      actions,
      for (final column in SaleLineItemColumn.values)
        if (column != SaleLineItemColumn.freeQty &&
            column != SaleLineItemColumn.count)
        if (visibility.isVisible(column)) widthFor(column),
    ];
    return values.fold<double>(0, (sum, value) => sum + value) +
        gap * (values.length - 1);
  }

  SaleLineItemColumnWidths rescaleToFit(
    double maxWidth,
    SaleLineItemColumnVisibility visibility,
  ) {
    final total = visibleTotalWithGaps(visibility);
    if (total <= maxWidth || total <= 0) return this;

    final factor = maxWidth / total;
    double scale(double value) => value * factor;

    return copyWith(
      index: scale(index),
      item: scale(item),
      serial: visibility.isVisible(SaleLineItemColumn.serialNo)
          ? scale(serial)
          : 0,
      description: visibility.isVisible(SaleLineItemColumn.description)
          ? scale(description)
          : 0,
      batch: visibility.isVisible(SaleLineItemColumn.batch) ? scale(batch) : 0,
      model: visibility.isVisible(SaleLineItemColumn.model) ? scale(model) : 0,
      expDate: visibility.isVisible(SaleLineItemColumn.expDate)
          ? scale(expDate)
          : 0,
      mfgDate: visibility.isVisible(SaleLineItemColumn.mfgDate)
          ? scale(mfgDate)
          : 0,
      mrp: visibility.isVisible(SaleLineItemColumn.mrp) ? scale(mrp) : 0,
      size: visibility.isVisible(SaleLineItemColumn.size) ? scale(size) : 0,
      qty: scale(qty),
      freeQty: visibility.isVisible(SaleLineItemColumn.freeQty)
          ? scale(freeQty)
          : 0,
      count: visibility.isVisible(SaleLineItemColumn.count) ? scale(count) : 0,
      unit: visibility.isVisible(SaleLineItemColumn.unit) ? scale(unit) : 0,
      price: visibility.isVisible(SaleLineItemColumn.price) ? scale(price) : 0,
      discount: visibility.isVisible(SaleLineItemColumn.discount)
          ? scale(discount)
          : 0,
      taxPercent: visibility.isVisible(SaleLineItemColumn.taxPercent)
          ? scale(taxPercent)
          : 0,
      taxAmount: visibility.isVisible(SaleLineItemColumn.taxAmount)
          ? scale(taxAmount)
          : 0,
      amount: scale(amount),
      actions: scale(actions),
    );
  }

  List<double> get _values => [
    index,
    item,
    serial,
    description,
    batch,
    model,
    expDate,
    mfgDate,
    mrp,
    size,
    qty,
    freeQty,
    count,
    unit,
    price,
    discount,
    taxPercent,
    taxAmount,
    amount,
    actions,
  ];

  SaleLineItemColumnWidths copyWith({
    double? index,
    double? item,
    double? serial,
    double? description,
    double? batch,
    double? model,
    double? expDate,
    double? mfgDate,
    double? mrp,
    double? size,
    double? qty,
    double? freeQty,
    double? count,
    double? unit,
    double? price,
    double? discount,
    double? taxPercent,
    double? taxAmount,
    double? amount,
    double? actions,
  }) {
    return SaleLineItemColumnWidths(
      index: index ?? this.index,
      item: item ?? this.item,
      serial: serial ?? this.serial,
      description: description ?? this.description,
      batch: batch ?? this.batch,
      model: model ?? this.model,
      expDate: expDate ?? this.expDate,
      mfgDate: mfgDate ?? this.mfgDate,
      mrp: mrp ?? this.mrp,
      size: size ?? this.size,
      qty: qty ?? this.qty,
      freeQty: freeQty ?? this.freeQty,
      count: count ?? this.count,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      taxPercent: taxPercent ?? this.taxPercent,
      taxAmount: taxAmount ?? this.taxAmount,
      amount: amount ?? this.amount,
      actions: actions ?? this.actions,
    );
  }

  SaleLineItemColumnWidths scaled(double factor) {
    double scaleValue(double preferred, double minimum) {
      return math.max(preferred * factor, minimum);
    }

    const min = _minimum;
    const pref = preferred;

    return SaleLineItemColumnWidths(
      index: scaleValue(pref.index, min.index),
      item: scaleValue(pref.item, min.item),
      serial: scaleValue(pref.serial, min.serial),
      description: scaleValue(pref.description, min.description),
      batch: scaleValue(pref.batch, min.batch),
      model: scaleValue(pref.model, min.model),
      expDate: scaleValue(pref.expDate, min.expDate),
      mfgDate: scaleValue(pref.mfgDate, min.mfgDate),
      mrp: scaleValue(pref.mrp, min.mrp),
      size: scaleValue(pref.size, min.size),
      qty: scaleValue(pref.qty, min.qty),
      freeQty: scaleValue(pref.freeQty, min.freeQty),
      count: scaleValue(pref.count, min.count),
      unit: scaleValue(pref.unit, min.unit),
      price: scaleValue(pref.price, min.price),
      discount: scaleValue(pref.discount, min.discount),
      taxPercent: scaleValue(pref.taxPercent, min.taxPercent),
      taxAmount: scaleValue(pref.taxAmount, min.taxAmount),
      amount: scaleValue(pref.amount, min.amount),
      actions: scaleValue(pref.actions, min.actions),
    );
  }
}

Color saleLineItemRowBackground({
  required bool isActive,
  required bool isOdd,
}) {
  // Neutral rows only — active state is shown via field focus / confirm control,
  // not a full-row tint (matches Add Sale grid appearance).
  return isOdd ? SaleLineItemTableLayout.zebraRowBackground : Colors.white;
}

class SaleLineItemGridCell extends StatelessWidget {
  const SaleLineItemGridCell({
    required this.width,
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
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
            right: BorderSide(color: SaleLineItemTableLayout.gridBorderColor),
          ),
        ),
        child: Padding(
          padding: padding,
          child: Align(
            alignment: alignment,
            widthFactor: 1,
            heightFactor: 1,
            child: wrapEllipsisTooltipChild(child),
          ),
        ),
      ),
    );
  }
}

class SaleLineItemGridHeaderCell extends StatelessWidget {
  const SaleLineItemGridHeaderCell({
    required this.width,
    required this.label,
    this.alignRight = false,
    super.key,
  });

  final double width;
  final String label;
  final bool alignRight;

  static const _style = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return SaleLineItemGridCell(
      width: width,
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        label,
        style: _style,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}

/// Row index cell: shows S.No. (or active bolt icon) and a delete control on hover.
class SaleLineItemIndexCell extends StatefulWidget {
  const SaleLineItemIndexCell({
    required this.rowNumber,
    required this.isActive,
    this.onDelete,
    super.key,
  });

  final int rowNumber;
  final bool isActive;
  final VoidCallback? onDelete;

  @override
  State<SaleLineItemIndexCell> createState() => _SaleLineItemIndexCellState();
}

class _SaleLineItemIndexCellState extends State<SaleLineItemIndexCell> {
  bool _isHovered = false;

  static const _indexStyle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: _isHovered && widget.onDelete != null
          ? IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(
                Icons.delete_outline,
                size: 16,
                color: AppColors.error,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Delete row',
            )
          : widget.isActive
          ? const Icon(Icons.bolt, size: 16, color: AppColors.primary)
          : Text('${widget.rowNumber}', style: _indexStyle),
    );
  }
}

class SaleLineItemConfirmButton extends StatelessWidget {
  const SaleLineItemConfirmButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SaleLineItemTableLayout.confirmButtonColor,
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(2),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: Icon(
            Icons.check,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
