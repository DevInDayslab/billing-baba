import { z } from 'zod';

const sortFieldValues = ['sale_date', 'created_at', 'total_amount'] as const;
const sortOrderValues = ['asc', 'desc'] as const;
const paymentModeValues = [
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
] as const;
const statusValues = [
  'paid',
  'unpaid',
  'partially_paid',
  'overdue',
  'cancelled',
] as const;

export const saleFaAssetBodySchema = z.object({
  id: z.uuid().optional(),
  asset_name: z.string().trim().min(1, 'Asset name is required').max(500),
  item_code: z.string().trim().max(200).optional().nullable(),
  asset_category: z.string().trim().max(200).optional().nullable(),
  serial_number: z.string().trim().max(200).optional().nullable(),
  sale_price: z.string().regex(/^\d+(\.\d{1,4})?$/),
  location: z.string().trim().max(500).optional().nullable(),
  description: z.string().trim().max(2000).optional().nullable(),
  qty: z
    .string()
    .regex(/^\d+(\.\d{1,4})?$/)
    .optional(),
  tax_rate: z
    .string()
    .regex(/^\d+(\.\d{1,4})?$/)
    .optional(),
  tax_amount: z
    .string()
    .regex(/^\d+(\.\d{1,4})?$/)
    .optional(),
  line_total: z.string().regex(/^\d+(\.\d{1,4})?$/),
  sort_order: z.number().int().min(0).optional(),
  purchase_fixed_asset_id: z.uuid().optional().nullable(),
});

export const createSaleFaBodySchema = z.object({
  party_id: z.uuid('Invalid party ID'),
  reference_number: z.string().trim().max(100).optional().nullable(),
  sale_date: z.string().date(),
  due_date: z.string().date().optional().nullable(),
  payment_mode: z.enum(paymentModeValues).optional().nullable(),
  status: z.enum(statusValues).optional(),
  notes: z.string().trim().max(2000).optional().nullable(),
  description: z.string().trim().max(2000).optional().nullable(),
  subtotal: z
    .string()
    .regex(/^\d+(\.\d{1,4})?$/)
    .optional(),
  tax_amount: z
    .string()
    .regex(/^\d+(\.\d{1,4})?$/)
    .optional(),
  total_amount: z.string().regex(/^\d+(\.\d{1,4})?$/),
  balance_due: z
    .string()
    .regex(/^\d+(\.\d{1,4})?$/)
    .optional(),
  assets: z.array(saleFaAssetBodySchema).min(1, 'At least one asset required'),
});

export type CreateSaleFaBody = z.infer<typeof createSaleFaBodySchema>;

export const updateSaleFaBodySchema = createSaleFaBodySchema
  .partial()
  .extend({
    assets: z.array(saleFaAssetBodySchema).min(1).optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateSaleFaBody = z.infer<typeof updateSaleFaBodySchema>;

export const listSaleFaQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  party_id: z.uuid().optional(),
  status: z.enum(statusValues).optional(),
  from: z.string().date().optional(),
  to: z.string().date().optional(),
  sort: z.enum(sortFieldValues).default('sale_date'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListSaleFaQuery = z.infer<typeof listSaleFaQuerySchema>;

export const saleFaBatchIdParamSchema = z.object({
  batchId: z.uuid('Invalid batch ID'),
});
