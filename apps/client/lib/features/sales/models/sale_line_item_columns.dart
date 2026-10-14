/// Toggleable columns in the Add Sale line-items grid.
///
/// [item], [qty], and [amount] are always shown and are not part of this enum.
enum SaleLineItemColumn {
  serialNo,
  description,
  batch,
  model,
  expDate,
  mfgDate,
  mrp,
  size,
  unit,
  price,
  discount,
  taxPercent,
  taxAmount;

  String get label => switch (this) {
    SaleLineItemColumn.serialNo => 'Serial No.',
    SaleLineItemColumn.description => 'Description',
    SaleLineItemColumn.batch => 'Batch No.',
    SaleLineItemColumn.model => 'Model No.',
    SaleLineItemColumn.expDate => 'Exp. Date',
    SaleLineItemColumn.mfgDate => 'Mfg. Date',
    SaleLineItemColumn.mrp => 'MRP',
    SaleLineItemColumn.size => 'Size',
    SaleLineItemColumn.unit => 'Unit',
    SaleLineItemColumn.price => 'Price/Unit',
    SaleLineItemColumn.discount => 'Discount',
    SaleLineItemColumn.taxPercent => 'Tax %',
    SaleLineItemColumn.taxAmount => 'Tax Amount',
  };

  String get storageKey => name;
}

/// Which optional line-item columns are visible in the Add Sale grid.
class SaleLineItemColumnVisibility {
  const SaleLineItemColumnVisibility(this._visible);

  /// Matches the current always-on grid before the discount column was added.
  static const defaults = SaleLineItemColumnVisibility({
    SaleLineItemColumn.serialNo,
    SaleLineItemColumn.description,
    SaleLineItemColumn.batch,
    SaleLineItemColumn.model,
    SaleLineItemColumn.expDate,
    SaleLineItemColumn.mfgDate,
    SaleLineItemColumn.mrp,
    SaleLineItemColumn.size,
    SaleLineItemColumn.unit,
    SaleLineItemColumn.price,
    SaleLineItemColumn.taxPercent,
    SaleLineItemColumn.taxAmount,
  });

  final Set<SaleLineItemColumn> _visible;

  bool isVisible(SaleLineItemColumn column) => _visible.contains(column);

  Iterable<SaleLineItemColumn> get visibleColumns =>
      SaleLineItemColumn.values.where(isVisible);

  SaleLineItemColumnVisibility toggle(SaleLineItemColumn column) {
    final next = Set<SaleLineItemColumn>.from(_visible);
    if (next.contains(column)) {
      next.remove(column);
    } else {
      next.add(column);
    }
    return SaleLineItemColumnVisibility(next);
  }

  String encode() => _visible.map((c) => c.storageKey).join(',');

  /// Gates tax/discount columns by Item Settings and GST tax settings.
  SaleLineItemColumnVisibility applyItemSettings({
    required bool itemWiseTax,
    required bool itemWiseDiscount,
    required bool allowsTransactionTaxes,
  }) {
    final next = Set<SaleLineItemColumn>.from(_visible);
    if (itemWiseTax && allowsTransactionTaxes) {
      next.add(SaleLineItemColumn.taxPercent);
      next.add(SaleLineItemColumn.taxAmount);
    } else {
      next.remove(SaleLineItemColumn.taxPercent);
      next.remove(SaleLineItemColumn.taxAmount);
    }
    if (itemWiseDiscount) {
      next.add(SaleLineItemColumn.discount);
    } else {
      next.remove(SaleLineItemColumn.discount);
    }
    return SaleLineItemColumnVisibility(next);
  }

  static SaleLineItemColumnVisibility decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return defaults;

    final parsed = <SaleLineItemColumn>{};
    for (final part in raw.split(',')) {
      final key = part.trim();
      if (key.isEmpty) continue;
      for (final column in SaleLineItemColumn.values) {
        if (column.storageKey == key) {
          parsed.add(column);
          break;
        }
      }
    }

    return parsed.isEmpty ? defaults : SaleLineItemColumnVisibility(parsed);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleLineItemColumnVisibility &&
          _visible.length == other._visible.length &&
          _visible.containsAll(other._visible);

  @override
  int get hashCode => Object.hashAllUnordered(_visible);
}
