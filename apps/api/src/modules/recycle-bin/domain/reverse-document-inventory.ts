import { and, eq } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { inventoryMovements } from '../../../db/schema/inventory/tables';
import { normalizeMoney, parseMoney } from '../../inventory/inventory.utils';
import { recordMovementAndUpdateStock } from '../../inventory/inventory-stock.service';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

export async function reverseInventoryForDocument(
  db: Database,
  tx: DbTransaction,
  params: {
    businessId: string;
    referenceType: 'sales_documents' | 'purchase_documents';
    referenceId: string;
    userId?: string | null;
  },
): Promise<void> {
  const movements = await tx
    .select()
    .from(inventoryMovements)
    .where(
      and(
        eq(inventoryMovements.businessId, params.businessId),
        eq(inventoryMovements.referenceType, params.referenceType),
        eq(inventoryMovements.referenceId, params.referenceId),
      ),
    );

  for (const movement of movements) {
    const delta = parseMoney(movement.quantityDelta);
    if (delta === 0) continue;

    await recordMovementAndUpdateStock(db, tx, {
      businessId: params.businessId,
      itemId: movement.itemId,
      godownId: movement.godownId,
      movementType: movement.movementType,
      quantityDelta: normalizeMoney(-delta),
      costPerUnit: movement.costPerUnit,
      unit: movement.unit,
      referenceId: params.referenceId,
      referenceType: params.referenceType,
      createdBy: params.userId ?? null,
      occurredAt: movement.createdAt,
      notes: 'Recycle bin reversal',
    });
  }
}
