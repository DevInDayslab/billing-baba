import type { MovementRecord, MovementRow } from './movement.types';

export function toMovementRecord(row: MovementRow): MovementRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    item_name: row.itemName,
    godown_id: row.godownId,
    godown_name: row.godownName,
    movement_type: row.movementType,
    quantity_delta: row.quantityDelta,
    cost_per_unit: row.costPerUnit,
    unit: row.unit,
    reference_id: row.referenceId,
    reference_type: row.referenceType,
    reference_number: row.referenceNumber,
    party_name: row.partyName,
    created_by: row.createdBy,
    created_by_name: row.createdByName,
    notes: row.notes,
    created_at: row.createdAt.toISOString(),
  };
}
