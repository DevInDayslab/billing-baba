import crypto from 'node:crypto';
import Razorpay from 'razorpay';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';

export type RazorpayOrderResult = {
  id: string;
  amount: number;
  currency: string;
};

export class RazorpayService {
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

  private assertWebhookConfigured(): void {
    if (!this.config.razorpayWebhookSecret) {
      throw new AppError(
        'RAZORPAY_NOT_CONFIGURED',
        'Razorpay webhook secret is not configured on the server',
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
      this.client = new Razorpay({
        key_id: keyId,
        key_secret: keySecret,
      });
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

  async createOrder(input: {
    amountPaise: number;
    currency: string;
    receipt: string;
    notes?: Record<string, string>;
  }): Promise<RazorpayOrderResult> {
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

  verifyPaymentSignature(
    orderId: string,
    paymentId: string,
    signature: string,
  ): boolean {
    this.assertOrderConfigured();
    const keySecret = this.config.razorpayKeySecret;
    if (!keySecret) {
      throw new AppError(
        'RAZORPAY_NOT_CONFIGURED',
        'Razorpay is not configured on the server',
        503,
      );
    }
    const body = `${orderId}|${paymentId}`;
    const expected = crypto
      .createHmac('sha256', keySecret)
      .update(body)
      .digest('hex');
    return expected === signature;
  }

  verifyWebhookSignature(rawBody: string | Buffer, signature: string): boolean {
    this.assertWebhookConfigured();
    const webhookSecret = this.config.razorpayWebhookSecret;
    if (!webhookSecret) {
      throw new AppError(
        'RAZORPAY_NOT_CONFIGURED',
        'Razorpay is not configured on the server',
        503,
      );
    }
    const body =
      typeof rawBody === 'string' ? rawBody : rawBody.toString('utf8');
    const expected = crypto
      .createHmac('sha256', webhookSecret)
      .update(body)
      .digest('hex');
    return expected === signature;
  }
}
