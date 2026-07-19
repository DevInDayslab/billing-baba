import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { getSharedNotificationService } from '../notifications/notification-service.factory';
import type { NotificationService } from '../notifications/notification.service';
import {
  buildInvitationUrl,
  toInvitationDto,
  toInvitationPublicDto,
} from './collaboration.mapper';
import {
  CollaborationRepository,
  generateInvitationToken,
} from './collaboration.repository';
import type { CreateInvitationBody } from './collaboration.schema';
import type {
  AcceptInvitationResult,
  InvitationDto,
  InvitationPublicDto,
  InvitationRow,
} from './collaboration.types';
import {
  addDays,
  isExpired,
  parseContactOrThrow,
  roleDisplayLabel,
} from './collaboration.utils';

export class InvitationService {
  private readonly repository: CollaborationRepository;
  private readonly notificationService: NotificationService;
  private readonly config: AppConfig;

  constructor(
    config: AppConfig,
    notificationService?: NotificationService,
  ) {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new CollaborationRepository(db);
    this.notificationService =
      notificationService ?? getSharedNotificationService(config);
    this.config = config;
  }

  async createInvitation(
    businessId: string,
    accountId: string,
    input: CreateInvitationBody,
  ): Promise<InvitationDto> {
    const isOwner = await this.repository.isBusinessOwner(
      businessId,
      accountId,
    );
    if (!isOwner) {
      throw new AppError(
        'FORBIDDEN',
        'Only the business owner can send invitations',
        403,
      );
    }

    let phone: string | null;
    let email: string | null;
    try {
      ({ phone, email } = parseContactOrThrow(input.phone_or_email));
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Invalid phone or email';
      throw new AppError('INVALID_PHONE', message, 400);
    }

    if (!phone && !email) {
      throw new AppError(
        'INVALID_PHONE',
        'A valid phone number or email is required',
        400,
      );
    }

    const existingMember = await this.repository.findActiveMemberByContact(
      businessId,
      phone,
      email,
    );
    if (existingMember) {
      throw new AppError(
        'CONFLICT',
        'This contact is already a member of the company',
        409,
      );
    }

    const existingInvite = await this.repository.findActiveInvitationByContact(
      businessId,
      phone,
      email,
    );
    if (existingInvite) {
      throw new AppError(
        'CONFLICT',
        'An active invitation already exists for this contact',
        409,
      );
    }

    const token = await this.generateUniqueInvitationToken();
    const expiresAt = addDays(new Date(), this.config.invitationExpiryDays);

    const invitation = await this.repository.createInvitation({
      companyId: businessId,
      inviteeName: input.full_name,
      phone,
      email,
      role: input.role,
      createdBy: accountId,
      expiresAt,
      token,
    });

    const owner = await this.repository.getBusinessOwnerInfo(businessId);
    if (!owner) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    if (phone) {
      const result = await this.notificationService.sendSyncShareInvite(
        { phone },
        {
          companyName: owner.companyName,
          roleLabel: roleDisplayLabel(input.role),
          phone,
          email,
          inviteUrl: buildInvitationUrl(this.config, token),
          expiryDays: this.config.invitationExpiryDays,
        },
        {
          idempotencyKey: `invite:${invitation.id}`,
          companyId: businessId,
        },
      );
      if (!result.success) {
        console.warn(
          JSON.stringify({
            msg: 'invite_notification_failed',
            invitation_id: invitation.id,
            error: result.error?.code ?? 'UNKNOWN',
          }),
        );
      }
    }

    return toInvitationDto(invitation);
  }

  private async generateUniqueInvitationToken(): Promise<string> {
    for (let attempt = 0; attempt < 8; attempt++) {
      const token = generateInvitationToken();
      const existing = await this.repository.findInvitationByToken(token);
      if (!existing) {
        return token;
      }
    }

    throw new AppError(
      'INVITATION_TOKEN_CONFLICT',
      'Could not generate a unique invitation code',
      500,
    );
  }

  async getInvitationByToken(token: string): Promise<InvitationPublicDto> {
    const invitation = await this.repository.findInvitationByToken(token);
    if (!invitation) {
      throw new AppError('INVITATION_NOT_FOUND', 'Invitation not found', 404);
    }

    const resolved = await this.resolveInvitationForRead(invitation);
    const owner = await this.repository.getBusinessOwnerInfo(
      resolved.companyId,
    );
    if (!owner) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    return toInvitationPublicDto(resolved, owner, this.config);
  }

  async acceptInvitation(token: string): Promise<AcceptInvitationResult> {
    const invitation = await this.repository.findInvitationByToken(token);
    if (!invitation) {
      throw new AppError('INVITATION_NOT_FOUND', 'Invitation not found', 404);
    }

    const resolved = await this.ensureActionableInvitation(invitation);

    const account = await this.repository.findOrCreateAccount({
      phone: resolved.phone,
      email: resolved.email,
      name: resolved.inviteeName,
    });

    const existingMember = await this.repository.findActiveMemberByContact(
      resolved.companyId,
      resolved.phone,
      resolved.email,
    );
    if (existingMember) {
      throw new AppError(
        'INVITATION_ALREADY_ACCEPTED',
        'Invitation has already been accepted',
        409,
      );
    }

    const accepted = await this.repository.markInvitationAccepted(resolved.id);
    if (!accepted) {
      throw new AppError(
        'INVITATION_NOT_ACTIONABLE',
        'Invitation cannot be accepted in its current state',
        409,
      );
    }

    const member = await this.repository.createCompanyMember({
      companyId: resolved.companyId,
      accountId: account.id,
      role: resolved.role,
      joinedAt: new Date(),
    });

    const owner = await this.repository.getBusinessOwnerInfo(
      resolved.companyId,
    );
    if (!owner) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    return {
      invitation: toInvitationPublicDto(accepted, owner, this.config),
      member_id: member.id,
    };
  }

  async rejectInvitation(token: string): Promise<InvitationPublicDto> {
    const invitation = await this.repository.findInvitationByToken(token);
    if (!invitation) {
      throw new AppError('INVITATION_NOT_FOUND', 'Invitation not found', 404);
    }

    await this.ensureActionableInvitation(invitation);

    const rejected = await this.repository.markInvitationRejected(
      invitation.id,
    );
    if (!rejected) {
      throw new AppError(
        'INVITATION_NOT_ACTIONABLE',
        'Invitation cannot be rejected in its current state',
        409,
      );
    }

    const owner = await this.repository.getBusinessOwnerInfo(
      invitation.companyId,
    );
    if (!owner) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    return toInvitationPublicDto(rejected, owner, this.config);
  }

  async reinvite(
    invitationId: string,
    businessId: string,
    accountId: string,
  ): Promise<InvitationDto> {
    const isOwner = await this.repository.isBusinessOwner(
      businessId,
      accountId,
    );
    if (!isOwner) {
      throw new AppError(
        'FORBIDDEN',
        'Only the business owner can reinvite members',
        403,
      );
    }

    const existing = await this.repository.findInvitationById(invitationId);
    if (!existing || existing.companyId !== businessId) {
      throw new AppError('INVITATION_NOT_FOUND', 'Invitation not found', 404);
    }

    const reinvitableStatuses = ['rejected', 'expired', 'left', 'cancelled'];
    if (!reinvitableStatuses.includes(existing.status)) {
      throw new AppError(
        'INVITATION_NOT_ACTIONABLE',
        'Only rejected, expired, left, or cancelled invitations can be reinvited',
        409,
      );
    }

    const token = await this.generateUniqueInvitationToken();
    const expiresAt = addDays(new Date(), this.config.invitationExpiryDays);

    const newInvitation = await this.repository.createInvitation({
      companyId: existing.companyId,
      inviteeName: existing.inviteeName,
      phone: existing.phone,
      email: existing.email,
      role: existing.role,
      createdBy: accountId,
      expiresAt,
      token,
    });

    await this.repository.cancelInvitation(existing.id, newInvitation.id);

    const owner = await this.repository.getBusinessOwnerInfo(businessId);
    if (!owner) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    if (existing.phone) {
      const result = await this.notificationService.sendSyncShareInvite(
        { phone: existing.phone },
        {
          companyName: owner.companyName,
          roleLabel: roleDisplayLabel(existing.role),
          phone: existing.phone,
          email: existing.email,
          inviteUrl: buildInvitationUrl(this.config, token),
          expiryDays: this.config.invitationExpiryDays,
        },
        {
          idempotencyKey: `invite:${newInvitation.id}`,
          companyId: businessId,
        },
      );
      if (!result.success) {
        console.warn(
          JSON.stringify({
            msg: 'invite_notification_failed',
            invitation_id: newInvitation.id,
            error: result.error?.code ?? 'UNKNOWN',
          }),
        );
      }
    }

    return toInvitationDto(newInvitation);
  }

  async listInvitations(
    businessId: string,
    accountId: string,
  ): Promise<InvitationDto[]> {
    const isOwner = await this.repository.isBusinessOwner(
      businessId,
      accountId,
    );
    if (!isOwner) {
      throw new AppError(
        'FORBIDDEN',
        'Only the business owner can list invitations',
        403,
      );
    }

    const rows = await this.repository.listInvitationsForCompany(businessId);
    return rows.map((row) => toInvitationDto(row));
  }

  async cancelInvitation(
    invitationId: string,
    businessId: string,
    accountId: string,
  ): Promise<InvitationDto> {
    const isOwner = await this.repository.isBusinessOwner(
      businessId,
      accountId,
    );
    if (!isOwner) {
      throw new AppError(
        'FORBIDDEN',
        'Only the business owner can cancel invitations',
        403,
      );
    }

    const existing = await this.repository.findInvitationById(invitationId);
    if (!existing || existing.companyId !== businessId) {
      throw new AppError('INVITATION_NOT_FOUND', 'Invitation not found', 404);
    }

    if (existing.status !== 'pending' && existing.status !== 'opened') {
      throw new AppError(
        'INVITATION_NOT_ACTIONABLE',
        'Only pending invitations can be cancelled',
        409,
      );
    }

    const cancelled = await this.repository.cancelInvitation(existing.id, null);
    if (!cancelled) {
      throw new AppError(
        'INVITATION_NOT_ACTIONABLE',
        'Invitation cannot be cancelled in its current state',
        409,
      );
    }

    return toInvitationDto(cancelled);
  }

  private async resolveInvitationForRead(
    invitation: InvitationRow,
  ): Promise<InvitationRow> {
    if (invitation.status === 'accepted') {
      return invitation;
    }

    if (
      isExpired(invitation.expiresAt) &&
      (invitation.status === 'pending' || invitation.status === 'opened')
    ) {
      await this.repository.markInvitationExpired(invitation.id);
      throw new AppError(
        'INVITATION_EXPIRED',
        'This invitation has expired',
        410,
      );
    }

    if (invitation.status === 'rejected') {
      throw new AppError(
        'INVITATION_NOT_ACTIONABLE',
        'This invitation was rejected',
        409,
      );
    }

    if (invitation.status === 'cancelled') {
      throw new AppError('INVITATION_NOT_FOUND', 'Invitation not found', 404);
    }

    if (invitation.status === 'expired') {
      throw new AppError(
        'INVITATION_EXPIRED',
        'This invitation has expired',
        410,
      );
    }

    if (invitation.status === 'pending') {
      const opened = await this.repository.markInvitationOpened(invitation.id);
      if (opened) {
        return opened;
      }
      const refreshed = await this.repository.findInvitationById(invitation.id);
      if (!refreshed) {
        throw new AppError('INVITATION_NOT_FOUND', 'Invitation not found', 404);
      }
      return refreshed;
    }

    return invitation;
  }

  private async ensureActionableInvitation(
    invitation: InvitationRow,
  ): Promise<InvitationRow> {
    if (invitation.status === 'accepted') {
      throw new AppError(
        'INVITATION_ALREADY_ACCEPTED',
        'Invitation has already been accepted',
        409,
      );
    }

    if (
      isExpired(invitation.expiresAt) &&
      (invitation.status === 'pending' || invitation.status === 'opened')
    ) {
      await this.repository.markInvitationExpired(invitation.id);
      throw new AppError(
        'INVITATION_EXPIRED',
        'This invitation has expired',
        410,
      );
    }

    if (invitation.status === 'expired') {
      throw new AppError(
        'INVITATION_EXPIRED',
        'This invitation has expired',
        410,
      );
    }

    if (invitation.status === 'rejected') {
      throw new AppError(
        'INVITATION_NOT_ACTIONABLE',
        'Invitation was already rejected',
        409,
      );
    }

    if (invitation.status === 'cancelled') {
      throw new AppError('INVITATION_NOT_FOUND', 'Invitation not found', 404);
    }

    if (invitation.status === 'pending') {
      const opened = await this.repository.markInvitationOpened(invitation.id);
      return opened ?? invitation;
    }

    return invitation;
  }
}
