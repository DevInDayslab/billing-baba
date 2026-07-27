import { z } from 'zod';

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

export const stockAdjustmentLineSchema = z.object({
  item_id: z.uuid('Invalid item ID'),
  quantity_delta: moneyField,
  reason: z.string().trim().optional(),
  cost_per_unit: optionalMoneyField,
});

export const stockAdjustmentPayloadSchema = z.object({
  adjustment_id: z.uuid('Invalid adjustment ID'),
  godown_id: z.uuid('Invalid godown ID'),
  lines: z.array(stockAdjustmentLineSchema).min(1),
});

export type StockAdjustmentPayload = z.infer<
  typeof stockAdjustmentPayloadSchema
>;
