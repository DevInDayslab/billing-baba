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
import { saleFaBatches, saleFixedAssets } from '../../db/schema/sales/tables';
import {
  toSaleFaAssetRecord,
  toSaleFaBatchListRecord,
  toSaleFaBatchRecord,
} from './sale-fa.mapper';
import type {
  ListSaleFaParams,
  SaleFaAssetInput,
  SaleFaBatchListRecord,
  SaleFaBatchRecord,
} from './sale-fa.types';

export class SaleFaRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListSaleFaParams): Promise<{
    rows: SaleFaBatchListRecord[];
    total: number;
  }> {
    const filters = [
      eq(saleFaBatches.businessId, params.businessId),
      eq(saleFaBatches.isDeleted, false),
    ];

    if (params.q) {
      filters.push(
        or(
          ilike(saleFaBatches.referenceNumber, `%${params.q}%`),
          ilike(parties.name, `%${params.q}%`),
        )!,
      );
    }
    if (params.partyId) {
      filters.push(eq(saleFaBatches.partyId, params.partyId));
    }
    if (params.status) {
      filters.push(
        eq(
          saleFaBatches.status,
          params.status as (typeof saleFaBatches.status.enumValues)[number],
        ),
      );
    }
    if (params.from) {
      filters.push(gte(saleFaBatches.saleDate, params.from));
    }
    if (params.to) {
      filters.push(lte(saleFaBatches.saleDate, params.to));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(saleFaBatches)
      .innerJoin(parties, eq(saleFaBatches.partyId, parties.id))
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? saleFaBatches.createdAt
        : params.sort === 'total_amount'
          ? saleFaBatches.totalAmount
          : saleFaBatches.saleDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: saleFaBatches.id,
        partyId: saleFaBatches.partyId,
        partyName: parties.name,
        referenceNumber: saleFaBatches.referenceNumber,
        saleDate: saleFaBatches.saleDate,
        dueDate: saleFaBatches.dueDate,
        paymentMode: saleFaBatches.paymentMode,
        totalAmount: saleFaBatches.totalAmount,
        balanceDue: saleFaBatches.balanceDue,
        status: saleFaBatches.status,
        createdAt: saleFaBatches.createdAt,
        updatedAt: saleFaBatches.updatedAt,
      })
      .from(saleFaBatches)
      .innerJoin(parties, eq(saleFaBatches.partyId, parties.id))
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map(toSaleFaBatchListRecord),
      total,
    };
  }

  async findById(
    businessId: string,
    batchId: string,
  ): Promise<SaleFaBatchRecord | null> {
    const [batch] = await this.db
      .select({
        id: saleFaBatches.id,
        partyId: saleFaBatches.partyId,
        partyName: parties.name,
        referenceNumber: saleFaBatches.referenceNumber,
        saleDate: saleFaBatches.saleDate,
        dueDate: saleFaBatches.dueDate,
        paymentMode: saleFaBatches.paymentMode,
        subtotal: saleFaBatches.subtotal,
        taxAmount: saleFaBatches.taxAmount,
        totalAmount: saleFaBatches.totalAmount,
        balanceDue: saleFaBatches.balanceDue,
        status: saleFaBatches.status,
        notes: saleFaBatches.notes,
        description: saleFaBatches.description,
        createdAt: saleFaBatches.createdAt,
        updatedAt: saleFaBatches.updatedAt,
      })
      .from(saleFaBatches)
      .innerJoin(parties, eq(saleFaBatches.partyId, parties.id))
      .where(
        and(
          eq(saleFaBatches.id, batchId),
          eq(saleFaBatches.businessId, businessId),
          eq(saleFaBatches.isDeleted, false),
        ),
      )
      .limit(1);

    if (!batch) return null;

    const assets = await this.listAssets(businessId, batchId);
    return toSaleFaBatchRecord(batch, assets);
  }

  async listAssets(businessId: string, batchId: string) {
    return this.db
      .select({
        id: saleFixedAssets.id,
        assetName: saleFixedAssets.assetName,
        itemCode: saleFixedAssets.itemCode,
        assetCategory: saleFixedAssets.assetCategory,
        serialNumber: saleFixedAssets.serialNumber,
        salePrice: saleFixedAssets.salePrice,
        location: saleFixedAssets.location,
        description: saleFixedAssets.description,
        qty: saleFixedAssets.qty,
        taxRate: saleFixedAssets.taxRate,
        taxAmount: saleFixedAssets.taxAmount,
        lineTotal: saleFixedAssets.lineTotal,
        sortOrder: saleFixedAssets.sortOrder,
        purchaseFixedAssetId: saleFixedAssets.purchaseFixedAssetId,
      })
      .from(saleFixedAssets)
      .where(
        and(
          eq(saleFixedAssets.batchId, batchId),
          eq(saleFixedAssets.businessId, businessId),
          eq(saleFixedAssets.isDeleted, false),
        ),
      )
      .orderBy(asc(saleFixedAssets.sortOrder));
  }

  async createBatch(
    businessId: string,
    values: {
      partyId: string;
      referenceNumber?: string | null;
      saleDate: string;
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
    assets: SaleFaAssetInput[],
  ): Promise<SaleFaBatchRecord> {
    const [batch] = await this.db
      .insert(saleFaBatches)
      .values({
        businessId,
        partyId: values.partyId,
        referenceNumber: values.referenceNumber ?? null,
        saleDate: values.saleDate,
        dueDate: values.dueDate ?? null,
        subtotal: values.subtotal,
        taxAmount: values.taxAmount,
        totalAmount: values.totalAmount,
        balanceDue: values.balanceDue,
        status:
          values.status as (typeof saleFaBatches.status.enumValues)[number],
        notes: values.notes ?? null,
        description: values.description ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
        paymentMode: (values.paymentMode ?? null) as
          | (typeof saleFaBatches.paymentMode.enumValues)[number]
          | null,
      })
      .returning({ id: saleFaBatches.id });

    if (!batch) throw new Error('Failed to create sale FA batch');

    await this.insertAssets(businessId, batch.id, assets, values.createdBy);

    const created = await this.findById(businessId, batch.id);
    if (!created) throw new Error('Failed to load created sale FA batch');
    return created;
  }

  private async insertAssets(
    businessId: string,
    batchId: string,
    assets: SaleFaAssetInput[],
    userId?: string | null,
  ) {
    if (assets.length === 0) return;
    await this.db.insert(saleFixedAssets).values(
      assets.map((asset, index) => ({
        businessId,
        batchId,
        assetName: asset.asset_name,
        itemCode: asset.item_code ?? null,
        assetCategory: asset.asset_category ?? null,
        serialNumber: asset.serial_number ?? null,
        salePrice: asset.sale_price,
        location: asset.location ?? null,
        description: asset.description ?? null,
        qty: asset.qty ?? '1',
        taxRate: asset.tax_rate ?? '0',
        taxAmount: asset.tax_amount ?? '0',
        lineTotal: asset.line_total,
        sortOrder: asset.sort_order ?? index,
        purchaseFixedAssetId: asset.purchase_fixed_asset_id ?? null,
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
      .update(saleFixedAssets)
      .set({
        isDeleted: true,
        deletedAt: now,
        updatedBy: userId,
        updatedAt: now,
        syncVersion: sql`${saleFixedAssets.syncVersion} + 1`,
      })
      .where(
        and(
          eq(saleFixedAssets.batchId, batchId),
          eq(saleFixedAssets.businessId, businessId),
          eq(saleFixedAssets.isDeleted, false),
        ),
      );

    const [row] = await this.db
      .update(saleFaBatches)
      .set({
        isDeleted: true,
        deletedAt: now,
        updatedBy: userId,
        updatedAt: now,
        syncVersion: sql`${saleFaBatches.syncVersion} + 1`,
      })
      .where(
        and(
          eq(saleFaBatches.id, batchId),
          eq(saleFaBatches.businessId, businessId),
          eq(saleFaBatches.isDeleted, false),
        ),
      )
      .returning({ id: saleFaBatches.id });

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
      eq(saleFixedAssets.businessId, businessId),
      eq(saleFixedAssets.isDeleted, false),
      eq(saleFixedAssets.serialNumber, serialNumber),
    ];
    if (excludeAssetId) {
      filters.push(sql`${saleFixedAssets.id} <> ${excludeAssetId}`);
    }
    const [row] = await this.db
      .select({ id: saleFixedAssets.id })
      .from(saleFixedAssets)
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
      saleDate?: string;
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
    assets?: SaleFaAssetInput[],
  ): Promise<SaleFaBatchRecord | null> {
    const [row] = await this.db
      .update(saleFaBatches)
      .set({
        ...(header.partyId !== undefined ? { partyId: header.partyId } : {}),
        ...(header.referenceNumber !== undefined
          ? { referenceNumber: header.referenceNumber }
          : {}),
        ...(header.saleDate !== undefined ? { saleDate: header.saleDate } : {}),
        ...(header.dueDate !== undefined ? { dueDate: header.dueDate } : {}),
        ...(header.paymentMode !== undefined
          ? {
              paymentMode: header.paymentMode as
                | (typeof saleFaBatches.paymentMode.enumValues)[number]
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
                header.status as (typeof saleFaBatches.status.enumValues)[number],
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
        syncVersion: sql`${saleFaBatches.syncVersion} + 1`,
      })
      .where(
        and(
          eq(saleFaBatches.id, batchId),
          eq(saleFaBatches.businessId, businessId),
          eq(saleFaBatches.isDeleted, false),
        ),
      )
      .returning({ id: saleFaBatches.id });

    if (!row) return null;

    if (assets) {
      await this.db
        .update(saleFixedAssets)
        .set({
          isDeleted: true,
          deletedAt: new Date(),
          updatedBy: header.updatedBy ?? null,
          updatedAt: new Date(),
          syncVersion: sql`${saleFixedAssets.syncVersion} + 1`,
        })
        .where(
          and(
            eq(saleFixedAssets.batchId, batchId),
            eq(saleFixedAssets.businessId, businessId),
            eq(saleFixedAssets.isDeleted, false),
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
