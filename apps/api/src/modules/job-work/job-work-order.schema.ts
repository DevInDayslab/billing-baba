import { z } from 'zod';

const moneyString = z
  .string()
  .trim()
  .regex(/^\d+(\.\d{1,4})?$/, 'Invalid money value');

const rawMaterialSchema = z.object({
  item_id: z.uuid(),
  quantity: moneyString,
  unit: z.string().trim().min(1).max(50),
  purchase_price: moneyString.optional().default('0'),
});

const additionalCostSchema = z.object({
  label: z.string().trim().min(1).max(200),
  amount: moneyString,
});

export const listJobWorkOrdersQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  status: z.enum(['open', 'closed', 'cancelled'] as const).optional(),
  party_id: z.uuid().optional(),
  sort: z.enum(['order_date', 'created_at'] as const).default('order_date'),
  order: z.enum(['asc', 'desc'] as const).default('desc'),
});

export type ListJobWorkOrdersQuery = z.infer<
  typeof listJobWorkOrdersQuerySchema
>;

export const createJobWorkOrderBodySchema = z.object({
  party_id: z.uuid().optional().nullable(),
  job_number: z.string().trim().max(100).optional().nullable(),
  order_date: z.iso.datetime().optional(),
  delivery_date: z.iso.datetime().optional().nullable(),
  finished_good_name: z.string().trim().min(1).max(200),
  finished_good_quantity: moneyString.optional().default('1'),
  finished_good_unit: z.string().trim().min(1).max(50).optional().default('PCS'),
  notes: z.string().trim().max(2000).optional().nullable(),
  raw_materials: z.array(rawMaterialSchema).optional().default([]),
  additional_costs: z.array(additionalCostSchema).optional().default([]),
});

export type CreateJobWorkOrderBody = z.infer<
  typeof createJobWorkOrderBodySchema
>;

export const updateJobWorkOrderBodySchema = z
  .object({
    party_id: z.uuid().nullable().optional(),
    job_number: z.string().trim().max(100).nullable().optional(),
    delivery_date: z.iso.datetime().nullable().optional(),
    finished_good_name: z.string().trim().min(1).max(200).optional(),
    finished_good_quantity: moneyString.optional(),
    finished_good_unit: z.string().trim().min(1).max(50).optional(),
    status: z.enum(['open', 'closed', 'cancelled'] as const).optional(),
    notes: z.string().trim().max(2000).nullable().optional(),
    raw_materials: z.array(rawMaterialSchema).optional(),
    additional_costs: z.array(additionalCostSchema).optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateJobWorkOrderBody = z.infer<
  typeof updateJobWorkOrderBodySchema
>;

export const jobWorkOrderIdParamSchema = z.object({
  id: z.uuid('Invalid job work order ID'),
});
