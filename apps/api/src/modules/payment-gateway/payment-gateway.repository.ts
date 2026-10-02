import { and, asc, eq, inArray, lt } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { businesses } from '../../db/schema/business/tables';
import { parties } from '../../db/schema/crm/tables';
import { users } from '../../db/schema/identity/tables';
import {
  GATEWAY_INTENT_PAYLOAD_VERSION,
  type GatewayIntentPayload,
  gatewayPaymentIntents,
  gatewayReconciliationJobs,
} from '../../db/schema/payments/gateway-tables';
import type {
  GatewayPaymentIntentStatus,
  GatewayPaymentIntentType,
} from './payment-gateway.types';

export type DbExecutor = Database;

export class PaymentGatewayRepository {
  constructor(private readonly db: Database) {}

  async getBusinessById(businessId: string) {
    const [row] = await this.db
      .select({
        id: businesses.id,
        name: businesses.name,
        email: businesses.email,
        phone: businesses.phone,
        currency: businesses.currency,
      })
      .from(businesses)
      .where(eq(businesses.id, businessId))
      .limit(1);
    return row ?? null;
  }

  async getPartyById(businessId: string, partyId: string) {
    const [row] = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        email: parties.email,
        mobile: parties.mobile,
      })
      .from(parties)
      .where(
        and(
          eq(parties.businessId, businessId),
          eq(parties.id, partyId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async hasBusinessMembership(businessId: string, accountId: string) {
    const [row] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  async findByIdempotencyKey(businessId: string, idempotencyKey: string) {
    const [row] = await this.db
      .select()
      .from(gatewayPaymentIntents)
      .where(
        and(
          eq(gatewayPaymentIntents.businessId, businessId),
          eq(gatewayPaymentIntents.idempotencyKey, idempotencyKey),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async findById(businessId: string, intentId: string) {
    const [row] = await this.db
      .select()
      .from(gatewayPaymentIntents)
      .where(
        and(
          eq(gatewayPaymentIntents.id, intentId),
          eq(gatewayPaymentIntents.businessId, businessId),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async findByIdGlobal(intentId: string) {
    const [row] = await this.db
      .select()
      .from(gatewayPaymentIntents)
      .where(eq(gatewayPaymentIntents.id, intentId))
      .limit(1);
    return row ?? null;
  }

  async findByRazorpayOrderId(razorpayOrderId: string) {
    const [row] = await this.db
      .select()
      .from(gatewayPaymentIntents)
      .where(eq(gatewayPaymentIntents.razorpayOrderId, razorpayOrderId))
      .limit(1);
    return row ?? null;
  }

  async createIntent(input: {
    id: string;
    businessId: string;
    intentType: GatewayPaymentIntentType;
    intentPayload: GatewayIntentPayload;
    businessName: string;
    customerName: string;
    customerPhone?: string | null;
    customerEmail?: string | null;
    amountPaise: number;
    currency: string;
    razorpayOrderId: string;
    idempotencyKey?: string;
  }) {
    const [row] = await this.db
      .insert(gatewayPaymentIntents)
      .values({
        id: input.id,
        businessId: input.businessId,
        intentType: input.intentType,
        intentPayloadVersion: GATEWAY_INTENT_PAYLOAD_VERSION,
        intentPayload: input.intentPayload,
        businessName: input.businessName,
        customerName: input.customerName,
        customerPhone: input.customerPhone ?? null,
        customerEmail: input.customerEmail ?? null,
        amountPaise: input.amountPaise,
        currency: input.currency,
        razorpayOrderId: input.razorpayOrderId,
        idempotencyKey: input.idempotencyKey ?? null,
        status: 'created',
      })
      .returning();
    return row ?? null;
  }

  async updateIntentStatus(input: {
    intentId: string;
    status: GatewayPaymentIntentStatus;
    razorpayPaymentId?: string;
    accountingPaymentId?: string;
    failureReason?: string;
    paidAt?: Date;
    verifiedAt?: Date;
  }) {
    const [row] = await this.db
      .update(gatewayPaymentIntents)
      .set({
        status: input.status,
        razorpayPaymentId: input.razorpayPaymentId,
        accountingPaymentId: input.accountingPaymentId,
        failureReason: input.failureReason,
        paidAt: input.paidAt,
        verifiedAt: input.verifiedAt,
        updatedAt: new Date(),
      })
      .where(eq(gatewayPaymentIntents.id, input.intentId))
      .returning();
    return row ?? null;
  }

  async listPendingVerification(businessId: string) {
    return this.db
      .select()
      .from(gatewayPaymentIntents)
      .where(
        and(
          eq(gatewayPaymentIntents.businessId, businessId),
          inArray(gatewayPaymentIntents.status, [
            'callback_received',
            'verifying',
          ]),
        ),
      );
  }

  async enqueueReconciliationJob(input: {
    intentId: string;
    event: string;
    razorpayOrderId: string;
    razorpayPaymentId?: string;
    payload?: Record<string, unknown>;
  }) {
    const [row] = await this.db
      .insert(gatewayReconciliationJobs)
      .values({
        intentId: input.intentId,
        event: input.event,
        razorpayOrderId: input.razorpayOrderId,
        razorpayPaymentId: input.razorpayPaymentId ?? null,
        payload: input.payload ?? null,
        status: 'pending',
      })
      .returning();
    return row ?? null;
  }

  async claimPendingReconciliationJobs(limit = 10) {
    const pending = await this.db
      .select()
      .from(gatewayReconciliationJobs)
      .where(
        and(
          eq(gatewayReconciliationJobs.status, 'pending'),
          lt(gatewayReconciliationJobs.attempts, 5),
        ),
      )
      .orderBy(asc(gatewayReconciliationJobs.createdAt))
      .limit(limit);

    const claimed = [];
    for (const job of pending) {
      const [updated] = await this.db
        .update(gatewayReconciliationJobs)
        .set({
          status: 'processing',
          attempts: job.attempts + 1,
        })
        .where(
          and(
            eq(gatewayReconciliationJobs.id, job.id),
            eq(gatewayReconciliationJobs.status, 'pending'),
          ),
        )
        .returning();
      if (updated) {
        claimed.push(updated);
      }
    }
    return claimed;
  }

  async completeReconciliationJob(jobId: string) {
    await this.db
      .update(gatewayReconciliationJobs)
      .set({ status: 'completed', processedAt: new Date() })
      .where(eq(gatewayReconciliationJobs.id, jobId));
  }

  async failReconciliationJob(jobId: string, error: string) {
    await this.db
      .update(gatewayReconciliationJobs)
      .set({
        status: 'pending',
        lastError: error,
        processedAt: new Date(),
      })
      .where(eq(gatewayReconciliationJobs.id, jobId));
  }
}
