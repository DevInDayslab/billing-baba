import {
  and,
  asc,
  count,
  desc,
  eq,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  jobWorkAdditionalCosts,
  jobWorkOrders,
  jobWorkRawMaterialLines,
} from '../../db/schema/job-work/tables';
import type {
  JobWorkOrderRecord,
  JobWorkOrderInsertValues,
} from './job-work-order.types';

export class JobWorkOrderRepository {
  constructor(private readonly db: Database) {}

  async list(params: {
    businessId: string;
    page: number;
    limit: number;
    status?: 'open' | 'closed' | 'cancelled';
    partyId?: string;
    sort: 'order_date' | 'created_at';
    order: 'asc' | 'desc';
  }): Promise<{ rows: JobWorkOrderRecord[]; total: number }> {
    const filters = [
      eq(jobWorkOrders.businessId, params.businessId),
      eq(jobWorkOrders.isDeleted, false),
    ];

    if (params.status) {
      filters.push(eq(jobWorkOrders.status, params.status));
    }
    if (params.partyId) {
      filters.push(eq(jobWorkOrders.partyId, params.partyId));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(jobWorkOrders)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? jobWorkOrders.createdAt
        : jobWorkOrders.orderDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select()
      .from(jobWorkOrders)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return { rows: rows.map((row) => toRecord(row)), total };
  }

  async findById(
    businessId: string,
    orderId: string,
    includeLines = false,
  ): Promise<JobWorkOrderRecord | null> {
    const [row] = await this.db
      .select()
      .from(jobWorkOrders)
      .where(
        and(
          eq(jobWorkOrders.id, orderId),
          eq(jobWorkOrders.businessId, businessId),
          eq(jobWorkOrders.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) {
      return null;
    }

    const record = toRecord(row);
    if (includeLines) {
      record.raw_materials = await this.listRawMaterials(businessId, orderId);
      record.additional_costs = await this.listAdditionalCosts(
        businessId,
        orderId,
      );
    }

    return record;
  }

  async create(values: JobWorkOrderInsertValues): Promise<JobWorkOrderRecord> {
    const [row] = await this.db
      .insert(jobWorkOrders)
      .values({
        businessId: values.businessId,
        partyId: values.partyId ?? null,
        jobNumber: values.jobNumber ?? null,
        orderDate: values.orderDate ?? new Date(),
        deliveryDate: values.deliveryDate ?? null,
        finishedGoodName: values.finishedGoodName,
        finishedGoodQuantity: values.finishedGoodQuantity ?? '1',
        finishedGoodUnit: values.finishedGoodUnit ?? 'PCS',
        rawMaterialsTotal: values.rawMaterialsTotal ?? '0',
        additionalCostsTotal: values.additionalCostsTotal ?? '0',
        grandTotal: values.grandTotal ?? '0',
        notes: values.notes ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create job work order');
    }

    return toRecord(row);
  }

  async update(
    businessId: string,
    orderId: string,
    values: Partial<JobWorkOrderInsertValues> & {
      status?: 'open' | 'closed' | 'cancelled';
    },
  ): Promise<JobWorkOrderRecord | null> {
    const [row] = await this.db
      .update(jobWorkOrders)
      .set({
        ...(values.partyId !== undefined ? { partyId: values.partyId } : {}),
        ...(values.jobNumber !== undefined
          ? { jobNumber: values.jobNumber }
          : {}),
        ...(values.deliveryDate !== undefined
          ? { deliveryDate: values.deliveryDate }
          : {}),
        ...(values.finishedGoodName !== undefined
          ? { finishedGoodName: values.finishedGoodName }
          : {}),
        ...(values.finishedGoodQuantity !== undefined
          ? { finishedGoodQuantity: values.finishedGoodQuantity }
          : {}),
        ...(values.finishedGoodUnit !== undefined
          ? { finishedGoodUnit: values.finishedGoodUnit }
          : {}),
        ...(values.rawMaterialsTotal !== undefined
          ? { rawMaterialsTotal: values.rawMaterialsTotal }
          : {}),
        ...(values.additionalCostsTotal !== undefined
          ? { additionalCostsTotal: values.additionalCostsTotal }
          : {}),
        ...(values.grandTotal !== undefined
          ? { grandTotal: values.grandTotal }
          : {}),
        ...(values.status !== undefined ? { status: values.status } : {}),
        ...(values.notes !== undefined ? { notes: values.notes } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${jobWorkOrders.syncVersion} + 1`,
      })
      .where(
        and(
          eq(jobWorkOrders.id, orderId),
          eq(jobWorkOrders.businessId, businessId),
          eq(jobWorkOrders.isDeleted, false),
        ),
      )
      .returning();

    return row ? toRecord(row) : null;
  }

  async softDelete(
    businessId: string,
    orderId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(jobWorkOrders)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${jobWorkOrders.syncVersion} + 1`,
      })
      .where(
        and(
          eq(jobWorkOrders.id, orderId),
          eq(jobWorkOrders.businessId, businessId),
          eq(jobWorkOrders.isDeleted, false),
        ),
      )
      .returning({ id: jobWorkOrders.id });

    return Boolean(row);
  }

  async listRawMaterials(businessId: string, orderId: string) {
    const rows = await this.db
      .select()
      .from(jobWorkRawMaterialLines)
      .where(
        and(
          eq(jobWorkRawMaterialLines.jobWorkOrderId, orderId),
          eq(jobWorkRawMaterialLines.businessId, businessId),
          eq(jobWorkRawMaterialLines.isDeleted, false),
        ),
      )
      .orderBy(asc(jobWorkRawMaterialLines.sortOrder));

    return rows.map((row) => ({
      id: row.id,
      item_id: row.itemId,
      quantity: row.quantity,
      unit: row.unit,
      purchase_price: row.purchasePrice,
      line_total: row.lineTotal,
      sort_order: row.sortOrder,
    }));
  }

  async replaceRawMaterials(
    businessId: string,
    orderId: string,
    lines: Array<{
      itemId: string;
      quantity: string;
      unit: string;
      purchasePrice: string;
      lineTotal: string;
      sortOrder: number;
    }>,
    userId?: string | null,
  ): Promise<void> {
    await this.db
      .update(jobWorkRawMaterialLines)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId ?? null,
      })
      .where(
        and(
          eq(jobWorkRawMaterialLines.jobWorkOrderId, orderId),
          eq(jobWorkRawMaterialLines.businessId, businessId),
          eq(jobWorkRawMaterialLines.isDeleted, false),
        ),
      );

    if (lines.length === 0) {
      return;
    }

    await this.db.insert(jobWorkRawMaterialLines).values(
      lines.map((line) => ({
        businessId,
        jobWorkOrderId: orderId,
        itemId: line.itemId,
        quantity: line.quantity,
        unit: line.unit,
        purchasePrice: line.purchasePrice,
        lineTotal: line.lineTotal,
        sortOrder: line.sortOrder,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      })),
    );
  }

  async listAdditionalCosts(businessId: string, orderId: string) {
    const rows = await this.db
      .select()
      .from(jobWorkAdditionalCosts)
      .where(
        and(
          eq(jobWorkAdditionalCosts.jobWorkOrderId, orderId),
          eq(jobWorkAdditionalCosts.businessId, businessId),
          eq(jobWorkAdditionalCosts.isDeleted, false),
        ),
      )
      .orderBy(asc(jobWorkAdditionalCosts.sortOrder));

    return rows.map((row) => ({
      id: row.id,
      label: row.label,
      amount: row.amount,
      sort_order: row.sortOrder,
    }));
  }

  async replaceAdditionalCosts(
    businessId: string,
    orderId: string,
    costs: Array<{ label: string; amount: string; sortOrder: number }>,
    userId?: string | null,
  ): Promise<void> {
    await this.db
      .update(jobWorkAdditionalCosts)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId ?? null,
      })
      .where(
        and(
          eq(jobWorkAdditionalCosts.jobWorkOrderId, orderId),
          eq(jobWorkAdditionalCosts.businessId, businessId),
          eq(jobWorkAdditionalCosts.isDeleted, false),
        ),
      );

    if (costs.length === 0) {
      return;
    }

    await this.db.insert(jobWorkAdditionalCosts).values(
      costs.map((cost) => ({
        businessId,
        jobWorkOrderId: orderId,
        label: cost.label,
        amount: cost.amount,
        sortOrder: cost.sortOrder,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      })),
    );
  }

  async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    const { users } = await import('../../db/schema/identity/tables.js');
    const [membership] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(membership);
  }
}

function toRecord(row: typeof jobWorkOrders.$inferSelect): JobWorkOrderRecord {
  return {
    id: row.id,
    party_id: row.partyId,
    job_number: row.jobNumber,
    status: row.status,
    order_date: row.orderDate.toISOString(),
    delivery_date: row.deliveryDate?.toISOString() ?? null,
    finished_good_name: row.finishedGoodName,
    finished_good_quantity: row.finishedGoodQuantity,
    finished_good_unit: row.finishedGoodUnit,
    raw_materials_total: row.rawMaterialsTotal,
    additional_costs_total: row.additionalCostsTotal,
    grand_total: row.grandTotal,
    notes: row.notes,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
