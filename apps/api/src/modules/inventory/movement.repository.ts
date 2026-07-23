import { and, asc, count, desc, eq, sql } from 'drizzle-orm';
import { alias } from 'drizzle-orm/pg-core';
import type { Database } from '../../db/client';
import { parties } from '../../db/schema/crm/tables';
import { users } from '../../db/schema/identity/tables';
import {
  godowns,
  inventoryMovements,
  items,
} from '../../db/schema/inventory/tables';
import { purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import { toMovementRecord } from './movement.mapper';
import type {
  ListMovementsParams,
  MovementRecord,
  MovementRow,
} from './movement.types';

const salesParty = alias(parties, 'sales_party');
const purchaseParty = alias(parties, 'purchase_party');

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
      unit: inventoryMovements.unit,
      referenceId: inventoryMovements.referenceId,
      referenceType: inventoryMovements.referenceType,
      referenceNumber: sql<string | null>`COALESCE(
        ${salesDocuments.documentNumber},
        ${purchaseDocuments.documentNumber},
        CASE
          WHEN ${inventoryMovements.referenceType} = 'items'
            AND ${inventoryMovements.movementType} = 'opening'
          THEN COALESCE(NULLIF(${items.barcode}, ''), 'Opening')
          ELSE NULL
        END
      )`,
      partyName: sql<string | null>`COALESCE(
        ${salesParty.name},
        ${purchaseParty.name}
      )`,
      createdBy: inventoryMovements.createdBy,
      createdByName: users.name,
      notes: inventoryMovements.notes,
      createdAt: inventoryMovements.createdAt,
    };
  }

  private movementJoins() {
    return this.db
      .select(this.selectShape())
      .from(inventoryMovements)
      .innerJoin(items, eq(inventoryMovements.itemId, items.id))
      .innerJoin(godowns, eq(inventoryMovements.godownId, godowns.id))
      .leftJoin(
        salesDocuments,
        and(
          eq(inventoryMovements.referenceType, 'sales_documents'),
          eq(inventoryMovements.referenceId, salesDocuments.id),
        ),
      )
      .leftJoin(salesParty, eq(salesDocuments.partyId, salesParty.id))
      .leftJoin(
        purchaseDocuments,
        and(
          eq(inventoryMovements.referenceType, 'purchase_documents'),
          eq(inventoryMovements.referenceId, purchaseDocuments.id),
        ),
      )
      .leftJoin(purchaseParty, eq(purchaseDocuments.partyId, purchaseParty.id))
      .leftJoin(
        users,
        and(
          eq(inventoryMovements.createdBy, users.id),
          eq(users.businessId, inventoryMovements.businessId),
          eq(users.isDeleted, false),
        ),
      );
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

    const rows = await this.movementJoins()
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
    const [row] = await this.movementJoins()
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
