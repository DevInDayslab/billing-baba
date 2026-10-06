import crypto from 'node:crypto';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../errors/app-error';

export function verifyRazorpayPaymentSignature(
  config: AppConfig,
  orderId: string,
  paymentId: string,
  signature: string,
): boolean {
  const keySecret = config.razorpayKeySecret;
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

export function verifyRazorpayWebhookSignature(
  config: AppConfig,
  rawBody: string | Buffer,
  signature: string,
): boolean {
  const webhookSecret = config.razorpayWebhookSecret;
  if (!webhookSecret) {
    throw new AppError(
      'RAZORPAY_NOT_CONFIGURED',
      'Razorpay webhook secret is not configured on the server',
      503,
    );
  }
  const body = typeof rawBody === 'string' ? rawBody : rawBody.toString('utf8');
  const expected = crypto
    .createHmac('sha256', webhookSecret)
    .update(body)
    .digest('hex');
  return expected === signature;
}
