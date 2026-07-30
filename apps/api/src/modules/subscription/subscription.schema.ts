import { z } from 'zod';
import { PURCHASABLE_PLANS } from './subscription.constants';

export const createOrderBodySchema = z.object({
  plan: z.enum(PURCHASABLE_PLANS),
});

export const verifyPaymentBodySchema = z.object({
  paymentUuid: z.string().uuid(),
  razorpayOrderId: z.string().min(1),
  razorpayPaymentId: z.string().min(1),
  razorpaySignature: z.string().min(1),
});
