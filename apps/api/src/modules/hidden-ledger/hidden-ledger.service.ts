import { getDb } from '../../db/client';
import type { Database } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { canViewHiddenLedger } from '../../shared/hidden-ledger/hidden-ledger-access';
import type { UserRole } from '../auth/auth.types';
import { HiddenLedgerRepository } from './hidden-ledger.repository';
import type {
  ListHiddenLedgerEntriesQuery,
  ListHiddenLedgerRecoveriesQuery,
} from './hidden-ledger.schema';
import type {
  HiddenLedgerEntryDetailRecord,
  HiddenLedgerEntryRecord,
  HiddenLedgerPartySummary,
  HiddenLedgerRecoveryRecord,
} from './hidden-ledger.types';
import { normalizeMoney, parseMoney } from '../inventory/inventory.utils';

export class HiddenLedgerService {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: HiddenLedgerRepository;

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
    this.repository = new HiddenLedgerRepository(db);
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

  private assertHiddenLedgerAccess(role?: UserRole): void {
    if (!canViewHiddenLedger(role)) {
      throw new AppError(
        'FORBIDDEN',
        'Hidden ledger access is restricted to owner and manager roles',
        403,
      );
    }
  }

  async listEntries(
    businessId: string,
    accountId: string,
    role: UserRole | undefined,
    query: ListHiddenLedgerEntriesQuery,
  ): Promise<{
    data: HiddenLedgerEntryRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    this.assertHiddenLedgerAccess(role);

    const result = await this.repository.listEntries({
      businessId,
      page: query.page,
      limit: query.limit,
      partyId: query.party_id,
      status: query.status,
      from: query.from ? new Date(query.from) : undefined,
      to: query.to ? new Date(query.to) : undefined,
      q: query.q,
      invoiceNumber: query.invoice_number,
      sort: query.sort,
      order: query.order,
    });

    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getEntry(
    businessId: string,
    accountId: string,
    role: UserRole | undefined,
    entryId: string,
  ): Promise<HiddenLedgerEntryDetailRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    this.assertHiddenLedgerAccess(role);

    const entry = await this.repository.findEntryById(businessId, entryId);
    if (!entry) {
      throw new AppError('NOT_FOUND', 'Hidden ledger entry not found', 404);
    }

    const recoveries = await this.repository.listRecoveries(
      businessId,
      entryId,
      1,
      100,
    );

    return { ...entry, recoveries: recoveries.rows };
  }

  async listRecoveries(
    businessId: string,
    accountId: string,
    role: UserRole | undefined,
    entryId: string,
    query: ListHiddenLedgerRecoveriesQuery,
  ): Promise<{
    data: HiddenLedgerRecoveryRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    this.assertHiddenLedgerAccess(role);

    const entry = await this.repository.findEntryById(businessId, entryId);
    if (!entry) {
      throw new AppError('NOT_FOUND', 'Hidden ledger entry not found', 404);
    }

    const result = await this.repository.listRecoveries(
      businessId,
      entryId,
      query.page,
      query.limit,
    );

    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getPartySummary(
    businessId: string,
    accountId: string,
    role: UserRole | undefined,
    partyId: string,
  ): Promise<HiddenLedgerPartySummary> {
    await this.assertBusinessAccess(businessId, accountId);
    this.assertHiddenLedgerAccess(role);

    const summary = await this.repository.getPartySummary(businessId, partyId);
    if (!summary) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    return summary;
  }

  /** Records a short-payment shortfall routed to the hidden ledger during checkout. */
  async recordShortPaymentEntry(params: {
    businessId: string;
    partyId: string;
    salesDocumentId: string;
    shortfallAmount: string;
    userId?: string | null;
    db?: Database;
  }): Promise<HiddenLedgerEntryRecord> {
    const repo = new HiddenLedgerRepository(params.db ?? this.db);

    const entry = await repo.createEntry({
      businessId: params.businessId,
      partyId: params.partyId,
      saleId: params.salesDocumentId,
      invoiceId: params.salesDocumentId,
      amount: params.shortfallAmount,
      createdBy: params.userId ?? null,
      updatedBy: params.userId ?? null,
    });

    const current = parseMoney(
      (await repo.findPartyHiddenLedgerBalance(
        params.businessId,
        params.partyId,
      )) ?? '0',
    );
    const shortfall = parseMoney(params.shortfallAmount);
    await repo.updatePartyHiddenLedgerBalance(
      params.businessId,
      params.partyId,
      normalizeMoney(current + shortfall),
      params.userId ?? null,
    );

    return entry;
  }

  /** Applies manual recovery from a sale markup, FIFO across open entries. */
  async recordSaleRecovery(params: {
    businessId: string;
    accountId: string;
    role: UserRole | undefined;
    partyId: string;
    saleId: string;
    recoveryAmount: string;
    userId?: string | null;
  }): Promise<{
    recovered_amount: string;
    recoveries: HiddenLedgerRecoveryRecord[];
  }> {
    await this.assertBusinessAccess(params.businessId, params.accountId);
    this.assertHiddenLedgerAccess(params.role);

    const amount = parseMoney(params.recoveryAmount);
    if (amount <= 0) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Recovery amount must be greater than zero',
        422,
      );
    }

    const balance = parseMoney(
      (await this.repository.findPartyHiddenLedgerBalance(
        params.businessId,
        params.partyId,
      )) ?? '0',
    );
    if (amount > balance) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Recovery amount exceeds hidden ledger balance',
        422,
      );
    }

    const existingRecovery = await this.repository.sumRecoveriesForSale(
      params.businessId,
      params.saleId,
    );
    if (existingRecovery > 0) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Recovery has already been recorded for this sale',
        422,
      );
    }

    return this.db.transaction(async (tx) => {
      const repo = new HiddenLedgerRepository(tx as unknown as typeof this.db);

      const duplicateInTx = await repo.sumRecoveriesForSale(
        params.businessId,
        params.saleId,
      );
      if (duplicateInTx > 0) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Recovery has already been recorded for this sale',
          422,
        );
      }

      const entries = await repo.listRecoverableEntries(
        params.businessId,
        params.partyId,
      );

      if (entries.length === 0) {
        throw new AppError(
          'VALIDATION_ERROR',
          'No recoverable hidden ledger entries for this party',
          422,
        );
      }

      let remaining = amount;
      const recoveries: HiddenLedgerRecoveryRecord[] = [];

      for (const entry of entries) {
        if (remaining <= 0) break;

        const entryRemaining = parseMoney(entry.remaining_amount);
        if (entryRemaining <= 0) continue;

        const chunk = Math.min(remaining, entryRemaining);
        const chunkAmount = normalizeMoney(chunk);

        const recovery = await repo.createRecoveryRecord({
          businessId: params.businessId,
          ledgerEntryId: entry.id,
          saleId: params.saleId,
          recoveredAmount: chunkAmount,
          recoveredBy: params.userId ?? null,
        });

        const updatedEntry = await repo.applyRecoveryToEntry({
          businessId: params.businessId,
          entryId: entry.id,
          recoveryAmount: chunkAmount,
          updatedBy: params.userId ?? null,
        });

        if (!updatedEntry) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Cannot recover from a fully recovered hidden ledger entry',
            422,
          );
        }

        recoveries.push(recovery);
        remaining -= chunk;
      }

      if (remaining > 0.0001) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Insufficient open hidden ledger entries for recovery',
          422,
        );
      }

      await repo.updatePartyHiddenLedgerBalance(
        params.businessId,
        params.partyId,
        normalizeMoney(balance - amount),
        params.userId ?? null,
      );

      return {
        recovered_amount: normalizeMoney(amount),
        recoveries,
      };
    });
  }
}
