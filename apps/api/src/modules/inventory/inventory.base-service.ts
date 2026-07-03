import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { InventorySharedRepository } from './inventory.shared-repository';

export abstract class InventoryServiceBase {
  protected readonly sharedRepository: InventorySharedRepository;

  protected constructor(db = getDb()) {
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.sharedRepository = new InventorySharedRepository(db);
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
