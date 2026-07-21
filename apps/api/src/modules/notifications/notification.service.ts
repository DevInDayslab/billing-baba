import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import {
  buildPaymentReceivedNotification,
  buildPaymentReminderNotification,
  buildSaleInvoiceNotification,
  buildSyncShareInviteNotification,
  type PaymentReceivedNotificationInput,
  type PaymentReminderNotificationInput,
  type SaleInvoiceNotificationInput,
  type SyncShareInviteNotificationInput,
} from '../../notifications';
import {
  createNotificationProvider,
  type NotificationProvider,
  type NotificationSendResult,
} from '../../providers/notification';
import {
  maskPhoneE164,
  normalizeIndianMobile,
} from '../../shared/utils/phone-number';
import {
  logNotificationAttempt,
  toSafeNotificationErrorMessage,
} from './notification-logging';
import { NotificationSendLogRepository } from './notification-send-log.repository';

export type NotifyRecipient = {
  phone: string;
};

export type NotifyOptions = {
  idempotencyKey: string;
  companyId?: string | null;
};

/**
 * Application-facing notification facade.
 * Business modules call this service only — never Twilio or other providers.
 */
export class NotificationService {
  constructor(
    private readonly provider: NotificationProvider,
    private readonly config: Pick<
      AppConfig,
      | 'invitationExpiryDays'
      | 'notificationIdempotencyTtlHours'
      | 'environment'
      | 'twilioContentSidPaymentReminder'
    >,
    private readonly sendLog: NotificationSendLogRepository | null,
  ) {}

  static fromConfig(config: AppConfig): NotificationService {
    const db = getDb();
    const sendLog = db ? new NotificationSendLogRepository(db) : null;
    return new NotificationService(
      createNotificationProvider(config),
      config,
      sendLog,
    );
  }

  get providerName(): string {
    return this.provider.name;
  }

  async sendSyncShareInvite(
    recipient: NotifyRecipient,
    input: SyncShareInviteNotificationInput,
    options: NotifyOptions,
  ): Promise<NotificationSendResult> {
    const content = buildSyncShareInviteNotification({
      ...input,
      expiryDays: input.expiryDays ?? this.config.invitationExpiryDays,
    });

    return this.safeSend({
      to: recipient.phone,
      body: content.body,
      notificationType: content.type,
      idempotencyKey: options.idempotencyKey,
      companyId: options.companyId,
      metadata: {
        notificationType: content.type,
        companyName: input.companyName,
      },
    });
  }

  async sendPaymentReminder(
    recipient: NotifyRecipient,
    input: PaymentReminderNotificationInput,
    options: NotifyOptions,
  ): Promise<NotificationSendResult> {
    const content = buildPaymentReminderNotification(input);

    const freeform = await this.safeSend({
      to: recipient.phone,
      body: content.body,
      notificationType: content.type,
      idempotencyKey: options.idempotencyKey,
      companyId: options.companyId,
      metadata: {
        notificationType: content.type,
        companyName: input.companyName,
      },
    });

    if (freeform.success) return freeform;

    // Outside WhatsApp freeform window — retry with approved Content template.
    const contentSid = this.config.twilioContentSidPaymentReminder;
    if (
      freeform.error?.code === 'SESSION_WINDOW' &&
      contentSid &&
      this.provider.sendTemplate
    ) {
      const amount =
        typeof input.amount === 'number'
          ? input.amount.toLocaleString('en-IN')
          : String(input.amount);
      const templateResult = await this.provider.sendTemplate({
        to: recipient.phone,
        templateId: contentSid,
        variables: {
          '1': input.customerName,
          '2': amount,
          '3': input.companyName,
          '4': input.companyPhone?.trim() || '',
        },
        metadata: {
          notificationType: content.type,
          companyName: input.companyName,
        },
      });

      const phoneNorm = normalizeIndianMobile(recipient.phone);
      const maskedRecipient = phoneNorm.ok
        ? maskPhoneE164(phoneNorm.e164)
        : '****';

      logNotificationAttempt({
        notification_type: content.type,
        provider: this.provider.name,
        recipient: maskedRecipient,
        company_id: options.companyId ?? null,
        idempotency_key: `${options.idempotencyKey}:template`,
        status: templateResult.success ? 'success' : 'failure',
        provider_message_id: templateResult.providerMessageId ?? null,
        duration_ms: 0,
        error: templateResult.error?.code ?? null,
        timestamp: new Date().toISOString(),
      });

      if (templateResult.success) return templateResult;
      return {
        success: false,
        error: {
          code: templateResult.error?.code ?? 'SESSION_WINDOW',
          message: toSafeNotificationErrorMessage(
            templateResult.error?.code ?? 'SESSION_WINDOW',
          ),
          retryable: false,
          providerCode: templateResult.error?.providerCode,
        },
      };
    }

    return freeform;
  }

  /**
   * Available for callers; not wired into payment create/finalize yet.
   */
  async sendPaymentReceived(
    recipient: NotifyRecipient,
    input: PaymentReceivedNotificationInput,
    options: NotifyOptions,
  ): Promise<NotificationSendResult> {
    const content = buildPaymentReceivedNotification(input);
    const mediaUrl = input.mediaUrl?.trim();

    if (mediaUrl && this.provider.sendMedia) {
      return this.safeSendMedia({
        to: recipient.phone,
        body: content.body,
        mediaUrl,
        notificationType: content.type,
        idempotencyKey: options.idempotencyKey,
        companyId: options.companyId,
        metadata: {
          notificationType: content.type,
          companyName: input.companyName,
          hasMedia: true,
        },
      });
    }

    return this.safeSend({
      to: recipient.phone,
      body: content.body,
      notificationType: content.type,
      idempotencyKey: options.idempotencyKey,
      companyId: options.companyId,
      metadata: {
        notificationType: content.type,
        companyName: input.companyName,
      },
    });
  }

  async sendSaleInvoice(
    recipient: NotifyRecipient,
    input: SaleInvoiceNotificationInput,
    options: NotifyOptions,
  ): Promise<NotificationSendResult> {
    const content = buildSaleInvoiceNotification(input);
    const mediaUrl = input.mediaUrl?.trim();

    if (mediaUrl && this.provider.sendMedia) {
      return this.safeSendMedia({
        to: recipient.phone,
        body: content.body,
        mediaUrl,
        notificationType: content.type,
        idempotencyKey: options.idempotencyKey,
        companyId: options.companyId,
        metadata: {
          notificationType: content.type,
          companyName: input.companyName ?? null,
          hasMedia: true,
        },
      });
    }

    return this.safeSend({
      to: recipient.phone,
      body: content.body,
      notificationType: content.type,
      idempotencyKey: options.idempotencyKey,
      companyId: options.companyId,
      metadata: {
        notificationType: content.type,
        companyName: input.companyName ?? null,
      },
    });
  }

  /** Connectivity check — fixed copy, no business templates. */
  async sendTestMessage(
    recipient: NotifyRecipient,
    options: NotifyOptions,
  ): Promise<NotificationSendResult> {
    const body =
      '🏢 Billing Baba\n\nThis is a test WhatsApp message from Billing Baba. Your messaging setup is working.';
    return this.safeSend({
      to: recipient.phone,
      body,
      notificationType: 'test',
      idempotencyKey: options.idempotencyKey,
      companyId: options.companyId,
      metadata: { notificationType: 'test' },
    });
  }

  /**
   * Never throws — provider failures become structured results so business
   * flows (e.g. invitation create) are not rolled back by messaging issues.
   */
  private async safeSend(params: {
    to: string;
    body: string;
    notificationType: string;
    idempotencyKey: string;
    companyId?: string | null;
    metadata: Record<string, unknown>;
  }): Promise<NotificationSendResult> {
    const started = Date.now();
    const phoneResult = normalizeIndianMobile(params.to);
    if (!phoneResult.ok) {
      const result: NotificationSendResult = {
        success: false,
        error: {
          code: 'INVALID_NUMBER',
          message: toSafeNotificationErrorMessage('INVALID_NUMBER'),
          retryable: false,
        },
      };
      logNotificationAttempt({
        notification_type: params.notificationType,
        provider: this.provider.name,
        recipient: '****',
        company_id: params.companyId ?? null,
        idempotency_key: params.idempotencyKey,
        status: 'failure',
        provider_message_id: null,
        duration_ms: Date.now() - started,
        error: 'INVALID_NUMBER',
        timestamp: new Date().toISOString(),
      });
      return result;
    }

    const e164 = phoneResult.e164;
    const masked = maskPhoneE164(e164);

    try {
      if (this.sendLog) {
        const since = new Date();
        since.setHours(
          since.getHours() - this.config.notificationIdempotencyTtlHours,
        );
        const prior = await this.sendLog.findRecentSuccess(
          params.idempotencyKey,
          since,
          this.provider.name,
        );
        if (prior) {
          logNotificationAttempt({
            notification_type: params.notificationType,
            provider: this.provider.name,
            recipient: masked,
            company_id: params.companyId ?? null,
            idempotency_key: params.idempotencyKey,
            status: 'deduped',
            provider_message_id: prior.providerMessageId,
            duration_ms: Date.now() - started,
            error: null,
            timestamp: new Date().toISOString(),
          });
          return {
            success: true,
            providerMessageId: prior.providerMessageId ?? undefined,
            deduped: true,
          };
        }
      }

      const result = await this.provider.sendText({
        to: e164,
        body: params.body,
        metadata: params.metadata,
      });

      if (result.success && this.sendLog) {
        try {
          const saved = await this.sendLog.insertSuccess({
            idempotencyKey: params.idempotencyKey,
            notificationType: params.notificationType,
            provider: this.provider.name,
            recipientMasked: masked,
            companyId: params.companyId,
            status: 'success',
            providerMessageId: result.providerMessageId ?? null,
          });
          if (!saved.inserted && saved.row.status === 'success') {
            logNotificationAttempt({
              notification_type: params.notificationType,
              provider: this.provider.name,
              recipient: masked,
              company_id: params.companyId ?? null,
              idempotency_key: params.idempotencyKey,
              status: 'deduped',
              provider_message_id: saved.row.providerMessageId,
              duration_ms: Date.now() - started,
              error: null,
              timestamp: new Date().toISOString(),
            });
            return {
              success: true,
              providerMessageId: saved.row.providerMessageId ?? undefined,
              deduped: true,
            };
          }
        } catch {
          // Idempotency log is best-effort — never fail the send on log errors.
        }
      }

      const safeResult: NotificationSendResult = result.success
        ? result
        : {
            success: false,
            error: result.error
              ? {
                  ...result.error,
                  message: toSafeNotificationErrorMessage(result.error.code),
                }
              : {
                  code: 'PROVIDER_ERROR',
                  message: toSafeNotificationErrorMessage('PROVIDER_ERROR'),
                  retryable: false,
                },
          };

      logNotificationAttempt({
        notification_type: params.notificationType,
        provider: this.provider.name,
        recipient: masked,
        company_id: params.companyId ?? null,
        idempotency_key: params.idempotencyKey,
        status: safeResult.success ? 'success' : 'failure',
        provider_message_id: safeResult.providerMessageId ?? null,
        duration_ms: Date.now() - started,
        error: safeResult.error?.code ?? null,
        timestamp: new Date().toISOString(),
      });

      return safeResult;
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : 'Unexpected notification failure';
      logNotificationAttempt({
        notification_type: params.notificationType,
        provider: this.provider.name,
        recipient: masked,
        company_id: params.companyId ?? null,
        idempotency_key: params.idempotencyKey,
        status: 'failure',
        provider_message_id: null,
        duration_ms: Date.now() - started,
        error: 'PROVIDER_ERROR',
        timestamp: new Date().toISOString(),
      });
      // Do not leak raw exception text to callers
      void message;
      return {
        success: false,
        error: {
          code: 'PROVIDER_ERROR',
          message: toSafeNotificationErrorMessage('PROVIDER_ERROR'),
          retryable: false,
        },
      };
    }
  }

  private async safeSendMedia(params: {
    to: string;
    body: string;
    mediaUrl: string;
    notificationType: string;
    idempotencyKey: string;
    companyId?: string | null;
    metadata: Record<string, unknown>;
  }): Promise<NotificationSendResult> {
    if (!this.provider.sendMedia) {
      return this.safeSend({
        to: params.to,
        body: params.body,
        notificationType: params.notificationType,
        idempotencyKey: params.idempotencyKey,
        companyId: params.companyId,
        metadata: params.metadata,
      });
    }

    const started = Date.now();
    const phoneResult = normalizeIndianMobile(params.to);
    if (!phoneResult.ok) {
      return {
        success: false,
        error: {
          code: 'INVALID_NUMBER',
          message: toSafeNotificationErrorMessage('INVALID_NUMBER'),
          retryable: false,
        },
      };
    }

    const e164 = phoneResult.e164;
    const masked = maskPhoneE164(e164);

    try {
      if (this.sendLog) {
        const since = new Date();
        since.setHours(
          since.getHours() - this.config.notificationIdempotencyTtlHours,
        );
        const prior = await this.sendLog.findRecentSuccess(
          params.idempotencyKey,
          since,
          this.provider.name,
        );
        if (prior) {
          return {
            success: true,
            providerMessageId: prior.providerMessageId ?? undefined,
            deduped: true,
          };
        }
      }

      const result = await this.provider.sendMedia({
        to: e164,
        body: params.body,
        mediaUrl: params.mediaUrl,
        metadata: params.metadata,
      });

      if (result.success && this.sendLog) {
        try {
          await this.sendLog.insertSuccess({
            idempotencyKey: params.idempotencyKey,
            notificationType: params.notificationType,
            provider: this.provider.name,
            recipientMasked: masked,
            companyId: params.companyId,
            status: 'success',
            providerMessageId: result.providerMessageId ?? null,
          });
        } catch {
          // best-effort
        }
      }

      logNotificationAttempt({
        notification_type: params.notificationType,
        provider: this.provider.name,
        recipient: masked,
        company_id: params.companyId ?? null,
        idempotency_key: params.idempotencyKey,
        status: result.success ? 'success' : 'failure',
        provider_message_id: result.providerMessageId ?? null,
        duration_ms: Date.now() - started,
        error: result.error?.code ?? null,
        timestamp: new Date().toISOString(),
      });

      return result.success
        ? result
        : {
            success: false,
            error: result.error
              ? {
                  ...result.error,
                  message: toSafeNotificationErrorMessage(result.error.code),
                }
              : {
                  code: 'PROVIDER_ERROR',
                  message: toSafeNotificationErrorMessage('PROVIDER_ERROR'),
                  retryable: false,
                },
          };
    } catch {
      return {
        success: false,
        error: {
          code: 'PROVIDER_ERROR',
          message: toSafeNotificationErrorMessage('PROVIDER_ERROR'),
          retryable: false,
        },
      };
    }
  }
}
