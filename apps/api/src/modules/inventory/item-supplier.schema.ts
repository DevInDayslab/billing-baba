import { z } from 'zod';

export const itemSupplierItemIdParamSchema = z.object({
  itemId: z.uuid('Invalid item ID'),
});

export type ItemSupplierItemIdParam = z.infer<
  typeof itemSupplierItemIdParamSchema
>;

const itemSupplierInputSchema = z.object({
  party_id: z.uuid('Invalid party ID'),
  is_default: z.boolean().optional().default(false),
  sort_order: z.number().int().min(0).optional().default(0),
});

export const replaceItemSuppliersBodySchema = z
  .object({
    suppliers: z.array(itemSupplierInputSchema),
  })
  .superRefine((body, ctx) => {
    const partyIds = body.suppliers.map((supplier) => supplier.party_id);
    const uniquePartyIds = new Set(partyIds);
    if (uniquePartyIds.size !== partyIds.length) {
      ctx.addIssue({
        code: 'custom',
        message: 'Each party may only appear once',
        path: ['suppliers'],
      });
    }

    const defaultCount = body.suppliers.filter(
      (supplier) => supplier.is_default,
    ).length;
    if (body.suppliers.length > 0 && defaultCount === 0) {
      ctx.addIssue({
        code: 'custom',
        message: 'At least one supplier must be marked as default',
        path: ['suppliers'],
      });
    }
    if (defaultCount > 1) {
      ctx.addIssue({
        code: 'custom',
        message: 'Only one supplier may be marked as default',
        path: ['suppliers'],
      });
    }
  });

export type ReplaceItemSuppliersBody = z.infer<
  typeof replaceItemSuppliersBodySchema
>;

export type ItemSupplierInput = z.infer<typeof itemSupplierInputSchema>;
