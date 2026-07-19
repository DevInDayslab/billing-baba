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
      'invitationExpiryDays' | 'notificationIdempotencyTtlHours' | 'environment'
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

  /**
   * Available for callers; not wired into payment create/finalize yet.
   */
  async sendPaymentReceived(
    recipient: NotifyRecipient,
    input: PaymentReceivedNotificationInput,
    options: NotifyOptions,
  ): Promise<NotificationSendResult> {
    const content = buildPaymentReceivedNotification(input);
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
}
