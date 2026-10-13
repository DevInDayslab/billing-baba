/// User-facing copy when item settings cannot be turned off due to live data.
abstract final class ItemSettingsRestrictionMessages {
  /// [ItemSettings.enableItem] — items exist or appear on transaction lines.
  static const enableItemInUse =
      'Item cannot be disabled as Item unit being used in Transactions.';

  /// [ItemSettings.itemUnits] — units appear on saved transaction lines.
  static const itemUnitsInUse = enableItemInUse;
}
