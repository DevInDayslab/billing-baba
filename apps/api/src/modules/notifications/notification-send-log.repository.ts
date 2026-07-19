import { and, desc, eq, gt } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { notificationSendLog } from '../../db/schema';

export type NotificationSendLogInsert = {
  idempotencyKey: string;
  notificationType: string;
  provider: string;
  recipientMasked: string;
  companyId?: string | null;
  status: 'success' | 'failure';
  providerMessageId?: string | null;
  errorCode?: string | null;
};

export class NotificationSendLogRepository {
  constructor(private readonly db: Database) {}

  async findRecentSuccess(
    idempotencyKey: string,
    since: Date,
    provider?: string,
  ): Promise<{
    providerMessageId: string | null;
    createdAt: Date;
    provider: string;
  } | null> {
    const [row] = await this.db
      .select({
        providerMessageId: notificationSendLog.providerMessageId,
        createdAt: notificationSendLog.createdAt,
        status: notificationSendLog.status,
        provider: notificationSendLog.provider,
      })
      .from(notificationSendLog)
      .where(
        and(
          eq(notificationSendLog.idempotencyKey, idempotencyKey),
          eq(notificationSendLog.status, 'success'),
          gt(notificationSendLog.createdAt, since),
          ...(provider
            ? [eq(notificationSendLog.provider, provider)]
            : []),
        ),
      )
      .orderBy(desc(notificationSendLog.createdAt))
      .limit(1);

    if (!row) return null;
    return {
      providerMessageId: row.providerMessageId,
      createdAt: row.createdAt,
      provider: row.provider,
    };
  }

  async findByKey(idempotencyKey: string) {
    const [row] = await this.db
      .select()
      .from(notificationSendLog)
      .where(eq(notificationSendLog.idempotencyKey, idempotencyKey))
      .limit(1);
    return row ?? null;
  }

  async insertSuccess(values: NotificationSendLogInsert) {
    try {
      const [row] = await this.db
        .insert(notificationSendLog)
        .values({
          idempotencyKey: values.idempotencyKey,
          notificationType: values.notificationType,
          provider: values.provider,
          recipientMasked: values.recipientMasked,
          companyId: values.companyId ?? null,
          status: 'success',
          providerMessageId: values.providerMessageId ?? null,
          errorCode: null,
        })
        .returning();
      return { inserted: true as const, row };
    } catch (error) {
      // Unique violation — concurrent duplicate
      const existing = await this.findByKey(values.idempotencyKey);
      if (existing?.status === 'success') {
        return {
          inserted: false as const,
          row: existing,
        };
      }
      throw error;
    }
  }
}
