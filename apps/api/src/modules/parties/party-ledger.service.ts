import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { PartyRepository } from './party.repository';
import { PartyLedgerRepository } from './party-ledger.repository';
import type { PartyLedgerQuery } from './party-ledger.schema';
import type { PartyLedgerPayload } from './party-ledger.types';

export class PartyLedgerService {
  private readonly repository: PartyLedgerRepository;
  private readonly partyRepository: PartyRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new PartyLedgerRepository(db);
    this.partyRepository = new PartyRepository(db);
  }

  async getPartyLedger(
    businessId: string,
    accountId: string,
    partyId: string,
    query: PartyLedgerQuery,
  ): Promise<PartyLedgerPayload> {
    await this.assertBusinessAccess(businessId, accountId);

    const payload = await this.repository.getPartyLedger(businessId, partyId, {
      filter: query.filter,
      from: query.from,
      to: query.to,
    });

    if (!payload) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    return payload;
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.partyRepository.hasBusinessMembership(
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
}
