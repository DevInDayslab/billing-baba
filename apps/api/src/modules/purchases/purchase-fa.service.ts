import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { PurchaseFaRepository } from './purchase-fa.repository';
import type {
  CreatePurchaseFaBody,
  ListPurchaseFaQuery,
  UpdatePurchaseFaBody,
} from './purchase-fa.schema';
import type {
  PurchaseFaAssetInput,
  PurchaseFaBatchListRecord,
  PurchaseFaBatchRecord,
} from './purchase-fa.types';
import { PurchasesServiceBase } from './purchases.base-service';

export class PurchaseFaService extends PurchasesServiceBase {
  private readonly repository: PurchaseFaRepository;

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
    this.repository = new PurchaseFaRepository(db);
  }

  async listBatches(
    businessId: string,
    accountId: string,
    query: ListPurchaseFaQuery,
  ): Promise<{
    data: PurchaseFaBatchListRecord[];
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
  ): Promise<PurchaseFaBatchRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const batch = await this.repository.findById(businessId, batchId);
    if (!batch) {
      throw new AppError('NOT_FOUND', 'Fixed asset purchase not found', 404);
    }
    return batch;
  }

  async createBatch(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreatePurchaseFaBody,
  ): Promise<PurchaseFaBatchRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertPartyExists(businessId, input.party_id);
    await this.validateAssets(businessId, input.assets);

    return this.repository.createBatch(
      businessId,
      {
        partyId: input.party_id,
        referenceNumber: input.reference_number ?? null,
        purchaseDate: input.purchase_date,
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
    input: UpdatePurchaseFaBody,
  ): Promise<PurchaseFaBatchRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, batchId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Fixed asset purchase not found', 404);
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
        ...(input.purchase_date !== undefined
          ? { purchaseDate: input.purchase_date }
          : {}),
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
      throw new AppError('NOT_FOUND', 'Fixed asset purchase not found', 404);
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
      throw new AppError('NOT_FOUND', 'Fixed asset purchase not found', 404);
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
    assets: PurchaseFaAssetInput[],
  ): Promise<void> {
    for (const asset of assets) {
      if (Number(asset.purchase_price) <= 0) {
        throw new AppError(
          'INVALID_AMOUNT',
          'Purchase price must be greater than zero',
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
