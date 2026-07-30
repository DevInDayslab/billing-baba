import { z } from 'zod';

const sortOrderValues = ['asc', 'desc'] as const;
const movementTypeValues = [
  'opening',
  'purchase',
  'sale',
  'sales_return',
  'purchase_return',
  'challan',
  'adjustment',
] as const;
const postMovementTypeValues = ['opening', 'adjustment'] as const;

const moneyField = z
  .union([z.string(), z.number()])
  .transform((value) => String(value).trim())
  .pipe(
    z.string().regex(/^-?\d+(\.\d{1,4})?$/, 'Must be a valid decimal amount'),
  );

const optionalMoneyField = z
  .union([z.string(), z.number()])
  .optional()
  .transform((value) =>
    value === undefined || value === '' ? undefined : String(value).trim(),
  )
  .pipe(
    z
      .string()
      .regex(/^\d+(\.\d{1,4})?$/, 'Must be a valid positive decimal amount')
      .optional(),
  );

export const listMovementsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  item_id: z.uuid('Invalid item ID').optional(),
  godown_id: z.uuid('Invalid godown ID').optional(),
  movement_type: z.enum(movementTypeValues).optional(),
  sort: z.literal('created_at').default('created_at'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListMovementsQuery = z.infer<typeof listMovementsQuerySchema>;

export const createMovementBodySchema = z
  .object({
    item_id: z.uuid('Invalid item ID'),
    godown_id: z.uuid('Invalid godown ID'),
    movement_type: z.enum(postMovementTypeValues),
    quantity_delta: moneyField.refine((value) => Number(value) !== 0, {
      message: 'Quantity delta must not be zero',
    }),
    cost_per_unit: optionalMoneyField,
    reference_id: z.uuid('Invalid reference ID').optional(),
    reference_type: z
      .string()
      .trim()
      .optional()
      .transform((value) => (value === '' ? undefined : value)),
    notes: z
      .string()
      .trim()
      .max(500, 'Notes must be at most 500 characters')
      .optional()
      .transform((value) => (value === '' ? undefined : value)),
  })
  .superRefine((body, ctx) => {
    const delta = Number(body.quantity_delta);
    if (body.movement_type === 'opening' && delta <= 0) {
      ctx.addIssue({
        code: 'custom',
        message: 'Opening movement quantity must be positive',
        path: ['quantity_delta'],
      });
    }
    if (
      body.movement_type === 'opening' &&
      (body.cost_per_unit === undefined || Number(body.cost_per_unit) < 0)
    ) {
      ctx.addIssue({
        code: 'custom',
        message: 'Opening movement requires a valid cost per unit',
        path: ['cost_per_unit'],
      });
    }
    if (body.movement_type === 'adjustment' && delta === 0) {
      ctx.addIssue({
        code: 'custom',
        message: 'Adjustment quantity must not be zero',
        path: ['quantity_delta'],
      });
    }
    if (
      delta > 0 &&
      body.movement_type === 'adjustment' &&
      body.cost_per_unit === undefined
    ) {
      ctx.addIssue({
        code: 'custom',
        message: 'Positive adjustment requires cost per unit',
        path: ['cost_per_unit'],
      });
    }
  });

export type CreateMovementBody = z.infer<typeof createMovementBodySchema>;

export const movementIdParamSchema = z.object({
  id: z.uuid('Invalid movement ID'),
});

export type MovementIdParam = z.infer<typeof movementIdParamSchema>;
