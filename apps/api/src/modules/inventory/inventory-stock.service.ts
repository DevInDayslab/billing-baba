import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  godowns,
  inventoryMovements,
  stockLevels,
} from '../../db/schema/inventory/tables';
import { AppError } from '../../shared/errors/app-error';
import {
  calculateMovingAverageCost,
  normalizeMoney,
  parseMoney,
} from './inventory.utils';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

export type RecordMovementParams = {
  businessId: string;
  itemId: string;
  godownId: string;
  movementType:
    | 'opening'
    | 'purchase'
    | 'sale'
    | 'sales_return'
    | 'purchase_return'
    | 'challan'
    | 'adjustment';
  quantityDelta: string;
  costPerUnit?: string | null;
  referenceId?: string | null;
  referenceType?: string | null;
  createdBy?: string | null;
  occurredAt?: Date | null;
};

export type GodownRow = {
  id: string;
  name: string;
  isDefault: boolean;
};

export async function getDefaultGodown(
  db: Database | DbTransaction,
  businessId: string,
): Promise<GodownRow> {
  const [godown] = await db
    .select({
      id: godowns.id,
      name: godowns.name,
      isDefault: godowns.isDefault,
    })
    .from(godowns)
    .where(
      and(
        eq(godowns.businessId, businessId),
        eq(godowns.isDefault, true),
        eq(godowns.isDeleted, false),
      ),
    )
    .limit(1);

  if (!godown) {
    throw new AppError(
      'DEFAULT_GODOWN_NOT_FOUND',
      'Default godown not found for this business',
      422,
    );
  }

  return godown;
}

export async function recordMovementAndUpdateStock(
  _db: Database,
  tx: DbTransaction,
  params: RecordMovementParams,
): Promise<{ movementId: string; stockLevelId: string }> {
  const quantityDelta = normalizeMoney(params.quantityDelta);
  const delta = parseMoney(quantityDelta);

  if (delta === 0) {
    throw new AppError(
      'VALIDATION_ERROR',
      'Quantity delta must not be zero',
      400,
      { quantity_delta: ['Quantity delta must not be zero'] },
    );
  }

  const [existingStock] = await tx
    .select({
      id: stockLevels.id,
      quantity: stockLevels.quantity,
      averageCost: stockLevels.averageCost,
    })
    .from(stockLevels)
    .where(
      and(
        eq(stockLevels.businessId, params.businessId),
        eq(stockLevels.itemId, params.itemId),
        eq(stockLevels.godownId, params.godownId),
        eq(stockLevels.isDeleted, false),
      ),
    )
    .limit(1);

  const currentQty = existingStock?.quantity ?? '0';
  const currentAvg = existingStock?.averageCost ?? '0';
  const newQty = parseMoney(currentQty) + delta;

  if (newQty < 0) {
    throw new AppError(
      'INSUFFICIENT_STOCK',
      'Insufficient stock for this movement',
      422,
    );
  }

  const costPerUnit =
    params.costPerUnit !== undefined && params.costPerUnit !== null
      ? normalizeMoney(params.costPerUnit)
      : null;

  const [movement] = await tx
    .insert(inventoryMovements)
    .values({
      businessId: params.businessId,
      itemId: params.itemId,
      godownId: params.godownId,
      movementType: params.movementType,
      quantityDelta,
      costPerUnit,
      referenceId: params.referenceId ?? null,
      referenceType: params.referenceType ?? null,
      createdBy: params.createdBy ?? null,
      createdAt: params.occurredAt ?? new Date(),
    })
    .returning({ id: inventoryMovements.id });

  if (!movement) {
    throw new Error('Failed to record inventory movement');
  }

  const newAverageCost = calculateMovingAverageCost(
    currentQty,
    currentAvg,
    quantityDelta,
    costPerUnit,
  );

  if (existingStock) {
    const [updated] = await tx
      .update(stockLevels)
      .set({
        quantity: normalizeMoney(newQty),
        averageCost: newAverageCost,
        updatedAt: new Date(),
      })
      .where(eq(stockLevels.id, existingStock.id))
      .returning({ id: stockLevels.id });

    if (!updated) {
      throw new Error('Failed to update stock level');
    }

    return { movementId: movement.id, stockLevelId: updated.id };
  }

  const [created] = await tx
    .insert(stockLevels)
    .values({
      businessId: params.businessId,
      itemId: params.itemId,
      godownId: params.godownId,
      quantity: normalizeMoney(newQty),
      averageCost: newAverageCost,
    })
    .returning({ id: stockLevels.id });

  if (!created) {
    throw new Error('Failed to create stock level');
  }

  return { movementId: movement.id, stockLevelId: created.id };
}
