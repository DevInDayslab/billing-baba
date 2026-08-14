import Razorpay from 'razorpay';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../errors/app-error';
import {
  verifyRazorpayPaymentSignature,
  verifyRazorpayWebhookSignature,
} from './razorpay_signature';
import type {
  RazorpayCreateOrderInput,
  RazorpayOrderResult,
  RazorpayPaymentResult,
} from './razorpay_types';

/** Low-level Razorpay REST client — consumed by subscription and payment-gateway. */
export class RazorpayClient {
  private client: Razorpay | null = null;

  constructor(private readonly config: AppConfig) {}

  private assertOrderConfigured(): void {
    if (!this.config.razorpayKeyId || !this.config.razorpayKeySecret) {
      throw new AppError(
        'RAZORPAY_NOT_CONFIGURED',
        'Razorpay is not configured on the server',
        503,
      );
    }
  }

  private getClient(): Razorpay {
    this.assertOrderConfigured();
    const keyId = this.config.razorpayKeyId;
    const keySecret = this.config.razorpayKeySecret;
    if (!keyId || !keySecret) {
      throw new AppError(
        'RAZORPAY_NOT_CONFIGURED',
        'Razorpay is not configured on the server',
        503,
      );
    }
    if (!this.client) {
      this.client = new Razorpay({ key_id: keyId, key_secret: keySecret });
    }
    return this.client;
  }

  getKeyId(): string {
    this.assertOrderConfigured();
    const keyId = this.config.razorpayKeyId;
    if (!keyId) {
      throw new AppError(
        'RAZORPAY_NOT_CONFIGURED',
        'Razorpay is not configured on the server',
        503,
      );
    }
    return keyId;
  }

  async createOrder(input: RazorpayCreateOrderInput): Promise<RazorpayOrderResult> {
    const order = await this.getClient().orders.create({
      amount: input.amountPaise,
      currency: input.currency,
      receipt: input.receipt,
      notes: input.notes,
    });
    return {
      id: order.id,
      amount: Number(order.amount),
      currency: order.currency,
    };
  }

  async fetchPayment(paymentId: string): Promise<RazorpayPaymentResult> {
    const payment = await this.getClient().payments.fetch(paymentId);
    return {
      id: payment.id,
      orderId: payment.order_id,
      amount: Number(payment.amount),
      currency: payment.currency,
      status: payment.status,
      method: payment.method ?? null,
      captured: payment.captured ?? false,
    };
  }

  async fetchOrder(orderId: string): Promise<RazorpayOrderResult> {
    const order = await this.getClient().orders.fetch(orderId);
    return {
      id: order.id,
      amount: Number(order.amount),
      currency: order.currency,
    };
  }

  verifyPaymentSignature(
    orderId: string,
    paymentId: string,
    signature: string,
  ): boolean {
    return verifyRazorpayPaymentSignature(
      this.config,
      orderId,
      paymentId,
      signature,
    );
  }

  verifyWebhookSignature(rawBody: string | Buffer, signature: string): boolean {
    return verifyRazorpayWebhookSignature(this.config, rawBody, signature);
  }
}

/** @deprecated Use RazorpayClient — kept for subscription module compatibility. */
export class RazorpayService extends RazorpayClient {}

export type { RazorpayOrderResult, RazorpayPaymentResult } from './razorpay_types';
