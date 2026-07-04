import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { BusinessMembershipRepository } from '../../shared/repositories/business-membership.repository';

export abstract class SalesServiceBase {
  protected readonly sharedRepository: BusinessMembershipRepository;

  protected constructor(db = getDb()) {
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.sharedRepository = new BusinessMembershipRepository(db);
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
