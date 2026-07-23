import { z } from 'zod';

const salesDocumentTypeValues = [
  'estimate',
  'sale_order',
  'delivery_challan',
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
  'sales_return',
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

export const listSalesDocumentsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  document_type: z.enum(salesDocumentTypeValues).optional(),
  document_series: z.string().trim().min(1).max(20).optional(),
  status: z.enum(documentStatusValues).optional(),
  party_id: z.uuid().optional(),
  pos_session_id: z.uuid().optional(),
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

export type ListSalesDocumentsQuery = z.infer<
  typeof listSalesDocumentsQuerySchema
>;

export const createSalesDocumentBodySchema = z.object({
  document_type: z.enum(salesDocumentTypeValues),
  document_series: z.string().trim().min(1).max(20),
  party_id: z.uuid().optional().nullable(),
  is_gst_formal: z.boolean().optional().default(false),
  party_state_code: z.string().trim().max(4).optional().nullable(),
  document_date: z.iso.datetime().optional(),
  converted_from_id: z.uuid().optional().nullable(),
  pos_session_id: z.uuid().optional().nullable(),
  notes: z.string().trim().max(2000).optional().nullable(),
});

export type CreateSalesDocumentBody = z.infer<
  typeof createSalesDocumentBodySchema
>;

export const updateSalesDocumentBodySchema = z
  .object({
    party_id: z.uuid().nullable().optional(),
    is_gst_formal: z.boolean().optional(),
    party_state_code: z.string().trim().max(4).nullable().optional(),
    document_date: z.iso.datetime().optional(),
    document_series: z.string().trim().min(1).max(20).optional(),
    notes: z.string().trim().max(2000).nullable().optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateSalesDocumentBody = z.infer<
  typeof updateSalesDocumentBodySchema
>;

export const salesDocumentIdParamSchema = z.object({
  id: z.uuid('Invalid sales document ID'),
});

export const salesLineIdParamSchema = z.object({
  id: z.uuid('Invalid sales document ID'),
  lineId: z.uuid('Invalid line ID'),
});

export const createSalesLineBodySchema = z.object({
  item_id: z.uuid(),
  quantity: moneyString.refine(
    (v) => parseFloat(v) > 0,
    'Quantity must be > 0',
  ),
  unit: z.string().trim().min(1).max(50),
  unit_price: moneyString,
  market_price: moneyString.optional().nullable(),
  discount_amount: moneyString.optional().default('0'),
  tax_type: z.enum(taxTypeValues).optional().default('none'),
  tax_rate: moneyString.optional().default('0'),
  sort_order: z.number().int().min(0).optional(),
});

export type CreateSalesLineBody = z.infer<typeof createSalesLineBodySchema>;

export const updateSalesLineBodySchema = z
  .object({
    item_id: z.uuid().optional(),
    quantity: moneyString
      .refine((v) => parseFloat(v) > 0, 'Quantity must be > 0')
      .optional(),
    unit: z.string().trim().min(1).max(50).optional(),
    unit_price: moneyString.optional(),
    market_price: moneyString.nullable().optional(),
    discount_amount: moneyString.optional(),
    tax_type: z.enum(taxTypeValues).optional(),
    tax_rate: moneyString.optional(),
    sort_order: z.number().int().min(0).optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateSalesLineBody = z.infer<typeof updateSalesLineBodySchema>;

export const convertSalesDocumentBodySchema = z.object({
  target_type: z.enum([
    'sale_order',
    'delivery_challan',
    'tax_invoice',
    'bill_of_supply',
    'normal_invoice',
  ]),
  apply_gst: z.boolean().optional().default(false),
});

export type ConvertSalesDocumentBody = z.infer<
  typeof convertSalesDocumentBodySchema
>;

export const brandSwapBodySchema = z.object({
  brand_id: z.uuid(),
});

export type BrandSwapBody = z.infer<typeof brandSwapBodySchema>;

export const cloneWithAlternativesBodySchema = z.object({
  replacements: z
    .array(
      z.object({
        original_item_id: z.uuid(),
        replacement_item_id: z.uuid(),
      }),
    )
    .optional()
    .default([]),
});

export type CloneWithAlternativesBody = z.infer<
  typeof cloneWithAlternativesBodySchema
>;

export const finalizeSalesDocumentBodySchema = z.object({
  godown_id: z.uuid().optional(),
  loyalty_points_redeemed: z
    .string()
    .trim()
    .regex(/^\d+(\.\d{1,4})?$/, 'Invalid loyalty points value')
    .optional()
    .refine(
      (value) => value === undefined || parseFloat(value) >= 0,
      'Loyalty points must be >= 0',
    ),
});

export type FinalizeSalesDocumentBody = z.infer<
  typeof finalizeSalesDocumentBodySchema
>;

export const listPosSessionsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sort: z.enum(['started_at', 'created_at'] as const).default('started_at'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListPosSessionsQuery = z.infer<typeof listPosSessionsQuerySchema>;

export const createPosSessionBodySchema = z.object({
  opening_cash: moneyString.optional().nullable(),
});

export type CreatePosSessionBody = z.infer<typeof createPosSessionBodySchema>;

export const updatePosSessionBodySchema = z.object({
  ended_at: z.iso.datetime().optional(),
  closing_cash: moneyString.optional().nullable(),
});

export type UpdatePosSessionBody = z.infer<typeof updatePosSessionBodySchema>;

export const posSessionIdParamSchema = z.object({
  id: z.uuid('Invalid POS session ID'),
});

export const documentSequenceIdParamSchema = z.object({
  id: z.uuid('Invalid document sequence ID'),
});

export const updateDocumentSequenceBodySchema = z
  .object({
    prefix: z.string().trim().max(20).nullable().optional(),
    next_number: z.number().int().min(1).optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateDocumentSequenceBody = z.infer<
  typeof updateDocumentSequenceBodySchema
>;
