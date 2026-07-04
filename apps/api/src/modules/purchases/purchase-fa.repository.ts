import {
  and,
  asc,
  count,
  desc,
  eq,
  gte,
  ilike,
  lte,
  or,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import { parties } from '../../db/schema/crm/tables';
import {
  purchaseFaBatches,
  purchaseFixedAssets,
} from '../../db/schema/purchases/tables';
import {
  toPurchaseFaAssetRecord,
  toPurchaseFaBatchListRecord,
  toPurchaseFaBatchRecord,
} from './purchase-fa.mapper';
import type {
  ListPurchaseFaParams,
  PurchaseFaAssetInput,
  PurchaseFaBatchListRecord,
  PurchaseFaBatchRecord,
} from './purchase-fa.types';

export class PurchaseFaRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListPurchaseFaParams): Promise<{
    rows: PurchaseFaBatchListRecord[];
    total: number;
  }> {
    const filters = [
      eq(purchaseFaBatches.businessId, params.businessId),
      eq(purchaseFaBatches.isDeleted, false),
    ];

    if (params.q) {
      filters.push(
        or(
          ilike(purchaseFaBatches.referenceNumber, `%${params.q}%`),
          ilike(parties.name, `%${params.q}%`),
        )!,
      );
    }
    if (params.partyId) {
      filters.push(eq(purchaseFaBatches.partyId, params.partyId));
    }
    if (params.status) {
      filters.push(
        eq(
          purchaseFaBatches.status,
          params.status as (typeof purchaseFaBatches.status.enumValues)[number],
        ),
      );
    }
    if (params.from) {
      filters.push(gte(purchaseFaBatches.purchaseDate, params.from));
    }
    if (params.to) {
      filters.push(lte(purchaseFaBatches.purchaseDate, params.to));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(purchaseFaBatches)
      .innerJoin(parties, eq(purchaseFaBatches.partyId, parties.id))
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? purchaseFaBatches.createdAt
        : params.sort === 'total_amount'
          ? purchaseFaBatches.totalAmount
          : purchaseFaBatches.purchaseDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: purchaseFaBatches.id,
        partyId: purchaseFaBatches.partyId,
        partyName: parties.name,
        referenceNumber: purchaseFaBatches.referenceNumber,
        purchaseDate: purchaseFaBatches.purchaseDate,
        dueDate: purchaseFaBatches.dueDate,
        paymentMode: purchaseFaBatches.paymentMode,
        totalAmount: purchaseFaBatches.totalAmount,
        balanceDue: purchaseFaBatches.balanceDue,
        status: purchaseFaBatches.status,
        createdAt: purchaseFaBatches.createdAt,
        updatedAt: purchaseFaBatches.updatedAt,
      })
      .from(purchaseFaBatches)
      .innerJoin(parties, eq(purchaseFaBatches.partyId, parties.id))
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map(toPurchaseFaBatchListRecord),
      total,
    };
  }

  async findById(
    businessId: string,
    batchId: string,
  ): Promise<PurchaseFaBatchRecord | null> {
    const [batch] = await this.db
      .select({
        id: purchaseFaBatches.id,
        partyId: purchaseFaBatches.partyId,
        partyName: parties.name,
        referenceNumber: purchaseFaBatches.referenceNumber,
        purchaseDate: purchaseFaBatches.purchaseDate,
        dueDate: purchaseFaBatches.dueDate,
        paymentMode: purchaseFaBatches.paymentMode,
        subtotal: purchaseFaBatches.subtotal,
        taxAmount: purchaseFaBatches.taxAmount,
        totalAmount: purchaseFaBatches.totalAmount,
        balanceDue: purchaseFaBatches.balanceDue,
        status: purchaseFaBatches.status,
        notes: purchaseFaBatches.notes,
        description: purchaseFaBatches.description,
        createdAt: purchaseFaBatches.createdAt,
        updatedAt: purchaseFaBatches.updatedAt,
      })
      .from(purchaseFaBatches)
      .innerJoin(parties, eq(purchaseFaBatches.partyId, parties.id))
      .where(
        and(
          eq(purchaseFaBatches.id, batchId),
          eq(purchaseFaBatches.businessId, businessId),
          eq(purchaseFaBatches.isDeleted, false),
        ),
      )
      .limit(1);

    if (!batch) return null;

    const assets = await this.listAssets(businessId, batchId);
    return toPurchaseFaBatchRecord(batch, assets);
  }

  async listAssets(businessId: string, batchId: string) {
    return this.db
      .select({
        id: purchaseFixedAssets.id,
        assetName: purchaseFixedAssets.assetName,
        assetCategory: purchaseFixedAssets.assetCategory,
        serialNumber: purchaseFixedAssets.serialNumber,
        purchasePrice: purchaseFixedAssets.purchasePrice,
        location: purchaseFixedAssets.location,
        warrantyExpiry: purchaseFixedAssets.warrantyExpiry,
        description: purchaseFixedAssets.description,
        qty: purchaseFixedAssets.qty,
        taxRate: purchaseFixedAssets.taxRate,
        taxAmount: purchaseFixedAssets.taxAmount,
        lineTotal: purchaseFixedAssets.lineTotal,
        sortOrder: purchaseFixedAssets.sortOrder,
        purchaseDocumentId: purchaseFixedAssets.purchaseDocumentId,
      })
      .from(purchaseFixedAssets)
      .where(
        and(
          eq(purchaseFixedAssets.batchId, batchId),
          eq(purchaseFixedAssets.businessId, businessId),
          eq(purchaseFixedAssets.isDeleted, false),
        ),
      )
      .orderBy(asc(purchaseFixedAssets.sortOrder));
  }

  async createBatch(
    businessId: string,
    values: {
      partyId: string;
      referenceNumber?: string | null;
      purchaseDate: string;
      dueDate?: string | null;
      paymentMode?: string | null;
      subtotal: string;
      taxAmount: string;
      totalAmount: string;
      balanceDue: string;
      status: string;
      notes?: string | null;
      description?: string | null;
      createdBy?: string | null;
      updatedBy?: string | null;
    },
    assets: PurchaseFaAssetInput[],
  ): Promise<PurchaseFaBatchRecord> {
    const [batch] = await this.db
      .insert(purchaseFaBatches)
      .values({
        businessId,
        partyId: values.partyId,
        referenceNumber: values.referenceNumber ?? null,
        purchaseDate: values.purchaseDate,
        dueDate: values.dueDate ?? null,
        subtotal: values.subtotal,
        taxAmount: values.taxAmount,
        totalAmount: values.totalAmount,
        balanceDue: values.balanceDue,
        status:
          values.status as (typeof purchaseFaBatches.status.enumValues)[number],
        notes: values.notes ?? null,
        description: values.description ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
        paymentMode: (values.paymentMode ?? null) as
          | (typeof purchaseFaBatches.paymentMode.enumValues)[number]
          | null,
      })
      .returning({ id: purchaseFaBatches.id });

    if (!batch) throw new Error('Failed to create FA batch');

    await this.insertAssets(businessId, batch.id, assets, values.createdBy);

    const created = await this.findById(businessId, batch.id);
    if (!created) throw new Error('Failed to load created FA batch');
    return created;
  }

  private async insertAssets(
    businessId: string,
    batchId: string,
    assets: PurchaseFaAssetInput[],
    userId?: string | null,
  ) {
    if (assets.length === 0) return;
    await this.db.insert(purchaseFixedAssets).values(
      assets.map((asset, index) => ({
        businessId,
        batchId,
        assetName: asset.asset_name,
        assetCategory: asset.asset_category ?? null,
        serialNumber: asset.serial_number ?? null,
        purchasePrice: asset.purchase_price,
        location: asset.location ?? null,
        warrantyExpiry: asset.warranty_expiry ?? null,
        description: asset.description ?? null,
        qty: asset.qty ?? '1',
        taxRate: asset.tax_rate ?? '0',
        taxAmount: asset.tax_amount ?? '0',
        lineTotal: asset.line_total,
        sortOrder: asset.sort_order ?? index,
        purchaseDocumentId: asset.purchase_document_id ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      })),
    );
  }

  async softDeleteBatch(
    businessId: string,
    batchId: string,
    userId: string | null,
  ): Promise<boolean> {
    const now = new Date();
    await this.db
      .update(purchaseFixedAssets)
      .set({
        isDeleted: true,
        deletedAt: now,
        updatedBy: userId,
        updatedAt: now,
        syncVersion: sql`${purchaseFixedAssets.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseFixedAssets.batchId, batchId),
          eq(purchaseFixedAssets.businessId, businessId),
          eq(purchaseFixedAssets.isDeleted, false),
        ),
      );

    const [row] = await this.db
      .update(purchaseFaBatches)
      .set({
        isDeleted: true,
        deletedAt: now,
        updatedBy: userId,
        updatedAt: now,
        syncVersion: sql`${purchaseFaBatches.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseFaBatches.id, batchId),
          eq(purchaseFaBatches.businessId, businessId),
          eq(purchaseFaBatches.isDeleted, false),
        ),
      )
      .returning({ id: purchaseFaBatches.id });

    return Boolean(row);
  }

  async partyExists(businessId: string, partyId: string): Promise<boolean> {
    const [row] = await this.db
      .select({ id: parties.id })
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  async serialExists(
    businessId: string,
    serialNumber: string,
    excludeAssetId?: string,
  ): Promise<boolean> {
    const filters = [
      eq(purchaseFixedAssets.businessId, businessId),
      eq(purchaseFixedAssets.isDeleted, false),
      eq(purchaseFixedAssets.serialNumber, serialNumber),
    ];
    if (excludeAssetId) {
      filters.push(sql`${purchaseFixedAssets.id} <> ${excludeAssetId}`);
    }
    const [row] = await this.db
      .select({ id: purchaseFixedAssets.id })
      .from(purchaseFixedAssets)
      .where(and(...filters))
      .limit(1);
    return Boolean(row);
  }

  async updateBatch(
    businessId: string,
    batchId: string,
    header: {
      partyId?: string;
      referenceNumber?: string | null;
      purchaseDate?: string;
      dueDate?: string | null;
      paymentMode?: string | null;
      subtotal?: string;
      taxAmount?: string;
      totalAmount?: string;
      balanceDue?: string;
      status?: string;
      notes?: string | null;
      description?: string | null;
      updatedBy?: string | null;
    },
    assets?: PurchaseFaAssetInput[],
  ): Promise<PurchaseFaBatchRecord | null> {
    const [row] = await this.db
      .update(purchaseFaBatches)
      .set({
        ...(header.partyId !== undefined ? { partyId: header.partyId } : {}),
        ...(header.referenceNumber !== undefined
          ? { referenceNumber: header.referenceNumber }
          : {}),
        ...(header.purchaseDate !== undefined
          ? { purchaseDate: header.purchaseDate }
          : {}),
        ...(header.dueDate !== undefined ? { dueDate: header.dueDate } : {}),
        ...(header.paymentMode !== undefined
          ? {
              paymentMode: header.paymentMode as
                | (typeof purchaseFaBatches.paymentMode.enumValues)[number]
                | null,
            }
          : {}),
        ...(header.subtotal !== undefined ? { subtotal: header.subtotal } : {}),
        ...(header.taxAmount !== undefined
          ? { taxAmount: header.taxAmount }
          : {}),
        ...(header.totalAmount !== undefined
          ? { totalAmount: header.totalAmount }
          : {}),
        ...(header.balanceDue !== undefined
          ? { balanceDue: header.balanceDue }
          : {}),
        ...(header.status !== undefined
          ? {
              status:
                header.status as (typeof purchaseFaBatches.status.enumValues)[number],
            }
          : {}),
        ...(header.notes !== undefined ? { notes: header.notes } : {}),
        ...(header.description !== undefined
          ? { description: header.description }
          : {}),
        ...(header.updatedBy !== undefined
          ? { updatedBy: header.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${purchaseFaBatches.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseFaBatches.id, batchId),
          eq(purchaseFaBatches.businessId, businessId),
          eq(purchaseFaBatches.isDeleted, false),
        ),
      )
      .returning({ id: purchaseFaBatches.id });

    if (!row) return null;

    if (assets) {
      await this.db
        .update(purchaseFixedAssets)
        .set({
          isDeleted: true,
          deletedAt: new Date(),
          updatedBy: header.updatedBy ?? null,
          updatedAt: new Date(),
          syncVersion: sql`${purchaseFixedAssets.syncVersion} + 1`,
        })
        .where(
          and(
            eq(purchaseFixedAssets.batchId, batchId),
            eq(purchaseFixedAssets.businessId, businessId),
            eq(purchaseFixedAssets.isDeleted, false),
          ),
        );
      await this.insertAssets(
        businessId,
        batchId,
        assets,
        header.updatedBy ?? null,
      );
    }

    return this.findById(businessId, batchId);
  }
}
