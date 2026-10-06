import crypto from 'node:crypto';
import type { FastifyBaseLogger } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import type { GatewayIntentPayload } from '../../db/schema/payments/gateway-tables';
import { AppError } from '../../shared/errors/app-error';
import {
  type GatewayWebhookPayload,
  mapRazorpayMethodToAccountingMode,
  PaymentValidationService,
  RazorpayClient,
  type RazorpayPaymentResult,
} from '../../shared/payments';
import { BusinessMembershipRepository } from '../../shared/repositories/business-membership.repository';
import { PaymentService } from '../accounting/payment.service';
import type { PaymentRecord } from '../accounting/payment.types';
import { parseMoney } from '../inventory/inventory.utils';
import {
  GATEWAY_WEBHOOK_EVENTS,
  PAID_INTENT_TYPES,
  RECEIVED_INTENT_TYPES,
} from './payment-gateway.constants';
import type { PaymentGatewayRepository } from './payment-gateway.repository';
import { PaymentGatewayRepository as RepoClass } from './payment-gateway.repository';
import type {
  CreateGatewayOrderInput,
  CreateGatewayOrderResponse,
  GatewayPaymentIntentType,
  GatewayPaymentStatusResponse,
  VerifyGatewayPaymentInput,
  VerifyGatewayPaymentResponse,
} from './payment-gateway.types';

const CHECKOUT_TIMEOUT_SECONDS = 900;
const VERIFICATION_TIMEOUT_MS = 30_000;

function moneyToPaise(amount: string): number {
  return Math.round(parseMoney(amount) * 100);
}

function resolveDirection(
  intentType: GatewayPaymentIntentType,
): 'received' | 'paid' {
  if ((PAID_INTENT_TYPES as readonly string[]).includes(intentType)) {
    return 'paid';
  }
  if ((RECEIVED_INTENT_TYPES as readonly string[]).includes(intentType)) {
    return 'received';
  }
  throw new AppError('INVALID_INTENT', 'Unsupported payment intent type', 400);
}

function buildCreateOrderResponse(input: {
  intentId: string;
  razorpayOrderId: string;
  razorpayKey: string;
  amountPaise: number;
  currency: string;
  businessName: string;
  partyName: string;
  partyEmail: string;
  partyPhone: string;
  intentType: string;
}): CreateGatewayOrderResponse {
  return {
    id: input.intentId,
    order_id: input.razorpayOrderId,
    amount: input.amountPaise,
    currency: input.currency,
    receipt: input.intentId.replace(/-/g, '').slice(0, 32),
    razorpay_key: input.razorpayKey,
    customer: {
      name: input.partyName,
      email: input.partyEmail || 'customer@billingbaba.com',
      contact: input.partyPhone || '9999999999',
    },
    merchant: {
      name: input.businessName,
    },
    theme: {
      color: '#6C3CE9',
    },
    checkout: {
      timeout: CHECKOUT_TIMEOUT_SECONDS,
      retry: { enabled: true, max_count: 3 },
      remember_customer: true,
      send_sms_hash: true,
      readonly: { email: false, contact: false },
      notes: {
        intent_id: input.intentId,
        intent_type: input.intentType,
      },
    },
  };
}

export class PaymentGatewayService {
  private readonly razorpay: RazorpayClient;
  private readonly validator = new PaymentValidationService();

  constructor(
    readonly config: AppConfig,
    razorpay?: RazorpayClient,
  ) {
    this.razorpay = razorpay ?? new RazorpayClient(config);
  }

  private getRepository(): PaymentGatewayRepository {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    return new RepoClass(db);
  }

  private async assertAccess(businessId: string, accountId: string) {
    const repo = this.getRepository();
    const hasAccess = await repo.hasBusinessMembership(businessId, accountId);
    if (!hasAccess) {
      throw new AppError(
        'FORBIDDEN',
        'You do not have access to this business',
        403,
      );
    }
  }

  async createOrder(
    input: CreateGatewayOrderInput,
    logger?: FastifyBaseLogger,
  ): Promise<CreateGatewayOrderResponse> {
    const startedAt = Date.now();
    await this.assertAccess(input.businessId, input.accountId);

    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }

    const repo = new RepoClass(db);

    if (input.idempotencyKey) {
      const existing = await repo.findByIdempotencyKey(
        input.businessId,
        input.idempotencyKey,
      );
      if (existing) {
        logger?.info(
          { intentId: existing.id, latencyMs: Date.now() - startedAt },
          'Gateway create-order idempotent hit',
        );
        return buildCreateOrderResponse({
          intentId: existing.id,
          razorpayOrderId: existing.razorpayOrderId,
          razorpayKey: this.razorpay.getKeyId(),
          amountPaise: existing.amountPaise,
          currency: existing.currency,
          businessName: existing.businessName,
          partyName: existing.customerName,
          partyEmail: existing.customerEmail ?? '',
          partyPhone: existing.customerPhone ?? '',
          intentType: existing.intentType,
        });
      }
    }

    const business = await repo.getBusinessById(input.businessId);
    if (!business) {
      throw new AppError('BUSINESS_NOT_FOUND', 'Business not found', 404);
    }

    const party = await repo.getPartyById(input.businessId, input.partyId);
    if (!party) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    const amountPaise = moneyToPaise(input.amount);
    if (amountPaise <= 0) {
      throw new AppError('VALIDATION_ERROR', 'Amount must be positive', 400);
    }

    const direction = resolveDirection(input.intentType);
    const intentPayload: GatewayIntentPayload = {
      party_id: input.partyId,
      direction,
      amount: input.amount,
      discount_amount: input.discountAmount,
      notes: input.notes ?? null,
      short_payment_handling: input.shortPaymentHandling ?? null,
      shortfall_amount: input.shortfallAmount ?? null,
      allocations: input.allocations ?? [],
      reference_number: input.referenceNumber ?? null,
      invoice_number: input.invoiceNumber ?? null,
    };

    const intentId = crypto.randomUUID();
    const receipt = `gw_${intentId.replace(/-/g, '').slice(0, 24)}`;
    const order = await this.razorpay.createOrder({
      amountPaise,
      currency: business.currency ?? 'INR',
      receipt,
      notes: {
        business_id: input.businessId,
        intent_id: intentId,
        intent_type: input.intentType,
      },
    });

    const intent = await repo.createIntent({
      id: intentId,
      businessId: input.businessId,
      intentType: input.intentType,
      intentPayload,
      businessName: business.name,
      customerName: party.name,
      customerPhone: party.mobile,
      customerEmail: party.email,
      amountPaise,
      currency: business.currency ?? 'INR',
      razorpayOrderId: order.id,
      idempotencyKey: input.idempotencyKey,
    });

    if (!intent) {
      throw new AppError(
        'PAYMENT_CREATE_FAILED',
        'Failed to create payment intent',
        500,
      );
    }

    logger?.info(
      {
        businessId: input.businessId,
        intentId: intent.id,
        intentType: input.intentType,
        orderId: order.id,
        businessName: business.name,
        customerName: party.name,
        latencyMs: Date.now() - startedAt,
      },
      'Gateway order created',
    );

    return buildCreateOrderResponse({
      intentId: intent.id,
      razorpayOrderId: order.id,
      razorpayKey: this.razorpay.getKeyId(),
      amountPaise,
      currency: order.currency,
      businessName: business.name,
      partyName: party.name,
      partyEmail: party.email?.trim() ?? '',
      partyPhone: party.mobile?.trim() ?? '',
      intentType: input.intentType,
    });
  }

  async markCheckoutOpen(intentId: string, businessId: string) {
    const repo = this.getRepository();
    await repo.updateIntentStatus({
      intentId,
      status: 'checkout_open',
    });
    void businessId;
  }

  async verifyPayment(
    input: VerifyGatewayPaymentInput,
    logger?: FastifyBaseLogger,
  ): Promise<VerifyGatewayPaymentResponse> {
    const startedAt = Date.now();
    await this.assertAccess(input.businessId, input.accountId);

    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }

    const repo = new RepoClass(db);
    const intent = await repo.findById(input.businessId, input.intentId);
    if (!intent) {
      throw new AppError('PAYMENT_NOT_FOUND', 'Payment intent not found', 404);
    }

    if (intent.razorpayOrderId !== input.razorpayOrderId) {
      throw new AppError(
        'PAYMENT_MISMATCH',
        'Order id does not match payment intent',
        400,
      );
    }

    if (intent.status === 'verified' && intent.accountingPaymentId) {
      const paymentService = new PaymentService();
      const payment = await paymentService.getPayment(
        input.businessId,
        input.accountId,
        intent.accountingPaymentId,
      );
      return { status: 'verified', payment };
    }

    if (intent.status === 'failed' || intent.status === 'cancelled') {
      return {
        status: 'failed',
        failure_reason: intent.failureReason ?? 'Payment failed',
      };
    }

    if (intent.status === 'expired') {
      return { status: 'failed', failure_reason: 'Payment order expired' };
    }

    logger?.info({ intentId: input.intentId }, 'Verification started');

    if (
      !this.razorpay.verifyPaymentSignature(
        input.razorpayOrderId,
        input.razorpayPaymentId,
        input.razorpaySignature,
      )
    ) {
      logger?.warn(
        { intentId: input.intentId },
        'Verification failed: invalid signature',
      );
      await repo.updateIntentStatus({
        intentId: intent.id,
        status: 'failed',
        failureReason: 'Invalid payment signature',
      });
      throw new AppError('INVALID_SIGNATURE', 'Invalid payment signature', 401);
    }

    await repo.updateIntentStatus({
      intentId: intent.id,
      status: 'callback_received',
      razorpayPaymentId: input.razorpayPaymentId,
    });

    await repo.updateIntentStatus({
      intentId: intent.id,
      status: 'verifying',
      razorpayPaymentId: input.razorpayPaymentId,
    });

    let razorpayPayment: RazorpayPaymentResult;
    try {
      razorpayPayment = await Promise.race([
        this.razorpay.fetchPayment(input.razorpayPaymentId),
        new Promise<never>((_, reject) =>
          setTimeout(
            () => reject(new Error('Verification timeout')),
            VERIFICATION_TIMEOUT_MS,
          ),
        ),
      ]);
    } catch {
      logger?.warn(
        { intentId: input.intentId },
        'Verification pending: fetch timeout',
      );
      return { status: 'pending' };
    }

    const validation = this.validator.validate({
      intent: {
        razorpayOrderId: intent.razorpayOrderId,
        amountPaise: intent.amountPaise,
        currency: intent.currency,
      },
      razorpayPayment,
      merchantKeyId: this.razorpay.getKeyId(),
      config: this.config,
    });

    if (!validation.valid) {
      await repo.updateIntentStatus({
        intentId: intent.id,
        status: 'failed',
        razorpayPaymentId: input.razorpayPaymentId,
        failureReason: validation.reason,
      });
      logger?.warn(
        { intentId: input.intentId, reason: validation.reason },
        'Verification failed: validation',
      );
      return { status: 'failed', failure_reason: validation.reason };
    }

    const paidAt = new Date();
    const payment = await this.finalizeVerifiedIntent({
      repo,
      intent,
      razorpayPaymentId: input.razorpayPaymentId,
      razorpayMethod: razorpayPayment.method,
      businessId: input.businessId,
      accountId: input.accountId,
      userId: input.userId,
      paidAt,
      logger,
    });

    logger?.info(
      {
        intentId: input.intentId,
        latencyMs: Date.now() - startedAt,
      },
      'Verification finished',
    );

    return { status: 'verified', payment };
  }

  async getStatus(
    businessId: string,
    accountId: string,
    intentId: string,
  ): Promise<GatewayPaymentStatusResponse> {
    await this.assertAccess(businessId, accountId);

    const repo = this.getRepository();
    const intent = await repo.findById(businessId, intentId);
    if (!intent) {
      throw new AppError('PAYMENT_NOT_FOUND', 'Payment intent not found', 404);
    }

    let payment: PaymentRecord | undefined;
    if (intent.accountingPaymentId) {
      const paymentService = new PaymentService();
      payment = await paymentService.getPayment(
        businessId,
        accountId,
        intent.accountingPaymentId,
      );
    }

    return {
      id: intent.id,
      status: intent.status,
      order_id: intent.razorpayOrderId,
      amount: intent.amountPaise,
      currency: intent.currency,
      business_name: intent.businessName,
      customer_name: intent.customerName,
      payment,
      failure_reason: intent.failureReason,
    };
  }

  /** Validates webhook signature, enqueues reconciliation job, returns immediately. */
  async handleWebhook(
    rawBody: string | Buffer,
    signature: string | undefined,
    payload: GatewayWebhookPayload,
    logger?: FastifyBaseLogger,
  ): Promise<{ handled: boolean; enqueued: boolean }> {
    if (!signature) {
      throw new AppError('INVALID_SIGNATURE', 'Missing webhook signature', 401);
    }

    if (!this.razorpay.verifyWebhookSignature(rawBody, signature)) {
      throw new AppError('INVALID_SIGNATURE', 'Invalid webhook signature', 401);
    }

    const event = payload.event ?? 'unknown';
    logger?.info({ event }, 'Webhook verified');

    const orderId =
      payload.payload?.payment?.entity?.order_id ??
      payload.payload?.order?.entity?.id;
    const paymentId = payload.payload?.payment?.entity?.id;

    if (!orderId) {
      return { handled: false, enqueued: false };
    }

    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }

    const repo = new RepoClass(db);
    const intent = await repo.findByRazorpayOrderId(orderId);
    if (!intent) {
      return { handled: false, enqueued: false };
    }

    if (intent.status === 'verified') {
      logger?.info({ orderId }, 'Duplicate gateway webhook ignored');
      return { handled: true, enqueued: false };
    }

    if (event === GATEWAY_WEBHOOK_EVENTS.PAYMENT_FAILED) {
      await repo.updateIntentStatus({
        intentId: intent.id,
        status: 'failed',
        razorpayPaymentId: paymentId,
        failureReason: 'Payment failed at gateway',
      });
      return { handled: true, enqueued: false };
    }

    await repo.enqueueReconciliationJob({
      intentId: intent.id,
      event,
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      payload: payload as unknown as Record<string, unknown>,
    });

    logger?.info({ orderId, event }, 'Webhook reconciliation enqueued');
    return { handled: true, enqueued: true };
  }

  /** Processes a single reconciliation job (called by background worker). */
  async processReconciliationJob(
    jobId: string,
    logger?: FastifyBaseLogger,
  ): Promise<void> {
    const db = getDb();
    if (!db) return;

    const repo = new RepoClass(db);
    const membershipRepo = new BusinessMembershipRepository(db);

    const jobs = await repo.claimPendingReconciliationJobs(1);
    const job = jobs.find((j) => j.id === jobId) ?? jobs[0];
    if (!job) return;

    try {
      const intent = await repo.findByIdGlobal(job.intentId);
      if (!intent) {
        await repo.completeReconciliationJob(job.id);
        return;
      }

      if (intent.status === 'verified') {
        await repo.completeReconciliationJob(job.id);
        return;
      }

      if (!job.razorpayPaymentId) {
        await repo.failReconciliationJob(job.id, 'Missing payment id');
        return;
      }

      const razorpayPayment = await this.razorpay.fetchPayment(
        job.razorpayPaymentId,
      );
      const validation = this.validator.validate({
        intent: {
          razorpayOrderId: intent.razorpayOrderId,
          amountPaise: intent.amountPaise,
          currency: intent.currency,
        },
        razorpayPayment,
        merchantKeyId: this.razorpay.getKeyId(),
        config: this.config,
      });

      if (!validation.valid) {
        await repo.failReconciliationJob(job.id, validation.reason);
        return;
      }

      const accountId = await membershipRepo.findAnyAccountId(
        intent.businessId,
      );
      if (!accountId) {
        await repo.failReconciliationJob(job.id, 'No business account');
        return;
      }

      await repo.updateIntentStatus({
        intentId: intent.id,
        status: 'verifying',
        razorpayPaymentId: job.razorpayPaymentId,
      });

      await this.finalizeVerifiedIntent({
        repo,
        intent,
        razorpayPaymentId: job.razorpayPaymentId,
        razorpayMethod: razorpayPayment.method,
        businessId: intent.businessId,
        accountId,
        paidAt: new Date(),
        logger,
      });

      await repo.completeReconciliationJob(job.id);
      logger?.info(
        { intentId: intent.id, jobId: job.id },
        'Webhook reconciliation succeeded',
      );
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Reconciliation failed';
      await repo.failReconciliationJob(job.id, message);
      logger?.warn(
        { jobId: job.id, err: message },
        'Webhook reconciliation failed',
      );
    }
  }

  async processPendingReconciliationJobs(
    logger?: FastifyBaseLogger,
  ): Promise<number> {
    const db = getDb();
    if (!db) return 0;

    const repo = new RepoClass(db);
    const jobs = await repo.claimPendingReconciliationJobs(10);
    let processed = 0;

    for (const job of jobs) {
      await this.processReconciliationJob(job.id, logger);
      processed += 1;
    }

    return processed;
  }

  private async finalizeVerifiedIntent(input: {
    repo: PaymentGatewayRepository;
    intent: NonNullable<
      Awaited<ReturnType<PaymentGatewayRepository['findById']>>
    >;
    razorpayPaymentId: string;
    razorpayMethod: string | null;
    businessId: string;
    accountId: string;
    userId?: string;
    paidAt: Date;
    logger?: FastifyBaseLogger;
  }) {
    const {
      repo,
      intent,
      razorpayPaymentId,
      razorpayMethod,
      businessId,
      accountId,
      userId,
      paidAt,
      logger,
    } = input;

    if (intent.status === 'verified' && intent.accountingPaymentId) {
      const paymentService = new PaymentService();
      return paymentService.getPayment(
        businessId,
        accountId,
        intent.accountingPaymentId,
      );
    }

    const payload = intent.intentPayload;
    const paymentService = new PaymentService();
    const payment = await paymentService.createPayment(
      businessId,
      accountId,
      userId,
      {
        party_id: payload.party_id,
        direction: payload.direction,
        amount: payload.amount,
        discount_amount: payload.discount_amount,
        payment_mode: mapRazorpayMethodToAccountingMode(razorpayMethod),
        reference_number: payload.reference_number ?? razorpayPaymentId,
        notes: payload.notes,
        short_payment_handling: payload.short_payment_handling ?? undefined,
        shortfall_amount: payload.shortfall_amount ?? undefined,
        allocations: payload.allocations ?? [],
        source: 'razorpay_gateway',
      },
    );

    await repo.updateIntentStatus({
      intentId: intent.id,
      status: 'verified',
      razorpayPaymentId,
      accountingPaymentId: payment.id,
      paidAt,
      verifiedAt: paidAt,
    });

    logger?.info(
      {
        businessId,
        intentId: intent.id,
        accountingPaymentId: payment.id,
        razorpayPaymentId: razorpayPaymentId.slice(0, 8),
        businessName: intent.businessName,
        customerName: intent.customerName,
      },
      'Gateway payment verified',
    );

    return payment;
  }
}
