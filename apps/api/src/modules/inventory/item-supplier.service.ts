import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { getDb } from '../../db/client';
import { items } from '../../db/schema/inventory/tables';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import { ItemSupplierRepository } from './item-supplier.repository';
import type { ReplaceItemSuppliersBody } from './item-supplier.schema';
import type { ItemSupplierRecord } from './item-supplier.types';

export class ItemSupplierService extends InventoryServiceBase {
  private readonly repository: ItemSupplierRepository;
  private readonly db: Database;

  constructor() {
    super();
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = db;
    this.repository = new ItemSupplierRepository(db);
  }

  async listSuppliers(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<ItemSupplierRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
    return this.repository.listByItemId(businessId, itemId);
  }

  async replaceSuppliers(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    input: ReplaceItemSuppliersBody,
  ): Promise<ItemSupplierRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
    this.assertSingleDefault(input.suppliers);

    const partyIds = input.suppliers.map((supplier) => supplier.party_id);
    if (partyIds.length > 0) {
      const validPartyIds = await this.repository.findActivePartyIds(
        businessId,
        partyIds,
      );
      const invalidPartyIds = partyIds.filter((id) => !validPartyIds.has(id));
      if (invalidPartyIds.length > 0) {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          suppliers: ['One or more party IDs are invalid or not suppliers'],
        });
      }
    }

    return this.repository.replaceSuppliers({
      businessId,
      itemId,
      suppliers: input.suppliers.map((supplier, index) => ({
        partyId: supplier.party_id,
        isDefault: supplier.is_default ?? false,
        sortOrder: supplier.sort_order ?? index,
      })),
      updatedBy: userId ?? null,
    });
  }

  private assertSingleDefault(
    suppliers: ReplaceItemSuppliersBody['suppliers'],
  ): void {
    const defaultCount = suppliers.filter(
      (supplier) => supplier.is_default,
    ).length;
    if (defaultCount > 1) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        suppliers: ['Only one supplier may be marked as default'],
      });
    }
  }

  private async assertItemExists(
    businessId: string,
    itemId: string,
  ): Promise<void> {
    const [item] = await this.db
      .select({ id: items.id })
      .from(items)
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .limit(1);

    if (!item) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }
  }
}
