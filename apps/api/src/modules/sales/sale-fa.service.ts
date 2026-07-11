import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { SaleFaRepository } from './sale-fa.repository';
import type {
  CreateSaleFaBody,
  ListSaleFaQuery,
  UpdateSaleFaBody,
} from './sale-fa.schema';
import type {
  SaleFaAssetInput,
  SaleFaBatchListRecord,
  SaleFaBatchRecord,
} from './sale-fa.types';
import { SalesServiceBase } from './sales.base-service';

export class SaleFaService extends SalesServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: SaleFaRepository;

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
    this.repository = new SaleFaRepository(db);
  }

  async listBatches(
    businessId: string,
    accountId: string,
    query: ListSaleFaQuery,
  ): Promise<{
    data: SaleFaBatchListRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      partyId: query.party_id,
      status: query.status,
      from: query.from,
      to: query.to,
      sort: query.sort,
      order: query.order,
    });
    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getBatch(
    businessId: string,
    accountId: string,
    batchId: string,
  ): Promise<SaleFaBatchRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const batch = await this.repository.findById(businessId, batchId);
    if (!batch) {
      throw new AppError('NOT_FOUND', 'Fixed asset sale not found', 404);
    }
    return batch;
  }

  async createBatch(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateSaleFaBody,
  ): Promise<SaleFaBatchRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertPartyExists(businessId, input.party_id);
    await this.validateAssets(businessId, input.assets);

    return this.repository.createBatch(
      businessId,
      {
        partyId: input.party_id,
        referenceNumber: input.reference_number ?? null,
        saleDate: input.sale_date,
        dueDate: input.due_date ?? null,
        paymentMode: input.payment_mode ?? null,
        subtotal: input.subtotal ?? input.total_amount,
        taxAmount: input.tax_amount ?? '0',
        totalAmount: input.total_amount,
        balanceDue: input.balance_due ?? input.total_amount,
        status: input.status ?? 'unpaid',
        notes: input.notes ?? null,
        description: input.description ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      },
      input.assets,
    );
  }

  async updateBatch(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    batchId: string,
    input: UpdateSaleFaBody,
  ): Promise<SaleFaBatchRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, batchId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Fixed asset sale not found', 404);
    }

    if (input.party_id) {
      await this.assertPartyExists(businessId, input.party_id);
    }
    if (input.assets) {
      await this.validateAssets(businessId, input.assets);
    }

    const updated = await this.repository.updateBatch(
      businessId,
      batchId,
      {
        ...(input.party_id !== undefined ? { partyId: input.party_id } : {}),
        ...(input.reference_number !== undefined
          ? { referenceNumber: input.reference_number }
          : {}),
        ...(input.sale_date !== undefined ? { saleDate: input.sale_date } : {}),
        ...(input.due_date !== undefined ? { dueDate: input.due_date } : {}),
        ...(input.payment_mode !== undefined
          ? { paymentMode: input.payment_mode }
          : {}),
        ...(input.subtotal !== undefined ? { subtotal: input.subtotal } : {}),
        ...(input.tax_amount !== undefined
          ? { taxAmount: input.tax_amount }
          : {}),
        ...(input.total_amount !== undefined
          ? { totalAmount: input.total_amount }
          : {}),
        ...(input.balance_due !== undefined
          ? { balanceDue: input.balance_due }
          : {}),
        ...(input.status !== undefined ? { status: input.status } : {}),
        ...(input.notes !== undefined ? { notes: input.notes } : {}),
        ...(input.description !== undefined
          ? { description: input.description }
          : {}),
        updatedBy: userId ?? null,
      },
      input.assets,
    );

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Fixed asset sale not found', 404);
    }
    return updated;
  }

  async deleteBatch(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    batchId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    const deleted = await this.repository.softDeleteBatch(
      businessId,
      batchId,
      userId ?? null,
    );
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Fixed asset sale not found', 404);
    }
  }

  private async assertPartyExists(
    businessId: string,
    partyId: string,
  ): Promise<void> {
    const exists = await this.repository.partyExists(businessId, partyId);
    if (!exists) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }
  }

  private async validateAssets(
    businessId: string,
    assets: SaleFaAssetInput[],
  ): Promise<void> {
    for (const asset of assets) {
      if (Number(asset.sale_price) <= 0) {
        throw new AppError(
          'INVALID_AMOUNT',
          'Sale price must be greater than zero',
          422,
        );
      }
      if (asset.serial_number) {
        const exists = await this.repository.serialExists(
          businessId,
          asset.serial_number,
          asset.id,
        );
        if (exists) {
          throw new AppError(
            'DUPLICATE_SERIAL',
            `Serial number already exists: ${asset.serial_number}`,
            409,
          );
        }
      }
    }
  }
}
