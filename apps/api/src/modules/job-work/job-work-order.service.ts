import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { normalizeMoney, parseMoney } from '../inventory/inventory.utils';
import { JobWorkOrderRepository } from './job-work-order.repository';
import type {
  CreateJobWorkOrderBody,
  ListJobWorkOrdersQuery,
  UpdateJobWorkOrderBody,
} from './job-work-order.schema';
import type { JobWorkOrderRecord } from './job-work-order.types';

export class JobWorkOrderService {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: JobWorkOrderRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = db;
    this.repository = new JobWorkOrderRepository(db);
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.repository.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!hasAccess) {
      throw new AppError(
        'FORBIDDEN',
        'You do not have access to this business',
        403,
      );
    }
  }

  async list(
    businessId: string,
    accountId: string,
    query: ListJobWorkOrdersQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      status: query.status,
      partyId: query.party_id,
      sort: query.sort,
      order: query.order,
    });

    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getById(
    businessId: string,
    accountId: string,
    orderId: string,
  ): Promise<JobWorkOrderRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const order = await this.repository.findById(businessId, orderId, true);
    if (!order) {
      throw new AppError('NOT_FOUND', 'Job work order not found', 404);
    }

    return order;
  }

  async create(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateJobWorkOrderBody,
  ): Promise<JobWorkOrderRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const totals = this.computeTotals(
      input.raw_materials ?? [],
      input.additional_costs ?? [],
    );

    const order = await this.repository.create({
      businessId,
      partyId: input.party_id ?? null,
      jobNumber: input.job_number ?? null,
      orderDate: input.order_date ? new Date(input.order_date) : undefined,
      deliveryDate: input.delivery_date ? new Date(input.delivery_date) : null,
      finishedGoodName: input.finished_good_name,
      finishedGoodQuantity: input.finished_good_quantity,
      finishedGoodUnit: input.finished_good_unit,
      rawMaterialsTotal: totals.rawMaterialsTotal,
      additionalCostsTotal: totals.additionalCostsTotal,
      grandTotal: totals.grandTotal,
      notes: input.notes ?? null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });

    await this.repository.replaceRawMaterials(
      businessId,
      order.id,
      (input.raw_materials ?? []).map((line, index) => ({
        itemId: line.item_id,
        quantity: line.quantity,
        unit: line.unit,
        purchasePrice: line.purchase_price ?? '0',
        lineTotal: normalizeMoney(
          parseMoney(line.quantity) * parseMoney(line.purchase_price ?? '0'),
        ),
        sortOrder: index,
      })),
      userId ?? null,
    );

    await this.repository.replaceAdditionalCosts(
      businessId,
      order.id,
      (input.additional_costs ?? []).map((cost, index) => ({
        label: cost.label,
        amount: cost.amount,
        sortOrder: index,
      })),
      userId ?? null,
    );

    return this.getById(businessId, accountId, order.id);
  }

  async update(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    orderId: string,
    input: UpdateJobWorkOrderBody,
  ): Promise<JobWorkOrderRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, orderId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Job work order not found', 404);
    }

    let totals:
      | {
          rawMaterialsTotal: string;
          additionalCostsTotal: string;
          grandTotal: string;
        }
      | undefined;

    if (input.raw_materials || input.additional_costs) {
      totals = this.computeTotals(
        input.raw_materials ?? [],
        input.additional_costs ?? [],
      );
    }

    const updated = await this.repository.update(businessId, orderId, {
      partyId: input.party_id,
      jobNumber: input.job_number,
      deliveryDate: input.delivery_date
        ? new Date(input.delivery_date)
        : undefined,
      finishedGoodName: input.finished_good_name,
      finishedGoodQuantity: input.finished_good_quantity,
      finishedGoodUnit: input.finished_good_unit,
      status: input.status,
      notes: input.notes,
      rawMaterialsTotal: totals?.rawMaterialsTotal,
      additionalCostsTotal: totals?.additionalCostsTotal,
      grandTotal: totals?.grandTotal,
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Job work order not found', 404);
    }

    if (input.raw_materials) {
      await this.repository.replaceRawMaterials(
        businessId,
        orderId,
        input.raw_materials.map((line, index) => ({
          itemId: line.item_id,
          quantity: line.quantity,
          unit: line.unit,
          purchasePrice: line.purchase_price ?? '0',
          lineTotal: normalizeMoney(
            parseMoney(line.quantity) * parseMoney(line.purchase_price ?? '0'),
          ),
          sortOrder: index,
        })),
        userId ?? null,
      );
    }

    if (input.additional_costs) {
      await this.repository.replaceAdditionalCosts(
        businessId,
        orderId,
        input.additional_costs.map((cost, index) => ({
          label: cost.label,
          amount: cost.amount,
          sortOrder: index,
        })),
        userId ?? null,
      );
    }

    return this.getById(businessId, accountId, orderId);
  }

  async delete(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    orderId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const deleted = await this.repository.softDelete(
      businessId,
      orderId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Job work order not found', 404);
    }
  }

  private computeTotals(
    rawMaterials: Array<{ quantity: string; purchase_price?: string }>,
    additionalCosts: Array<{ amount: string }>,
  ) {
    const rawMaterialsTotal = rawMaterials.reduce(
      (sum, line) =>
        sum +
        parseMoney(line.quantity) * parseMoney(line.purchase_price ?? '0'),
      0,
    );
    const additionalCostsTotal = additionalCosts.reduce(
      (sum, cost) => sum + parseMoney(cost.amount),
      0,
    );

    return {
      rawMaterialsTotal: normalizeMoney(rawMaterialsTotal),
      additionalCostsTotal: normalizeMoney(additionalCostsTotal),
      grandTotal: normalizeMoney(rawMaterialsTotal + additionalCostsTotal),
    };
  }
}
