import { and, asc, desc, eq, lt } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  businesses,
  subscriptionHistory,
  subscriptionPayments,
  subscriptionPlans,
  subscriptions,
  users,
} from '../../db/schema';
import type {
  SubscriptionPlanCode,
  SubscriptionStatusCode,
} from './subscription.types';

export type DbExecutor = Database;

export class SubscriptionRepository {
  constructor(private readonly db: DbExecutor) {}

  async getActivePlans() {
    return this.db
      .select()
      .from(subscriptionPlans)
      .where(eq(subscriptionPlans.isActive, true))
      .orderBy(subscriptionPlans.plan);
  }

  async getPlanByCode(plan: SubscriptionPlanCode) {
    const [row] = await this.db
      .select()
      .from(subscriptionPlans)
      .where(eq(subscriptionPlans.plan, plan))
      .limit(1);
    return row ?? null;
  }

  async getBusinessById(businessId: string) {
    const [row] = await this.db
      .select()
      .from(businesses)
      .where(eq(businesses.id, businessId))
      .limit(1);
    return row ?? null;
  }

  async getBusinessOwnerName(businessId: string) {
    const [owner] = await this.db
      .select({ name: users.name })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.role, 'owner'),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);
    return owner?.name?.trim() ?? null;
  }

  async getActiveSubscription(businessId: string) {
    const [row] = await this.db
      .select()
      .from(subscriptions)
      .where(
        and(
          eq(subscriptions.businessId, businessId),
          eq(subscriptions.status, 'active'),
        ),
      )
      .orderBy(desc(subscriptions.createdAt))
      .limit(1);
    return row ?? null;
  }

  async createSubscription(input: {
    businessId: string;
    plan: SubscriptionPlanCode;
    status: SubscriptionStatusCode;
  }) {
    const [row] = await this.db
      .insert(subscriptions)
      .values({
        businessId: input.businessId,
        plan: input.plan,
        status: input.status,
      })
      .returning();
    return row;
  }

  async createPayment(input: {
    businessId: string;
    subscriptionId: string;
    plan: SubscriptionPlanCode;
    amount: string;
    currency: string;
    razorpayOrderId: string;
  }) {
    const [row] = await this.db
      .insert(subscriptionPayments)
      .values({
        businessId: input.businessId,
        subscriptionId: input.subscriptionId,
        plan: input.plan,
        amount: input.amount,
        currency: input.currency,
        razorpayOrderId: input.razorpayOrderId,
        paymentStatus: 'created',
      })
      .returning();
    return row;
  }

  async getPaymentById(paymentId: string) {
    const [row] = await this.db
      .select()
      .from(subscriptionPayments)
      .where(eq(subscriptionPayments.id, paymentId))
      .limit(1);
    return row ?? null;
  }

  async getPaymentByRazorpayOrderId(razorpayOrderId: string) {
    const [row] = await this.db
      .select()
      .from(subscriptionPayments)
      .where(eq(subscriptionPayments.razorpayOrderId, razorpayOrderId))
      .limit(1);
    return row ?? null;
  }

  async getSubscriptionById(subscriptionId: string) {
    const [row] = await this.db
      .select()
      .from(subscriptions)
      .where(eq(subscriptions.id, subscriptionId))
      .limit(1);
    return row ?? null;
  }

  async markPaymentPaid(input: {
    paymentId: string;
    razorpayPaymentId: string;
    paidAt: Date;
  }) {
    const [row] = await this.db
      .update(subscriptionPayments)
      .set({
        paymentStatus: 'paid',
        razorpayPaymentId: input.razorpayPaymentId,
        paidAt: input.paidAt,
      })
      .where(eq(subscriptionPayments.id, input.paymentId))
      .returning();
    return row ?? null;
  }

  async activateSubscription(input: {
    subscriptionId: string;
    startsAt: Date;
    expiresAt: Date;
  }) {
    const [row] = await this.db
      .update(subscriptions)
      .set({
        status: 'active',
        startsAt: input.startsAt,
        expiresAt: input.expiresAt,
        updatedAt: new Date(),
      })
      .where(eq(subscriptions.id, input.subscriptionId))
      .returning();
    return row ?? null;
  }

  async expireSubscription(subscriptionId: string) {
    const [row] = await this.db
      .update(subscriptions)
      .set({
        status: 'expired',
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(subscriptions.id, subscriptionId),
          eq(subscriptions.status, 'active'),
        ),
      )
      .returning();
    return row ?? null;
  }

  async expireActiveSubscriptionsForBusiness(
    businessId: string,
    excludeSubscriptionId?: string,
  ) {
    const rows = await this.db
      .select()
      .from(subscriptions)
      .where(
        and(
          eq(subscriptions.businessId, businessId),
          eq(subscriptions.status, 'active'),
        ),
      );

    const expired: typeof rows = [];
    for (const row of rows) {
      if (excludeSubscriptionId && row.id === excludeSubscriptionId) {
        continue;
      }
      const updated = await this.expireSubscription(row.id);
      if (updated) {
        expired.push(updated);
      }
    }
    return expired;
  }

  async updateBusinessPlan(input: {
    businessId: string;
    currentPlan: SubscriptionPlanCode;
    planStatus: SubscriptionStatusCode;
    planExpiresAt: Date | null;
  }) {
    const [row] = await this.db
      .update(businesses)
      .set({
        currentPlan: input.currentPlan,
        planStatus: input.planStatus,
        planExpiresAt: input.planExpiresAt,
        updatedAt: new Date(),
      })
      .where(eq(businesses.id, input.businessId))
      .returning();
    return row ?? null;
  }

  async insertHistory(input: {
    businessId: string;
    oldPlan: SubscriptionPlanCode;
    newPlan: SubscriptionPlanCode;
    event: string;
    metadata?: Record<string, unknown>;
  }) {
    const [row] = await this.db
      .insert(subscriptionHistory)
      .values({
        businessId: input.businessId,
        oldPlan: input.oldPlan,
        newPlan: input.newPlan,
        event: input.event,
        metadata: input.metadata ?? null,
      })
      .returning();
    return row;
  }

  async getHistory(businessId: string) {
    return (
      this.db
        .select()
        .from(subscriptionHistory)
        .where(eq(subscriptionHistory.businessId, businessId))
        // Phase 1 requirement: return chronological history (oldest -> newest).
        .orderBy(asc(subscriptionHistory.createdAt))
    );
  }

  async findExpiredActiveSubscriptions(now: Date) {
    return this.db
      .select()
      .from(subscriptions)
      .where(
        and(
          eq(subscriptions.status, 'active'),
          lt(subscriptions.expiresAt, now),
        ),
      );
  }
}
