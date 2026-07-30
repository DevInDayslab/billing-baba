import { z } from 'zod';

const purchaseDocumentTypeValues = [
  'purchase_order',
  'purchase_bill',
  'purchase_return',
] as const;

const documentStatusValues = [
  'draft',
  'finalized',
  'cancelled',
  'converted',
] as const;

const taxTypeValues = ['cgst_sgst', 'igst', 'exempt', 'none'] as const;

const sortFieldValues = [
  'document_date',
  'created_at',
  'document_number',
] as const;
const sortOrderValues = ['asc', 'desc'] as const;

const moneyString = z
  .string()
  .trim()
  .regex(/^-?\d+(\.\d{1,4})?$/, 'Invalid money value');

export const listPurchaseDocumentsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  document_type: z.enum(purchaseDocumentTypeValues).optional(),
  status: z.enum(documentStatusValues).optional(),
  party_id: z.uuid().optional(),
  from: z.iso.datetime().optional(),
  to: z.iso.datetime().optional(),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  sort: z.enum(sortFieldValues).default('document_date'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListPurchaseDocumentsQuery = z.infer<
  typeof listPurchaseDocumentsQuerySchema
>;

export const createPurchaseDocumentBodySchema = z.object({
  document_type: z.enum(purchaseDocumentTypeValues),
  document_series: z.string().trim().min(1).max(20),
  party_id: z.uuid(),
  is_gst_formal: z.boolean().optional().default(false),
  party_state_code: z.string().trim().max(4).optional().nullable(),
  document_date: z.iso.datetime().optional(),
  converted_from_id: z.uuid().optional().nullable(),
  supplier_invoice_number: z.string().trim().max(100).optional().nullable(),
  due_date: z.iso.date().optional().nullable(),
  notes: z.string().trim().max(2000).optional().nullable(),
});

export type CreatePurchaseDocumentBody = z.infer<
  typeof createPurchaseDocumentBodySchema
>;

export const updatePurchaseDocumentBodySchema = z
  .object({
    party_id: z.uuid().optional(),
    is_gst_formal: z.boolean().optional(),
    party_state_code: z.string().trim().max(4).nullable().optional(),
    document_date: z.iso.datetime().optional(),
    document_series: z.string().trim().min(1).max(20).optional(),
    supplier_invoice_number: z.string().trim().max(100).nullable().optional(),
    due_date: z.iso.date().nullable().optional(),
    notes: z.string().trim().max(2000).nullable().optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdatePurchaseDocumentBody = z.infer<
  typeof updatePurchaseDocumentBodySchema
>;

export const purchaseDocumentIdParamSchema = z.object({
  id: z.uuid('Invalid purchase document ID'),
});

export const purchaseLineIdParamSchema = z.object({
  id: z.uuid('Invalid purchase document ID'),
  lineId: z.uuid('Invalid line ID'),
});

export const createPurchaseLineBodySchema = z.object({
  item_id: z.uuid(),
  quantity: moneyString.refine(
    (v) => parseFloat(v) > 0,
    'Quantity must be > 0',
  ),
  unit: z.string().trim().min(1).max(50),
  unit_price: moneyString,
  discount_amount: moneyString.optional().default('0'),
  tax_type: z.enum(taxTypeValues).optional().default('none'),
  tax_rate: moneyString.optional().default('0'),
  tax_inclusive: z.boolean().optional().default(false),
  sort_order: z.number().int().min(0).optional(),
});

export type CreatePurchaseLineBody = z.infer<
  typeof createPurchaseLineBodySchema
>;

export const updatePurchaseLineBodySchema = z
  .object({
    item_id: z.uuid().optional(),
    quantity: moneyString
      .refine((v) => parseFloat(v) > 0, 'Quantity must be > 0')
      .optional(),
    unit: z.string().trim().min(1).max(50).optional(),
    unit_price: moneyString.optional(),
    discount_amount: moneyString.optional(),
    tax_type: z.enum(taxTypeValues).optional(),
    tax_rate: moneyString.optional(),
    tax_inclusive: z.boolean().optional(),
    sort_order: z.number().int().min(0).optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdatePurchaseLineBody = z.infer<
  typeof updatePurchaseLineBodySchema
>;

export const convertPurchaseDocumentBodySchema = z.object({
  target_type: z.enum(['purchase_bill', 'purchase_return']),
});

export type ConvertPurchaseDocumentBody = z.infer<
  typeof convertPurchaseDocumentBodySchema
>;

const finalizePaymentModeValues = [
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
] as const;

const shortPaymentHandlingValues = ['official_balance', 'unrecovered'] as const;

export const finalizePurchasePaymentBodySchema = z
  .object({
    amount: moneyString,
    payment_mode: z.enum(finalizePaymentModeValues),
    short_payment_handling: z.enum(shortPaymentHandlingValues).optional(),
    shortfall_amount: moneyString.optional(),
    payment_date: z.iso.datetime().optional(),
  })
  .superRefine((body, ctx) => {
    if (body.short_payment_handling === 'unrecovered') {
      if (!body.shortfall_amount) {
        ctx.addIssue({
          code: 'custom',
          message:
            'shortfall_amount is required when short_payment_handling is unrecovered',
          path: ['shortfall_amount'],
        });
        return;
      }

      if (parseFloat(body.shortfall_amount) <= 0) {
        ctx.addIssue({
          code: 'custom',
          message: 'shortfall_amount must be greater than zero',
          path: ['shortfall_amount'],
        });
      }
    }
  });

export type FinalizePurchasePaymentBody = z.infer<
  typeof finalizePurchasePaymentBodySchema
>;

export const finalizePurchaseDocumentBodySchema = z.object({
  godown_id: z.uuid().optional(),
  payment: finalizePurchasePaymentBodySchema.optional(),
});

export type FinalizePurchaseDocumentBody = z.infer<
  typeof finalizePurchaseDocumentBodySchema
>;
