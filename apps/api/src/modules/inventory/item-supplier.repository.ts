import { and, asc, eq, inArray, notInArray, or, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { parties } from '../../db/schema/crm/tables';
import { itemSuppliers } from '../../db/schema/inventory/item-suppliers.table';
import { toItemSupplierRecord } from './item-supplier.mapper';
import type {
  ItemSupplierRecord,
  ReplaceItemSuppliersParams,
} from './item-supplier.types';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];
type DbOrTransaction = Database | DbTransaction;

export class ItemSupplierRepository {
  constructor(private readonly db: Database) {}

  async listByItemId(
    businessId: string,
    itemId: string,
  ): Promise<ItemSupplierRecord[]> {
    const rows = await this.db
      .select({
        id: itemSuppliers.id,
        itemId: itemSuppliers.itemId,
        partyId: itemSuppliers.partyId,
        isDefault: itemSuppliers.isDefault,
        sortOrder: itemSuppliers.sortOrder,
        partyName: parties.name,
        partyMobile: parties.mobile,
        partyType: parties.partyType,
      })
      .from(itemSuppliers)
      .innerJoin(
        parties,
        and(
          eq(itemSuppliers.partyId, parties.id),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .where(
        and(
          eq(itemSuppliers.businessId, businessId),
          eq(itemSuppliers.itemId, itemId),
          eq(itemSuppliers.isDeleted, false),
        ),
      )
      .orderBy(asc(itemSuppliers.sortOrder), asc(itemSuppliers.createdAt));

    return rows.map((row) => toItemSupplierRecord(row));
  }

  async replaceSuppliers(
    params: ReplaceItemSuppliersParams,
  ): Promise<ItemSupplierRecord[]> {
    const { businessId, itemId, suppliers, updatedBy } = params;

    return this.db.transaction(async (tx) => {
      const now = new Date();
      const incomingPartyIds = suppliers.map((supplier) => supplier.partyId);

      const activeFilter = and(
        eq(itemSuppliers.businessId, businessId),
        eq(itemSuppliers.itemId, itemId),
        eq(itemSuppliers.isDeleted, false),
      );

      if (incomingPartyIds.length === 0) {
        await tx
          .update(itemSuppliers)
          .set({
            isDeleted: true,
            deletedAt: now,
            updatedAt: now,
            updatedBy: updatedBy ?? null,
            syncVersion: sql`${itemSuppliers.syncVersion} + 1`,
          })
          .where(activeFilter);
      } else {
        await tx
          .update(itemSuppliers)
          .set({
            isDeleted: true,
            deletedAt: now,
            updatedAt: now,
            updatedBy: updatedBy ?? null,
            syncVersion: sql`${itemSuppliers.syncVersion} + 1`,
          })
          .where(
            and(activeFilter, notInArray(itemSuppliers.partyId, incomingPartyIds)),
          );
      }

      for (const supplier of suppliers) {
        const [existing] = await tx
          .select({ id: itemSuppliers.id })
          .from(itemSuppliers)
          .where(
            and(
              eq(itemSuppliers.businessId, businessId),
              eq(itemSuppliers.itemId, itemId),
              eq(itemSuppliers.partyId, supplier.partyId),
            ),
          )
          .limit(1);

        if (existing) {
          await tx
            .update(itemSuppliers)
            .set({
              isDefault: supplier.isDefault,
              sortOrder: supplier.sortOrder,
              isDeleted: false,
              deletedAt: null,
              updatedAt: now,
              updatedBy: updatedBy ?? null,
              syncVersion: sql`${itemSuppliers.syncVersion} + 1`,
            })
            .where(eq(itemSuppliers.id, existing.id));
          continue;
        }

        await tx.insert(itemSuppliers).values({
          businessId,
          itemId,
          partyId: supplier.partyId,
          isDefault: supplier.isDefault,
          sortOrder: supplier.sortOrder,
          createdBy: updatedBy ?? null,
          updatedBy: updatedBy ?? null,
        });
      }

      return this.listByItemIdWithDb(tx, businessId, itemId);
    });
  }

  async findActivePartyIds(
    businessId: string,
    partyIds: string[],
  ): Promise<Set<string>> {
    if (partyIds.length === 0) {
      return new Set();
    }

    const rows = await this.db
      .select({ id: parties.id })
      .from(parties)
      .where(
        and(
          eq(parties.businessId, businessId),
          inArray(parties.id, partyIds),
          eq(parties.isDeleted, false),
          or(
            eq(parties.partyType, 'supplier'),
            eq(parties.partyType, 'both'),
          ),
        ),
      );

    return new Set(rows.map((row) => row.id));
  }

  private async listByItemIdWithDb(
    db: DbOrTransaction,
    businessId: string,
    itemId: string,
  ): Promise<ItemSupplierRecord[]> {
    const rows = await db
      .select({
        id: itemSuppliers.id,
        itemId: itemSuppliers.itemId,
        partyId: itemSuppliers.partyId,
        isDefault: itemSuppliers.isDefault,
        sortOrder: itemSuppliers.sortOrder,
        partyName: parties.name,
        partyMobile: parties.mobile,
        partyType: parties.partyType,
      })
      .from(itemSuppliers)
      .innerJoin(
        parties,
        and(
          eq(itemSuppliers.partyId, parties.id),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .where(
        and(
          eq(itemSuppliers.businessId, businessId),
          eq(itemSuppliers.itemId, itemId),
          eq(itemSuppliers.isDeleted, false),
        ),
      )
      .orderBy(asc(itemSuppliers.sortOrder), asc(itemSuppliers.createdAt));

    return rows.map((row) => toItemSupplierRecord(row));
  }
}
