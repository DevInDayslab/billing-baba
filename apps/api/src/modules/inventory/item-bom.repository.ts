import { and, asc, eq, inArray, notInArray, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { itemBomCosts } from '../../db/schema/inventory/item-bom-costs.table';
import { itemBomMaterials } from '../../db/schema/inventory/item-bom-materials.table';
import { items, unitDefinitions } from '../../db/schema/inventory/tables';
import {
  toItemBomCostRecord,
  toItemBomMaterialRecord,
} from './item-bom.mapper';
import type { ItemBomRecord, ReplaceItemBomParams } from './item-bom.types';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];
type DbOrTransaction = Database | DbTransaction;

export class ItemBomRepository {
  constructor(private readonly db: Database) {}

  async getByItemId(
    businessId: string,
    itemId: string,
  ): Promise<ItemBomRecord> {
    const materials = await this.listMaterialsByItemId(businessId, itemId);
    const costs = await this.listCostsByItemId(businessId, itemId);
    return { materials, costs };
  }

  async listRawItemIdsForItem(
    businessId: string,
    itemId: string,
  ): Promise<string[]> {
    const rows = await this.db
      .select({ rawItemId: itemBomMaterials.rawItemId })
      .from(itemBomMaterials)
      .where(
        and(
          eq(itemBomMaterials.businessId, businessId),
          eq(itemBomMaterials.itemId, itemId),
          eq(itemBomMaterials.isDeleted, false),
        ),
      );
    return rows.map((row) => row.rawItemId);
  }

  async countFinishedGoodsUsingRawItem(
    businessId: string,
    rawItemId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({ count: sql<number>`count(*)::int` })
      .from(itemBomMaterials)
      .where(
        and(
          eq(itemBomMaterials.businessId, businessId),
          eq(itemBomMaterials.rawItemId, rawItemId),
          eq(itemBomMaterials.isDeleted, false),
        ),
      );
    return row?.count ?? 0;
  }

  async replaceBom(params: ReplaceItemBomParams): Promise<ItemBomRecord> {
    const { businessId, itemId, materials, costs, updatedBy } = params;

    return this.db.transaction(async (tx) => {
      const now = new Date();

      await this.replaceMaterials(tx, {
        businessId,
        itemId,
        materials,
        updatedBy,
        now,
      });
      await this.replaceCosts(tx, {
        businessId,
        itemId,
        costs,
        updatedBy,
        now,
      });

      return {
        materials: await this.listMaterialsByItemIdWithDb(
          tx,
          businessId,
          itemId,
        ),
        costs: await this.listCostsByItemIdWithDb(tx, businessId, itemId),
      };
    });
  }

  async findActiveItemIds(
    businessId: string,
    itemIds: string[],
  ): Promise<Set<string>> {
    if (itemIds.length === 0) return new Set();

    const rows = await this.db
      .select({ id: items.id })
      .from(items)
      .where(
        and(
          eq(items.businessId, businessId),
          inArray(items.id, itemIds),
          eq(items.isDeleted, false),
        ),
      );

    return new Set(rows.map((row) => row.id));
  }

  async findActiveUnitIds(
    businessId: string,
    unitIds: string[],
  ): Promise<Set<string>> {
    if (unitIds.length === 0) return new Set();

    const rows = await this.db
      .select({ id: unitDefinitions.id })
      .from(unitDefinitions)
      .where(
        and(
          eq(unitDefinitions.businessId, businessId),
          inArray(unitDefinitions.id, unitIds),
          eq(unitDefinitions.isDeleted, false),
        ),
      );

    return new Set(rows.map((row) => row.id));
  }

  private async replaceMaterials(
    tx: DbTransaction,
    input: {
      businessId: string;
      itemId: string;
      materials: ReplaceItemBomParams['materials'];
      updatedBy?: string | null;
      now: Date;
    },
  ): Promise<void> {
    const { businessId, itemId, materials, updatedBy, now } = input;
    const incomingRawItemIds = materials.map((material) => material.rawItemId);

    const activeFilter = and(
      eq(itemBomMaterials.businessId, businessId),
      eq(itemBomMaterials.itemId, itemId),
      eq(itemBomMaterials.isDeleted, false),
    );

    if (incomingRawItemIds.length === 0) {
      await tx
        .update(itemBomMaterials)
        .set({
          isDeleted: true,
          deletedAt: now,
          updatedAt: now,
          updatedBy: updatedBy ?? null,
          syncVersion: sql`${itemBomMaterials.syncVersion} + 1`,
        })
        .where(activeFilter);
    } else {
      await tx
        .update(itemBomMaterials)
        .set({
          isDeleted: true,
          deletedAt: now,
          updatedAt: now,
          updatedBy: updatedBy ?? null,
          syncVersion: sql`${itemBomMaterials.syncVersion} + 1`,
        })
        .where(
          and(
            activeFilter,
            notInArray(itemBomMaterials.rawItemId, incomingRawItemIds),
          ),
        );
    }

    for (const material of materials) {
      const [existing] = await tx
        .select({ id: itemBomMaterials.id })
        .from(itemBomMaterials)
        .where(
          and(
            eq(itemBomMaterials.businessId, businessId),
            eq(itemBomMaterials.itemId, itemId),
            eq(itemBomMaterials.rawItemId, material.rawItemId),
          ),
        )
        .limit(1);

      if (existing) {
        await tx
          .update(itemBomMaterials)
          .set({
            qty: material.qty,
            unitId: material.unitId,
            purchasePrice: material.purchasePrice,
            sortOrder: material.sortOrder,
            isDeleted: false,
            deletedAt: null,
            updatedAt: now,
            updatedBy: updatedBy ?? null,
            syncVersion: sql`${itemBomMaterials.syncVersion} + 1`,
          })
          .where(eq(itemBomMaterials.id, existing.id));
        continue;
      }

      await tx.insert(itemBomMaterials).values({
        businessId,
        itemId,
        rawItemId: material.rawItemId,
        qty: material.qty,
        unitId: material.unitId,
        purchasePrice: material.purchasePrice,
        sortOrder: material.sortOrder,
        createdBy: updatedBy ?? null,
        updatedBy: updatedBy ?? null,
      });
    }
  }

  private async replaceCosts(
    tx: DbTransaction,
    input: {
      businessId: string;
      itemId: string;
      costs: ReplaceItemBomParams['costs'];
      updatedBy?: string | null;
      now: Date;
    },
  ): Promise<void> {
    const { businessId, itemId, costs, updatedBy, now } = input;
    const incomingIds = costs
      .map((cost) => cost.id)
      .filter((id): id is string => id != null);

    const activeFilter = and(
      eq(itemBomCosts.businessId, businessId),
      eq(itemBomCosts.itemId, itemId),
      eq(itemBomCosts.isDeleted, false),
    );

    if (incomingIds.length === 0) {
      await tx
        .update(itemBomCosts)
        .set({
          isDeleted: true,
          deletedAt: now,
          updatedAt: now,
          updatedBy: updatedBy ?? null,
          syncVersion: sql`${itemBomCosts.syncVersion} + 1`,
        })
        .where(activeFilter);
    } else {
      await tx
        .update(itemBomCosts)
        .set({
          isDeleted: true,
          deletedAt: now,
          updatedAt: now,
          updatedBy: updatedBy ?? null,
          syncVersion: sql`${itemBomCosts.syncVersion} + 1`,
        })
        .where(and(activeFilter, notInArray(itemBomCosts.id, incomingIds)));
    }

    for (const cost of costs) {
      if (cost.id) {
        const [existing] = await tx
          .select({ id: itemBomCosts.id })
          .from(itemBomCosts)
          .where(
            and(
              eq(itemBomCosts.businessId, businessId),
              eq(itemBomCosts.itemId, itemId),
              eq(itemBomCosts.id, cost.id),
            ),
          )
          .limit(1);

        if (existing) {
          await tx
            .update(itemBomCosts)
            .set({
              description: cost.description,
              amount: cost.amount,
              sortOrder: cost.sortOrder,
              isDeleted: false,
              deletedAt: null,
              updatedAt: now,
              updatedBy: updatedBy ?? null,
              syncVersion: sql`${itemBomCosts.syncVersion} + 1`,
            })
            .where(eq(itemBomCosts.id, existing.id));
          continue;
        }
      }

      await tx.insert(itemBomCosts).values({
        id: cost.id,
        businessId,
        itemId,
        description: cost.description,
        amount: cost.amount,
        sortOrder: cost.sortOrder,
        createdBy: updatedBy ?? null,
        updatedBy: updatedBy ?? null,
      });
    }
  }

  private async listMaterialsByItemId(
    businessId: string,
    itemId: string,
  ): Promise<ItemBomRecord['materials']> {
    return this.listMaterialsByItemIdWithDb(this.db, businessId, itemId);
  }

  private async listCostsByItemId(
    businessId: string,
    itemId: string,
  ): Promise<ItemBomRecord['costs']> {
    return this.listCostsByItemIdWithDb(this.db, businessId, itemId);
  }

  private async listMaterialsByItemIdWithDb(
    db: DbOrTransaction,
    businessId: string,
    itemId: string,
  ): Promise<ItemBomRecord['materials']> {
    const rows = await db
      .select({
        id: itemBomMaterials.id,
        itemId: itemBomMaterials.itemId,
        rawItemId: itemBomMaterials.rawItemId,
        qty: itemBomMaterials.qty,
        unitId: itemBomMaterials.unitId,
        purchasePrice: itemBomMaterials.purchasePrice,
        sortOrder: itemBomMaterials.sortOrder,
        rawItemName: items.name,
        rawItemBaseUnit: items.baseUnit,
        rawItemPurchasePrice: items.purchasePrice,
      })
      .from(itemBomMaterials)
      .innerJoin(
        items,
        and(
          eq(itemBomMaterials.rawItemId, items.id),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .where(
        and(
          eq(itemBomMaterials.businessId, businessId),
          eq(itemBomMaterials.itemId, itemId),
          eq(itemBomMaterials.isDeleted, false),
        ),
      )
      .orderBy(
        asc(itemBomMaterials.sortOrder),
        asc(itemBomMaterials.createdAt),
      );

    return rows.map((row) => toItemBomMaterialRecord(row));
  }

  private async listCostsByItemIdWithDb(
    db: DbOrTransaction,
    businessId: string,
    itemId: string,
  ): Promise<ItemBomRecord['costs']> {
    const rows = await db
      .select({
        id: itemBomCosts.id,
        itemId: itemBomCosts.itemId,
        description: itemBomCosts.description,
        amount: itemBomCosts.amount,
        sortOrder: itemBomCosts.sortOrder,
      })
      .from(itemBomCosts)
      .where(
        and(
          eq(itemBomCosts.businessId, businessId),
          eq(itemBomCosts.itemId, itemId),
          eq(itemBomCosts.isDeleted, false),
        ),
      )
      .orderBy(asc(itemBomCosts.sortOrder), asc(itemBomCosts.createdAt));

    return rows.map((row) => toItemBomCostRecord(row));
  }
}
