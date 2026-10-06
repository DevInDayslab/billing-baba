import { z } from 'zod';
import { parseMoney } from '../inventory/inventory.utils';

const intentTypeValues = [
  'payment_in',
  'payment_out',
  'sale_invoice',
  'purchase_bill',
  'pos',
  'party_outstanding',
  'advance',
] as const;

const moneyString = z
  .string()
  .trim()
  .regex(/^\d+(\.\d{1,4})?$/, 'Invalid money value');

const allocationSchema = z.object({
  sales_document_id: z.uuid().optional(),
  purchase_document_id: z.uuid().optional(),
  allocated_amount: moneyString,
});

export const createGatewayOrderBodySchema = z
  .object({
    intent_type: z.enum(intentTypeValues),
    party_id: z.uuid(),
    amount: moneyString,
    discount_amount: moneyString.optional(),
    notes: z.string().trim().max(2000).optional().nullable(),
    short_payment_handling: z
      .enum(['official_balance', 'unrecovered'] as const)
      .optional(),
    shortfall_amount: moneyString.optional(),
    allocations: z.array(allocationSchema).optional().default([]),
    reference_number: z.string().trim().max(100).optional().nullable(),
    invoice_number: z.string().trim().max(100).optional().nullable(),
  })
  .superRefine((body, ctx) => {
    if (parseMoney(body.amount) <= 0) {
      ctx.addIssue({
        code: 'custom',
        message: 'amount must be greater than zero',
        path: ['amount'],
      });
    }
  });

export type CreateGatewayOrderBody = z.infer<
  typeof createGatewayOrderBodySchema
>;

export const verifyGatewayPaymentBodySchema = z.object({
  intent_id: z.uuid(),
  payment_id: z.string().min(1),
  order_id: z.string().min(1),
  signature: z.string().min(1),
});

export type VerifyGatewayPaymentBody = z.infer<
  typeof verifyGatewayPaymentBodySchema
>;

export const gatewayIntentIdParamSchema = z.object({
  id: z.uuid('Invalid intent ID'),
});
