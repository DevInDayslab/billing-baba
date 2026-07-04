import { and, asc, count, desc, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  godowns,
  inventoryMovements,
  items,
} from '../../db/schema/inventory/tables';
import { toMovementRecord } from './movement.mapper';
import type {
  ListMovementsParams,
  MovementRecord,
  MovementRow,
} from './movement.types';

export class MovementRepository {
  constructor(private readonly db: Database) {}

  private selectShape() {
    return {
      id: inventoryMovements.id,
      itemId: inventoryMovements.itemId,
      itemName: items.name,
      godownId: inventoryMovements.godownId,
      godownName: godowns.name,
      movementType: inventoryMovements.movementType,
      quantityDelta: inventoryMovements.quantityDelta,
      costPerUnit: inventoryMovements.costPerUnit,
      referenceId: inventoryMovements.referenceId,
      referenceType: inventoryMovements.referenceType,
      createdBy: inventoryMovements.createdBy,
      createdAt: inventoryMovements.createdAt,
    };
  }

  async list(params: ListMovementsParams): Promise<{
    rows: MovementRecord[];
    total: number;
  }> {
    const filters = [
      eq(inventoryMovements.businessId, params.businessId),
      eq(items.isDeleted, false),
      eq(godowns.isDeleted, false),
    ];

    if (params.itemId) {
      filters.push(eq(inventoryMovements.itemId, params.itemId));
    }

    if (params.godownId) {
      filters.push(eq(inventoryMovements.godownId, params.godownId));
    }

    if (params.movementType) {
      filters.push(eq(inventoryMovements.movementType, params.movementType));
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(inventoryMovements)
      .innerJoin(items, eq(inventoryMovements.itemId, items.id))
      .innerJoin(godowns, eq(inventoryMovements.godownId, godowns.id))
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);
    const orderBy =
      params.order === 'desc'
        ? desc(inventoryMovements.createdAt)
        : asc(inventoryMovements.createdAt);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select(this.selectShape())
      .from(inventoryMovements)
      .innerJoin(items, eq(inventoryMovements.itemId, items.id))
      .innerJoin(godowns, eq(inventoryMovements.godownId, godowns.id))
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toMovementRecord(row as MovementRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    movementId: string,
  ): Promise<MovementRecord | null> {
    const [row] = await this.db
      .select(this.selectShape())
      .from(inventoryMovements)
      .innerJoin(items, eq(inventoryMovements.itemId, items.id))
      .innerJoin(godowns, eq(inventoryMovements.godownId, godowns.id))
      .where(
        and(
          eq(inventoryMovements.id, movementId),
          eq(inventoryMovements.businessId, businessId),
          eq(items.isDeleted, false),
          eq(godowns.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toMovementRecord(row as MovementRow) : null;
  }

  runTransaction<T>(
    callback: (
      tx: Parameters<Parameters<Database['transaction']>[0]>[0],
    ) => Promise<T>,
  ): Promise<T> {
    return this.db.transaction(callback);
  }
}
