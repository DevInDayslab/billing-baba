import type {
  ItemSupplierRecord,
  ItemSupplierRow,
} from './item-supplier.types';

export function toItemSupplierRecord(row: ItemSupplierRow): ItemSupplierRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    party_id: row.partyId,
    is_default: row.isDefault,
    sort_order: row.sortOrder,
    party: {
      id: row.partyId,
      name: row.partyName,
      mobile: row.partyMobile,
      party_type: row.partyType,
    },
  };
}
