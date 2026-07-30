import { and, eq } from 'drizzle-orm';
import type { Database } from '../../../../db/client';
import { inventoryMovements } from '../../../../db/schema/inventory/tables';
import { AppError } from '../../../../shared/errors/app-error';
import { recordMovementAndUpdateStock } from '../../../inventory/inventory-stock.service';
import { ItemRepository } from '../../../inventory/item.repository';
import { normalizeMoney } from '../../../inventory/inventory.utils';
import { stockAdjustmentPayloadSchema } from './stock-adjustment.schema';
import type {
  CommandApplyOutcome,
  CommandHandler,
  CommandMutationInput,
} from './command.types';

export const stockAdjustmentHandler: CommandHandler = async (db, input) => {
  const parsed = stockAdjustmentPayloadSchema.safeParse(input.payload);
  if (!parsed.success) {
    return validationError(
      input,
      parsed.error.issues[0]?.message ?? 'Invalid stock_adjustment payload',
    );
  }

  const { adjustment_id: adjustmentId, godown_id: godownId, lines } =
    parsed.data;

  const existing = await db
    .select({
      id: inventoryMovements.id,
      itemId: inventoryMovements.itemId,
    })
    .from(inventoryMovements)
    .where(
      and(
        eq(inventoryMovements.businessId, input.businessId),
        eq(inventoryMovements.referenceType, 'stock_adjustment'),
        eq(inventoryMovements.referenceId, adjustmentId),
      ),
    );

  if (existing.length > 0) {
    return {
      status: 'accepted',
      result: {
        mutation_id: input.mutationId,
        kind: 'command',
        command: input.command,
        command_id: input.commandId,
        sync_version: 0,
        server_updated_at: new Date().toISOString(),
        result: {
          adjustment_id: adjustmentId,
          status: 'completed',
          movement_ids: existing.map((row) => ({
            item_id: row.itemId,
            movement_id: row.id,
          })),
        },
      },
    };
  }

  const itemRepository = new ItemRepository(db);
  const godownExists = await itemRepository.godownExists(
    input.businessId,
    godownId,
  );
  if (!godownExists) {
    return validationError(input, 'Godown not found');
  }

  const movementIds: { item_id: string; movement_id: string }[] = [];

  try {
    await db.transaction(async (tx) => {
      for (const line of lines) {
        const item = await itemRepository.findRowById(
          input.businessId,
          line.item_id,
        );
        if (!item) {
          throw new AppError('VALIDATION_ERROR', 'Item not found', 422);
        }
        if (!item.hasStockTracking) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Stock movements are not allowed for this item',
            422,
          );
        }

        const quantityDelta = normalizeMoney(line.quantity_delta);
        if (Number(quantityDelta) === 0) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Quantity delta must not be zero',
            422,
          );
        }

        if (Number(quantityDelta) > 0 && !line.cost_per_unit) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Cost per unit is required for positive adjustments',
            422,
          );
        }

        const result = await recordMovementAndUpdateStock(db, tx, {
          businessId: input.businessId,
          itemId: line.item_id,
          godownId,
          movementType: 'adjustment',
          quantityDelta,
          costPerUnit: line.cost_per_unit ?? null,
          unit: item.baseUnit,
          referenceId: adjustmentId,
          referenceType: 'stock_adjustment',
          createdBy: input.userId ?? null,
          notes: line.reason ?? null,
        });

        movementIds.push({
          item_id: line.item_id,
          movement_id: result.movementId,
        });
      }
    });
  } catch (error) {
    return mapAdjustmentError(input, error);
  }

  return {
    status: 'accepted',
    result: {
      mutation_id: input.mutationId,
      kind: 'command',
      command: input.command,
      command_id: input.commandId,
      sync_version: 0,
      server_updated_at: new Date().toISOString(),
      result: {
        adjustment_id: adjustmentId,
        status: 'completed',
        movement_ids: movementIds,
      },
    },
  };
};

function validationError(
  input: CommandMutationInput,
  message: string,
): CommandApplyOutcome {
  return {
    status: 'error',
    result: {
      mutation_id: input.mutationId,
      code: 'VALIDATION_FAILED',
      message,
    },
  };
}

function mapAdjustmentError(
  input: CommandMutationInput,
  error: unknown,
): CommandApplyOutcome {
  if (error instanceof AppError) {
    return {
      status: 'error',
      result: {
        mutation_id: input.mutationId,
        code: error.code,
        message: error.message,
        details: error.errors ?? undefined,
      },
    };
  }

  return {
    status: 'error',
    result: {
      mutation_id: input.mutationId,
      code: 'INTERNAL_ERROR',
      message: error instanceof Error ? error.message : 'Stock adjustment failed',
    },
  };
}
