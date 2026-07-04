import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { SalesSharedRepository } from './sales.shared-repository';

export abstract class SalesServiceBase {
  protected readonly sharedRepository: SalesSharedRepository;

  protected constructor(db = getDb()) {
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.sharedRepository = new SalesSharedRepository(db);
  }

  protected async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.sharedRepository.hasBusinessMembership(
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
