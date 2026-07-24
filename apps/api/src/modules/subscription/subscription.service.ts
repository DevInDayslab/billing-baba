import type { FastifyBaseLogger } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { RazorpayService } from './razorpay.service';
import {
  PLAN_DISPLAY_NAMES,
  PURCHASABLE_PLANS,
  RAZORPAY_WEBHOOK_EVENTS,
  SUBSCRIPTION_HISTORY_EVENTS,
} from './subscription.constants';
import { SubscriptionRepository } from './subscription.repository';
import type { DbExecutor } from './subscription.repository';
import type {
  CreateOrderInput,
  CurrentSubscriptionResponse,
  PlanCatalogItem,
  SubscriptionHistoryItem,
  SubscriptionPlanCode,
  VerifyPaymentInput,
  VerifyPaymentResponse,
} from './subscription.types';

type WebhookPayload = {
  event?: string;
  payload?: {
    payment?: { entity?: { id?: string; order_id?: string } };
    order?: { entity?: { id?: string } };
  };
};

function toIso(date: Date | null | undefined): string | null {
  return date ? date.toISOString() : null;
}

function remainingDays(expiresAt: Date | null | undefined): number | null {
  if (!expiresAt) {
    return null;
  }
  const diffMs = expiresAt.getTime() - Date.now();
  return Math.max(0, Math.ceil(diffMs / (1000 * 60 * 60 * 24)));
}

function priceToPaise(price: string): number {
  return Math.round(Number.parseFloat(price) * 100);
}

function resolvePurchaseEvent(
  oldPlan: SubscriptionPlanCode,
  newPlan: SubscriptionPlanCode,
): string {
  if (oldPlan === 'no_plan') {
    return SUBSCRIPTION_HISTORY_EVENTS.PURCHASED;
  }
  if (oldPlan === 'gold' && newPlan === 'platinum') {
    return SUBSCRIPTION_HISTORY_EVENTS.UPGRADED;
  }
  if (oldPlan === newPlan) {
    return SUBSCRIPTION_HISTORY_EVENTS.RENEWED;
  }
  return SUBSCRIPTION_HISTORY_EVENTS.PURCHASED;
}

export class SubscriptionService {
  private readonly razorpay: RazorpayService;

  constructor(private readonly config: AppConfig) {
    this.razorpay = new RazorpayService(config);
  }

  private getRepository(): SubscriptionRepository {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    return new SubscriptionRepository(db);
  }

  async getPlans(): Promise<PlanCatalogItem[]> {
    const repo = this.getRepository();
    const rows = await repo.getActivePlans();
    return rows.map((row) => ({
      plan: row.plan,
      name: row.name,
      price: row.price,
      durationDays: row.durationDays,
      isActive: row.isActive,
    }));
  }

  async getCurrent(businessId: string): Promise<CurrentSubscriptionResponse> {
    const repo = this.getRepository();
    const business = await repo.getBusinessById(businessId);
    if (!business) {
      throw new AppError('BUSINESS_NOT_FOUND', 'Business not found', 404);
    }

    const activeSubscription = await repo.getActiveSubscription(businessId);
    const plan = business.currentPlan;
    const status = business.planStatus;
    const expiresAt = business.planExpiresAt;

    return {
      plan,
      planName: PLAN_DISPLAY_NAMES[plan] ?? plan,
      status,
      expiresAt: toIso(expiresAt),
      remainingDays: remainingDays(expiresAt),
      purchaseDate: toIso(activeSubscription?.startsAt),
      renewalDate: toIso(activeSubscription?.expiresAt),
    };
  }

  async getHistory(businessId: string): Promise<SubscriptionHistoryItem[]> {
    const repo = this.getRepository();
    const rows = await repo.getHistory(businessId);
    return rows.map((row) => ({
      id: row.id,
      oldPlan: row.oldPlan,
      newPlan: row.newPlan,
      event: row.event,
      metadata: row.metadata ?? null,
      createdAt: row.createdAt.toISOString(),
    }));
  }

  async createOrder(input: CreateOrderInput, logger?: FastifyBaseLogger) {
    if (!PURCHASABLE_PLANS.includes(input.plan)) {
      throw new AppError('INVALID_PLAN', 'Invalid plan selected', 400);
    }

    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }

    const repo = new SubscriptionRepository(db);
    const business = await repo.getBusinessById(input.businessId);
    if (!business) {
      throw new AppError('BUSINESS_NOT_FOUND', 'Business not found', 404);
    }

    const ownerName = await repo.getBusinessOwnerName(input.businessId);
    const businessEmail = business.email?.trim() ?? '';
    const businessPhone = business.phone?.trim() ?? '';
    if (!ownerName || !businessEmail || !businessPhone) {
      throw new AppError(
        'BUSINESS_PROFILE_INCOMPLETE',
        'Please complete your business profile before purchasing a subscription.',
        400,
      );
    }

    const catalogPlan = await repo.getPlanByCode(input.plan);
    if (
      !catalogPlan ||
      !catalogPlan.isActive ||
      catalogPlan.durationDays <= 0
    ) {
      throw new AppError(
        'INVALID_PLAN',
        'Plan is not available for purchase',
        400,
      );
    }

    const amountPaise = priceToPaise(catalogPlan.price);
    if (amountPaise <= 0) {
      throw new AppError('INVALID_PLAN', 'Plan price is invalid', 400);
    }

    const pendingSubscription = await repo.createSubscription({
      businessId: input.businessId,
      plan: input.plan,
      status: 'pending',
    });
    if (!pendingSubscription) {
      throw new AppError(
        'SUBSCRIPTION_CREATE_FAILED',
        'Failed to create subscription',
        500,
      );
    }

    const receipt = `bb_${pendingSubscription.id.replace(/-/g, '').slice(0, 24)}`;
    const order = await this.razorpay.createOrder({
      amountPaise,
      currency: business.currency ?? 'INR',
      receipt,
      notes: {
        business_id: input.businessId,
        subscription_id: pendingSubscription.id,
        plan: input.plan,
      },
    });

    const payment = await repo.createPayment({
      businessId: input.businessId,
      subscriptionId: pendingSubscription.id,
      plan: input.plan,
      amount: catalogPlan.price,
      currency: business.currency ?? 'INR',
      razorpayOrderId: order.id,
    });
    if (!payment) {
      throw new AppError(
        'PAYMENT_CREATE_FAILED',
        'Failed to create payment',
        500,
      );
    }

    logger?.info(
      {
        businessId: input.businessId,
        plan: input.plan,
        orderId: order.id,
        paymentId: payment.id,
      },
      'Order Created',
    );

    return {
      paymentUuid: payment.id,
      razorpayOrderId: order.id,
      razorpayKey: this.razorpay.getKeyId(),
      amount: amountPaise,
      currency: order.currency,
      businessName: business.name,
      ownerName,
      businessEmail,
      businessPhone,
    };
  }

  async verifyPayment(
    input: VerifyPaymentInput,
    logger?: FastifyBaseLogger,
  ): Promise<VerifyPaymentResponse> {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }

    const repo = new SubscriptionRepository(db);
    const payment = await repo.getPaymentById(input.paymentUuid);
    if (!payment || payment.businessId !== input.businessId) {
      throw new AppError('PAYMENT_NOT_FOUND', 'Payment not found', 404);
    }

    if (payment.razorpayOrderId !== input.razorpayOrderId) {
      throw new AppError(
        'PAYMENT_MISMATCH',
        'Order id does not match payment record',
        400,
      );
    }

    if (payment.paymentStatus === 'paid') {
      const business = await repo.getBusinessById(input.businessId);
      return {
        activated: true,
        plan: business?.currentPlan ?? payment.plan,
        expiresAt: business?.planExpiresAt?.toISOString() ?? new Date().toISOString(),
      };
    }

    if (payment.paymentStatus !== 'created') {
      throw new AppError(
        'PAYMENT_UNAVAILABLE',
        'Payment is no longer valid',
        410,
      );
    }

    if (
      !this.razorpay.verifyPaymentSignature(
        input.razorpayOrderId,
        input.razorpayPaymentId,
        input.razorpaySignature,
      )
    ) {
      logger?.warn(
        { paymentUuid: input.paymentUuid },
        'Payment verification failed: invalid signature',
      );
      throw new AppError('INVALID_SIGNATURE', 'Invalid payment signature', 401);
    }

    const paidAt = new Date();
    const activation = await db.transaction(async (tx) => {
      const txRepo = new SubscriptionRepository(tx as unknown as DbExecutor);
      return this.activatePaidPayment({
        repo: txRepo,
        payment,
        razorpayOrderId: input.razorpayOrderId,
        razorpayPaymentId: input.razorpayPaymentId,
        paidAt,
        logger,
      });
    });

    logger?.info(
      {
        businessId: input.businessId,
        paymentUuid: input.paymentUuid,
        plan: activation.plan,
      },
      'Payment Verified',
    );

    return {
      activated: true,
      plan: activation.plan,
      expiresAt: activation.expiresAt.toISOString(),
    };
  }

  private async activatePaidPayment(input: {
    repo: SubscriptionRepository;
    payment: NonNullable<
      Awaited<ReturnType<SubscriptionRepository['getPaymentById']>>
    >;
    razorpayOrderId: string;
    razorpayPaymentId: string;
    paidAt: Date;
    logger?: FastifyBaseLogger;
  }): Promise<{ plan: SubscriptionPlanCode; expiresAt: Date }> {
    const { repo, payment, razorpayOrderId, razorpayPaymentId, paidAt, logger } =
      input;

    await repo.markPaymentPaid({
      paymentId: payment.id,
      razorpayPaymentId,
      paidAt,
    });

    if (!payment.subscriptionId) {
      throw new AppError(
        'SUBSCRIPTION_NOT_FOUND',
        'Subscription not linked to payment',
        500,
      );
    }

    const subscription = await repo.getSubscriptionById(payment.subscriptionId);
    if (!subscription) {
      throw new AppError(
        'SUBSCRIPTION_NOT_FOUND',
        'Subscription not found',
        404,
      );
    }

    const catalogPlan = await repo.getPlanByCode(subscription.plan);
    if (!catalogPlan) {
      throw new AppError('INVALID_PLAN', 'Plan catalog entry missing', 500);
    }

    const business = await repo.getBusinessById(payment.businessId);
    if (!business) {
      throw new AppError('BUSINESS_NOT_FOUND', 'Business not found', 404);
    }

    const oldPlan = business.currentPlan;
    const newPlan = subscription.plan;
    const startsAt = paidAt;
    const expiresAt = new Date(startsAt);
    expiresAt.setDate(expiresAt.getDate() + catalogPlan.durationDays);

    await repo.expireActiveSubscriptionsForBusiness(
      payment.businessId,
      subscription.id,
    );

    await repo.activateSubscription({
      subscriptionId: subscription.id,
      startsAt,
      expiresAt,
    });

    await repo.updateBusinessPlan({
      businessId: payment.businessId,
      currentPlan: newPlan,
      planStatus: 'active',
      planExpiresAt: expiresAt,
    });

    const eventName = resolvePurchaseEvent(oldPlan, newPlan);
    await repo.insertHistory({
      businessId: payment.businessId,
      oldPlan,
      newPlan,
      event: eventName,
      metadata: {
        orderId: razorpayOrderId,
        paymentId: razorpayPaymentId,
        subscriptionId: subscription.id,
      },
    });

    logger?.info(
      {
        businessId: payment.businessId,
        oldPlan,
        newPlan,
        event: eventName,
      },
      'Plan Activated',
    );

    return { plan: newPlan, expiresAt };
  }

  async handleWebhook(
    rawBody: string | Buffer,
    signature: string | undefined,
    payload: WebhookPayload,
    logger?: FastifyBaseLogger,
  ): Promise<{ handled: boolean }> {
    if (!signature) {
      logger?.warn('Verification Failure: missing webhook signature');
      throw new AppError('INVALID_SIGNATURE', 'Missing webhook signature', 401);
    }

    if (!this.razorpay.verifyWebhookSignature(rawBody, signature)) {
      logger?.warn('Verification Failure: invalid webhook signature');
      throw new AppError('INVALID_SIGNATURE', 'Invalid webhook signature', 401);
    }

    logger?.info({ event: payload.event }, 'Webhook Verified');

    const event = payload.event;
    if (
      event !== RAZORPAY_WEBHOOK_EVENTS.PAYMENT_CAPTURED &&
      event !== RAZORPAY_WEBHOOK_EVENTS.ORDER_PAID
    ) {
      return { handled: false };
    }

    const orderId =
      payload.payload?.payment?.entity?.order_id ??
      payload.payload?.order?.entity?.id;
    const paymentId = payload.payload?.payment?.entity?.id ?? undefined;

    if (!orderId) {
      throw new AppError(
        'WEBHOOK_INVALID',
        'Webhook payload missing order id',
        400,
      );
    }

    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }

    const existingPayment = await new SubscriptionRepository(
      db,
    ).getPaymentByRazorpayOrderId(orderId);

    if (!existingPayment) {
      throw new AppError(
        'PAYMENT_NOT_FOUND',
        'Payment not found for order',
        404,
      );
    }

    if (existingPayment.paymentStatus === 'paid') {
      logger?.info({ orderId }, 'Duplicate webhook ignored');
      return { handled: true };
    }

    logger?.info({ orderId, razorpayPaymentId: paymentId }, 'Payment Received');

    await db.transaction(async (tx) => {
      const repo = new SubscriptionRepository(tx as unknown as DbExecutor);
      await this.activatePaidPayment({
        repo,
        payment: existingPayment,
        razorpayOrderId: orderId,
        razorpayPaymentId: paymentId ?? `unknown_${orderId}`,
        paidAt: new Date(),
        logger,
      });
    });

    return { handled: true };
  }

  async expireDueSubscriptions(logger?: FastifyBaseLogger): Promise<number> {
    const db = getDb();
    if (!db) {
      return 0;
    }

    const repo = new SubscriptionRepository(db);
    const now = new Date();
    const expiredRows = await repo.findExpiredActiveSubscriptions(now);
    let count = 0;

    for (const subscription of expiredRows) {
      await db.transaction(async (tx) => {
        const txRepo = new SubscriptionRepository(tx as unknown as DbExecutor);
        const updated = await txRepo.expireSubscription(subscription.id);
        if (!updated) {
          return;
        }

        const business = await txRepo.getBusinessById(subscription.businessId);
        if (!business) {
          return;
        }

        await txRepo.updateBusinessPlan({
          businessId: subscription.businessId,
          currentPlan: 'no_plan',
          planStatus: 'active',
          planExpiresAt: null,
        });

        await txRepo.insertHistory({
          businessId: subscription.businessId,
          oldPlan: subscription.plan,
          newPlan: 'no_plan',
          event: SUBSCRIPTION_HISTORY_EVENTS.EXPIRED,
          metadata: { subscriptionId: subscription.id },
        });

        await txRepo.insertHistory({
          businessId: subscription.businessId,
          oldPlan: subscription.plan,
          newPlan: 'no_plan',
          event: SUBSCRIPTION_HISTORY_EVENTS.DOWNGRADED,
          metadata: { subscriptionId: subscription.id },
        });

        count += 1;
        logger?.info(
          {
            businessId: subscription.businessId,
            subscriptionId: subscription.id,
            plan: subscription.plan,
          },
          'Plan Expired',
        );
        logger?.info(
          { businessId: subscription.businessId },
          'Plan Downgraded',
        );
      });
    }

    return count;
  }
}
