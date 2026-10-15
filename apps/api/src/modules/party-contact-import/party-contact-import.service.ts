import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { CollaborationRepository } from '../collaboration/collaboration.repository';
import type { NotificationService } from '../notifications/notification.service';
import { getSharedNotificationService } from '../notifications/notification-service.factory';
import { normalizeMobile } from '../parties/party.utils';
import { toSessionDto } from './party-contact-import.mapper';
import { PartyContactImportRepository } from './party-contact-import.repository';
import type { ReplacePartyContactImportStagingBody } from './party-contact-import.schema';
import type {
  CreatePartyContactImportSessionDto,
  PartyContactImportPublicDto,
  PartyContactImportSessionDto,
} from './party-contact-import.types';
import {
  addMinutes,
  buildPartyContactImportDeepLink,
  buildPartyContactImportWebUrl,
  buildUrlQrDataUrl,
  generatePartyContactImportToken,
  MAX_PARTY_CONTACT_IMPORT_ROWS,
} from './party-contact-import.utils';

export class PartyContactImportService {
  private readonly repository: PartyContactImportRepository;
  private readonly collaborationRepository: CollaborationRepository;
  private readonly notificationService: NotificationService;
  private readonly config: AppConfig;

  constructor(config: AppConfig, notificationService?: NotificationService) {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new PartyContactImportRepository(db);
    this.collaborationRepository = new CollaborationRepository(db);
    this.notificationService =
      notificationService ?? getSharedNotificationService(config);
    this.config = config;
  }

  async createSession(
    businessId: string,
    accountId: string,
  ): Promise<CreatePartyContactImportSessionDto> {
    await this.assertBusinessAccess(businessId, accountId);

    const token = generatePartyContactImportToken();
    const expiresAt = addMinutes(
      new Date(),
      this.config.partyContactImportExpiryMinutes,
    );

    const session = await this.repository.createSession({
      businessId,
      createdByAccountId: accountId,
      token,
      expiresAt,
    });

    const webUrl = buildPartyContactImportWebUrl(this.config, token);
    const deepLinkUrl = buildPartyContactImportDeepLink(token);
    const qrDataUrl = await buildUrlQrDataUrl(webUrl);

    const owner = await this.collaborationRepository.getBusinessOwnerInfo(
      businessId,
    );
    const account =
      await this.collaborationRepository.getAccountById(accountId);

    let notificationSent = false;
    const phone = account?.phone;
    if (phone && owner) {
      const result = await this.notificationService.sendPartyContactImportLink(
        { phone },
        {
          companyName: owner.companyName,
          importUrl: webUrl,
          expiryMinutes: this.config.partyContactImportExpiryMinutes,
        },
        {
          idempotencyKey: `party_contact_import:${session.id}`,
          companyId: businessId,
        },
      );
      notificationSent = result.success;
      if (!result.success) {
        console.warn(
          JSON.stringify({
            msg: 'party_contact_import_notification_failed',
            session_id: session.id,
          }),
        );
      }
    }

    return {
      session_id: session.id,
      token,
      web_url: webUrl,
      deep_link_url: deepLinkUrl,
      qr_data_url: qrDataUrl,
      expires_at: expiresAt.toISOString(),
      notification_sent: notificationSent,
    };
  }

  async getSessionById(
    businessId: string,
    accountId: string,
    sessionId: string,
    includeStaging = false,
  ): Promise<PartyContactImportSessionDto> {
    await this.assertBusinessAccess(businessId, accountId);

    const session = await this.repository.findSessionById(sessionId);
    if (!session || session.businessId !== businessId) {
      throw new AppError('NOT_FOUND', 'Import session not found', 404);
    }

    const resolved = await this.repository.markExpiredIfNeeded(session);
    const stagingCount = await this.repository.countStagingRows(resolved.id);
    const stagingRows =
      includeStaging && resolved.status === 'submitted'
        ? await this.repository.listStagingRows(resolved.id)
        : undefined;

    return toSessionDto(resolved, stagingCount, { stagingRows });
  }

  async cancelSession(
    businessId: string,
    accountId: string,
    sessionId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const session = await this.repository.findSessionById(sessionId);
    if (!session || session.businessId !== businessId) {
      throw new AppError('NOT_FOUND', 'Import session not found', 404);
    }

    const cancelled = await this.repository.cancelSession(sessionId);
    if (!cancelled) {
      throw new AppError(
        'CONFLICT',
        'Import session cannot be cancelled in its current state',
        409,
      );
    }
  }

  async commitSession(
    businessId: string,
    accountId: string,
    sessionId: string,
  ): Promise<PartyContactImportSessionDto> {
    await this.assertBusinessAccess(businessId, accountId);

    const session = await this.repository.findSessionById(sessionId);
    if (!session || session.businessId !== businessId) {
      throw new AppError('NOT_FOUND', 'Import session not found', 404);
    }

    const resolved = await this.repository.markExpiredIfNeeded(session);
    if (resolved.status === 'completed') {
      const count = await this.repository.countStagingRows(resolved.id);
      return toSessionDto(resolved, count);
    }

    if (resolved.status !== 'submitted') {
      throw new AppError(
        'CONFLICT',
        'Import session is not ready to complete',
        409,
      );
    }

    const updated = await this.repository.updateSessionStatus(
      resolved.id,
      'completed',
      { completedAt: new Date() },
    );
    if (!updated) {
      throw new AppError('NOT_FOUND', 'Import session not found', 404);
    }

    const count = await this.repository.countStagingRows(updated.id);
    return toSessionDto(updated, count);
  }

  async getSessionByToken(
    token: string,
    accountId: string,
  ): Promise<PartyContactImportSessionDto> {
    const session = await this.repository.findSessionByToken(token);
    if (!session) {
      throw new AppError('NOT_FOUND', 'Import session not found', 404);
    }

    await this.assertBusinessAccess(session.businessId, accountId);

    let resolved = await this.repository.markExpiredIfNeeded(session);
    if (resolved.status === 'pending') {
      const opened = await this.repository.updateSessionStatus(
        resolved.id,
        'opened',
        { openedAt: new Date() },
      );
      if (opened) resolved = opened;
    }

    const owner = await this.collaborationRepository.getBusinessOwnerInfo(
      resolved.businessId,
    );
    const stagingCount = await this.repository.countStagingRows(resolved.id);

    return toSessionDto(resolved, stagingCount, {
      companyName: owner?.companyName,
    });
  }

  async replaceStagingByToken(
    token: string,
    accountId: string,
    body: ReplacePartyContactImportStagingBody,
  ): Promise<PartyContactImportSessionDto> {
    const session = await this.repository.findSessionByToken(token);
    if (!session) {
      throw new AppError('NOT_FOUND', 'Import session not found', 404);
    }

    await this.assertBusinessAccess(session.businessId, accountId);

    let resolved = await this.repository.markExpiredIfNeeded(session);
    if (resolved.status === 'expired' || resolved.status === 'cancelled') {
      throw new AppError('INVITATION_EXPIRED', 'Import session has expired', 410);
    }
    if (resolved.status === 'completed') {
      throw new AppError(
        'CONFLICT',
        'Import session is already completed',
        409,
      );
    }
    if (
      resolved.status !== 'pending' &&
      resolved.status !== 'opened' &&
      resolved.status !== 'submitted'
    ) {
      throw new AppError(
        'CONFLICT',
        'Import session cannot accept contacts',
        409,
      );
    }

    if (body.contacts.length > MAX_PARTY_CONTACT_IMPORT_ROWS) {
      throw new AppError(
        'VALIDATION_ERROR',
        `Maximum ${MAX_PARTY_CONTACT_IMPORT_ROWS} contacts per import`,
        400,
      );
    }

    const normalizedRows = body.contacts.map((contact, index) => {
      const phones = contact.phones
        .map((phone) => normalizeMobile(phone))
        .filter((phone): phone is string => phone != null && phone.length === 10);
      const uniquePhones = [...new Set(phones)];
      if (uniquePhones.length === 0) {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          [`contacts.${index}.phones`]: [
            'At least one valid 10-digit mobile number is required',
          ],
        });
      }
      return {
        sortOrder: index,
        displayName: contact.display_name.trim(),
        primaryPhone: uniquePhones[0]!,
        phones: uniquePhones,
        email: contact.email?.trim() || null,
        address: contact.address?.trim() || null,
      };
    });

    await this.repository.replaceStagingRows(resolved.id, normalizedRows);

    const updated = await this.repository.updateSessionStatus(
      resolved.id,
      'submitted',
      { submittedAt: new Date() },
    );
    if (!updated) {
      throw new AppError('NOT_FOUND', 'Import session not found', 404);
    }

    const stagingCount = await this.repository.countStagingRows(updated.id);
    const owner = await this.collaborationRepository.getBusinessOwnerInfo(
      updated.businessId,
    );

    return toSessionDto(updated, stagingCount, {
      companyName: owner?.companyName,
    });
  }

  async getPublicByToken(token: string): Promise<PartyContactImportPublicDto> {
    const session = await this.repository.findSessionByToken(token);
    if (!session) {
      throw new AppError('NOT_FOUND', 'Import session not found', 404);
    }

    const resolved = await this.repository.markExpiredIfNeeded(session);
    const owner = await this.collaborationRepository.getBusinessOwnerInfo(
      resolved.businessId,
    );
    if (!owner) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    return {
      company_name: owner.companyName,
      status: resolved.status,
      expires_at: resolved.expiresAt.toISOString(),
    };
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
}
