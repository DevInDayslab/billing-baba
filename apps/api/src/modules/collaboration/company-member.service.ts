import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import {
  invitationToMemberDto,
  toOwnerMemberDto,
} from './collaboration.mapper';
import { assertCollaborationAction } from './collaboration.permissions';
import { CollaborationRepository } from './collaboration.repository';
import type { UpdateCompanyMemberBody } from './collaboration.schema';
import type { CompanyMemberDto } from './collaboration.types';

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

  private async assertOwner(
    businessId: string,
    accountId: string,
    action: 'members:update' | 'members:delete',
  ) {
    const isOwner = await this.repository.isBusinessOwner(
      businessId,
      accountId,
    );
    assertCollaborationAction(isOwner, action);
    return isOwner;
  }

  private async assertCanReadMembers(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const isOwner = await this.repository.isBusinessOwner(
      businessId,
      accountId,
    );
    if (isOwner) return;

    const isMember = await this.repository.hasActiveCompanyMembership(
      businessId,
      accountId,
    );
    if (!isMember) {
      throw new AppError(
        'FORBIDDEN',
        'You do not have access to this company',
        403,
      );
    }
  }

  async listMembers(
    businessId: string,
    accountId: string,
  ): Promise<CompanyMemberDto[]> {
    await this.assertCanReadMembers(businessId, accountId);

    const owner = await this.repository.getBusinessOwnerInfo(businessId);
    if (!owner) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    const ownerAccountId =
      (await this.repository.getBusinessOwnerAccountId(businessId)) ?? '';
    const currentAccount = await this.repository.getAccountById(accountId);

    const invitations =
      await this.repository.listInvitationsForCompany(businessId);

    const latestByPlaceholder = new Map<string, (typeof invitations)[number]>();
    for (const invitation of invitations) {
      latestByPlaceholder.set(invitation.placeholderMemberId, invitation);
    }

    const members: CompanyMemberDto[] = [
      toOwnerMemberDto(owner, accountId, ownerAccountId),
      ...Array.from(latestByPlaceholder.values()).map((row) =>
        invitationToMemberDto(row, currentAccount),
      ),
    ];

    return members;
  }

  async updateMember(
    memberId: string,
    businessId: string,
    accountId: string,
    body: UpdateCompanyMemberBody,
  ): Promise<CompanyMemberDto> {
    await this.assertOwner(businessId, accountId, 'members:update');

    if (memberId.startsWith('owner-')) {
      throw new AppError(
        'FORBIDDEN',
        'The business owner role cannot be changed',
        403,
      );
    }

    const invitation =
      await this.repository.findLatestInvitationByPlaceholderMemberId(
        businessId,
        memberId,
      );
    if (!invitation) {
      throw new AppError('MEMBER_NOT_FOUND', 'Company member not found', 404);
    }

    if (invitation.status === 'pending' || invitation.status === 'opened') {
      const updated = await this.repository.updateInvitationRole(
        invitation.id,
        body.role,
      );
      if (!updated) {
        throw new AppError(
          'INVITATION_NOT_ACTIONABLE',
          'Invitation cannot be updated in its current state',
          409,
        );
      }
      const currentAccount = await this.repository.getAccountById(accountId);
      return invitationToMemberDto(updated, currentAccount);
    }

    if (invitation.status === 'accepted' || invitation.status === 'left') {
      const activeMember =
        await this.repository.findActiveCompanyMemberByContact(
          businessId,
          invitation.phone,
          invitation.email,
        );
      if (!activeMember) {
        throw new AppError('MEMBER_NOT_FOUND', 'Company member not found', 404);
      }

      const updatedMember = await this.repository.updateCompanyMemberRole(
        activeMember.id,
        body.role,
      );
      if (!updatedMember) {
        throw new AppError(
          'INVITATION_NOT_ACTIONABLE',
          'Member cannot be updated in its current state',
          409,
        );
      }

      const updatedInvitation = await this.repository.updateInvitationRole(
        invitation.id,
        body.role,
      );
      const currentAccount = await this.repository.getAccountById(accountId);
      return invitationToMemberDto(
        updatedInvitation ?? invitation,
        currentAccount,
      );
    }

    throw new AppError(
      'INVITATION_NOT_ACTIONABLE',
      'Only pending or joined members can be updated',
      409,
    );
  }

  async removeMember(
    memberId: string,
    businessId: string,
    accountId: string,
  ): Promise<void> {
    await this.assertOwner(businessId, accountId, 'members:delete');

    if (memberId.startsWith('owner-')) {
      throw new AppError(
        'FORBIDDEN',
        'The business owner cannot be removed',
        403,
      );
    }

    const invitation =
      await this.repository.findLatestInvitationByPlaceholderMemberId(
        businessId,
        memberId,
      );
    if (!invitation) {
      throw new AppError('MEMBER_NOT_FOUND', 'Company member not found', 404);
    }

    if (invitation.status === 'pending' || invitation.status === 'opened') {
      const cancelled = await this.repository.cancelInvitation(
        invitation.id,
        null,
      );
      if (!cancelled) {
        throw new AppError(
          'INVITATION_NOT_ACTIONABLE',
          'Invitation cannot be cancelled in its current state',
          409,
        );
      }
      return;
    }

    if (invitation.status === 'accepted') {
      const activeMember =
        await this.repository.findActiveCompanyMemberByContact(
          businessId,
          invitation.phone,
          invitation.email,
        );
      if (!activeMember) {
        throw new AppError('MEMBER_NOT_FOUND', 'Company member not found', 404);
      }

      const removed = await this.repository.markMemberRemoved(activeMember.id);
      if (!removed) {
        throw new AppError(
          'INVITATION_NOT_ACTIONABLE',
          'Member cannot be removed in its current state',
          409,
        );
      }

      await this.repository.markInvitationRemovedByContact(
        businessId,
        invitation.phone,
        invitation.email,
      );

      if (activeMember.accountId) {
        await this.repository.deactivateCollaboratorUser(
          businessId,
          activeMember.accountId,
        );
      }
      return;
    }

    throw new AppError(
      'INVITATION_NOT_ACTIONABLE',
      'Only pending or joined members can be removed',
      409,
    );
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

    await this.repository.deactivateCollaboratorUser(
      member.companyId,
      accountId,
    );
  }
}
