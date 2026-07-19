import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { CollaborationRepository } from './collaboration.repository';

export class CompanyMemberService {
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

  async leaveCompany(memberId: string, accountId: string): Promise<void> {
    const member = await this.repository.findCompanyMemberById(memberId);
    if (!member) {
      throw new AppError('MEMBER_NOT_FOUND', 'Company member not found', 404);
    }

    if (member.accountId !== accountId) {
      throw new AppError(
        'FORBIDDEN',
        'You can only leave companies you belong to',
        403,
      );
    }

    if (member.status !== 'active') {
      throw new AppError(
        'INVITATION_NOT_ACTIONABLE',
        'You have already left this company',
        409,
      );
    }

    const left = await this.repository.markMemberLeft(memberId);
    if (!left) {
      throw new AppError('MEMBER_NOT_FOUND', 'Company member not found', 404);
    }

    await this.repository.markInvitationLeftByMember(
      member.companyId,
      accountId,
    );
  }
}
