import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/data/item_settings_usage_local_source.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/models/item_settings_restriction_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ItemSettingsRestriction {
  enableItemInUse,
  itemUnitsInUse,
}

extension ItemSettingsRestrictionMessage on ItemSettingsRestriction {
  String get message => switch (this) {
    ItemSettingsRestriction.enableItemInUse =>
      ItemSettingsRestrictionMessages.enableItemInUse,
    ItemSettingsRestriction.itemUnitsInUse =>
      ItemSettingsRestrictionMessages.itemUnitsInUse,
  };
}

final itemSettingsGuardProvider = Provider<ItemSettingsGuard>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ItemSettingsGuard(ItemSettingsUsageLocalSource(db), ref);
});

class ItemSettingsGuard {
  ItemSettingsGuard(this._usage, this._ref);

  final ItemSettingsUsageLocalSource _usage;
  final Ref _ref;

  String get _businessId => _ref.read(currentBusinessProvider)?.id ?? '';

  Future<ItemSettingsRestriction?> restrictionForPatch(
    ItemSettings current,
    ItemSettings next,
  ) async {
    if (current.enableItem && !next.enableItem) {
      if (await _usage.hasActiveItems(_businessId) ||
          await _usage.hasItemLinesInDocuments(_businessId)) {
        return ItemSettingsRestriction.enableItemInUse;
      }
    }

    if (current.itemUnits && !next.itemUnits) {
      if (await _usage.hasItemUnitUsageInTransactions(_businessId)) {
        return ItemSettingsRestriction.itemUnitsInUse;
      }
    }

    return null;
  }
}
