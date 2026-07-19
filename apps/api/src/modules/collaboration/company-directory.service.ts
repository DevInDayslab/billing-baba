import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import {
  toPendingInvitationDto,
  toSharedCompanyDto,
} from './collaboration.mapper';
import { CollaborationRepository } from './collaboration.repository';
import type {
  PendingInvitationDto,
  SharedCompanyDto,
} from './collaboration.types';
import { isExpired } from './collaboration.utils';

export class CompanyDirectoryService {
  private readonly repository: CollaborationRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new CollaborationRepository(db);
  }

  async listSharedCompanies(accountId: string): Promise<SharedCompanyDto[]> {
    const memberships =
      await this.repository.listActiveSharedCompanies(accountId);

    const results: SharedCompanyDto[] = [];
    for (const membership of memberships) {
      const owner = await this.repository.getBusinessOwnerInfo(
        membership.companyId,
      );
      if (!owner) continue;

      results.push(toSharedCompanyDto(owner, membership.role, membership.id));
    }

    return results;
  }

  async listPendingInvitations(
    accountId: string,
    phone: string,
  ): Promise<PendingInvitationDto[]> {
    const account = await this.repository.getAccountById(accountId);
    const email = account?.email ?? null;

    const invitations = await this.repository.listPendingInvitationsForAccount(
      phone,
      email,
    );

    const results: PendingInvitationDto[] = [];
    for (const invitation of invitations) {
      if (invitation.status === 'accepted') continue;

      const owner = await this.repository.getBusinessOwnerInfo(
        invitation.companyId,
      );
      if (!owner) continue;

      const expired =
        invitation.status === 'expired' ||
        (isExpired(invitation.expiresAt) &&
          (invitation.status === 'pending' || invitation.status === 'opened'));

      if (
        expired &&
        (invitation.status === 'pending' || invitation.status === 'opened')
      ) {
        await this.repository.markInvitationExpired(invitation.id);
      }

      if (
        invitation.status === 'cancelled' ||
        invitation.status === 'rejected'
      ) {
        continue;
      }

      results.push(toPendingInvitationDto(invitation, owner, expired));
    }

    return results;
  }
}
