import { describe, expect, mock, test } from 'bun:test';
import type { NotificationSendLogRepository } from '../../../src/modules/notifications/notification-send-log.repository';
import { NotificationService } from '../../../src/modules/notifications/notification.service';
import type {
  NotificationProvider,
  NotificationSendResult,
  SendTextParams,
} from '../../../src/providers/notification';

describe('NotificationService idempotency', () => {
  test('reuses recent successful send without calling provider', async () => {
    const sendText = mock(
      async (_params: SendTextParams): Promise<NotificationSendResult> => ({
        success: true,
        providerMessageId: 'SM123',
      }),
    );
    const provider: NotificationProvider = {
      name: 'mock',
      sendText,
    };
    const sendLog = {
      findRecentSuccess: mock(async () => ({
        providerMessageId: 'SM_PRIOR',
        createdAt: new Date(),
      })),
      insertSuccess: mock(async () => ({ inserted: true, row: null })),
      findByKey: mock(async () => null),
    } as unknown as NotificationSendLogRepository;

    const service = new NotificationService(
      provider,
      {
        invitationExpiryDays: 7,
        notificationIdempotencyTtlHours: 24,
        environment: 'test',
      },
      sendLog,
    );

    const result = await service.sendPaymentReminder(
      { phone: '8920108002' },
      {
        customerName: 'Ravi',
        companyName: 'Acme',
        amount: '100',
        dueDate: '20 Jul 2026',
        invoiceUrl: 'https://billingbaba.com/invoice/tok',
      },
      {
        idempotencyKey: 'reminder:doc:party',
        companyId: '11111111-1111-1111-1111-111111111111',
      },
    );

    expect(result.success).toBe(true);
    expect(result.deduped).toBe(true);
    expect(result.providerMessageId).toBe('SM_PRIOR');
    expect(sendText).toHaveBeenCalledTimes(0);
  });

  test('sends when no prior success and records log', async () => {
    const sendText = mock(
      async (_params: SendTextParams): Promise<NotificationSendResult> => ({
        success: true,
        providerMessageId: 'SM123',
      }),
    );
    const provider: NotificationProvider = {
      name: 'mock',
      sendText,
    };
    const insertSuccess = mock(async () => ({
      inserted: true as const,
      row: { status: 'success', providerMessageId: 'SM123' },
    }));
    const sendLog = {
      findRecentSuccess: mock(async () => null),
      insertSuccess,
      findByKey: mock(async () => null),
    } as unknown as NotificationSendLogRepository;

    const service = new NotificationService(
      provider,
      {
        invitationExpiryDays: 7,
        notificationIdempotencyTtlHours: 24,
        environment: 'test',
      },
      sendLog,
    );

    const result = await service.sendSaleInvoice(
      { phone: '+918920108002' },
      {
        customerName: 'Ravi',
        invoiceNumber: 'INV-1',
        amount: 50,
        invoiceUrl: 'https://billingbaba.com/invoice/x',
      },
      { idempotencyKey: 'invoice:abc' },
    );

    expect(result.success).toBe(true);
    expect(result.deduped).toBeUndefined();
    expect(sendText).toHaveBeenCalledTimes(1);
    expect(insertSuccess).toHaveBeenCalledTimes(1);
  });

  test('rejects invalid phone without calling provider', async () => {
    const sendText = mock(
      async (_params: SendTextParams): Promise<NotificationSendResult> => ({
        success: true,
        providerMessageId: 'SM123',
      }),
    );
    const provider: NotificationProvider = {
      name: 'mock',
      sendText,
    };
    const service = new NotificationService(
      provider,
      {
        invitationExpiryDays: 7,
        notificationIdempotencyTtlHours: 24,
        environment: 'test',
      },
      null,
    );

    const result = await service.sendSyncShareInvite(
      { phone: '123' },
      {
        companyName: 'Acme',
        inviteUrl: 'https://billingbaba.com/invite/ABC',
        expiryDays: 7,
      },
      { idempotencyKey: 'invite:1' },
    );

    expect(result.success).toBe(false);
    expect(result.error?.code).toBe('INVALID_NUMBER');
    expect(sendText).toHaveBeenCalledTimes(0);
  });
});
