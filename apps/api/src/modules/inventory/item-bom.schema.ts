import { z } from 'zod';

export const itemBomItemIdParamSchema = z.object({
  itemId: z.uuid('Invalid item ID'),
});

export type ItemBomItemIdParam = z.infer<typeof itemBomItemIdParamSchema>;

const positiveQtySchema = z
  .string()
  .regex(/^\d+(\.\d+)?$/, 'Quantity must be a positive number')
  .refine((value) => Number(value) > 0, 'Quantity must be greater than zero')
  .or(
    z
      .number()
      .positive('Quantity must be greater than zero')
      .transform((value) => value.toString()),
  );

const moneyStringSchema = z
  .string()
  .regex(/^-?\d+(\.\d+)?$/, 'Invalid amount')
  .or(z.number().transform((value) => value.toString()));

const itemBomMaterialInputSchema = z.object({
  raw_item_id: z.uuid('Invalid raw item ID'),
  qty: positiveQtySchema,
  unit_id: z.uuid('Invalid unit ID'),
  purchase_price: moneyStringSchema.optional().default('0'),
  sort_order: z.number().int().min(0).optional().default(0),
});

const itemBomCostInputSchema = z.object({
  id: z.uuid('Invalid cost ID').optional(),
  description: z.string().trim().min(1, 'Description is required'),
  amount: moneyStringSchema,
  sort_order: z.number().int().min(0).optional().default(0),
});

export const replaceItemBomBodySchema = z
  .object({
    materials: z.array(itemBomMaterialInputSchema).default([]),
    costs: z.array(itemBomCostInputSchema).default([]),
  })
  .superRefine((body, ctx) => {
    const rawItemIds = body.materials.map((material) => material.raw_item_id);
    const uniqueRawItemIds = new Set(rawItemIds);
    if (uniqueRawItemIds.size !== rawItemIds.length) {
      ctx.addIssue({
        code: 'custom',
        message: 'Each raw material may only appear once',
        path: ['materials'],
      });
    }

    const costIds = body.costs
      .map((cost) => cost.id)
      .filter((id): id is string => id != null);
    const uniqueCostIds = new Set(costIds);
    if (uniqueCostIds.size !== costIds.length) {
      ctx.addIssue({
        code: 'custom',
        message: 'Duplicate cost row IDs',
        path: ['costs'],
      });
    }
  });

export type ReplaceItemBomBody = z.infer<typeof replaceItemBomBodySchema>;
