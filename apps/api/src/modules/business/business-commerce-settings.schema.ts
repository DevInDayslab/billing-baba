import { z } from 'zod';

const pricingTierLabelsField = z
  .record(z.string(), z.string().trim().min(1).max(64))
  .optional();

export const updateCommerceSettingsBodySchema = z.object({
  pricing_tier_labels: pricingTierLabelsField,
  default_invoice_tax_rate: z.coerce
    .number()
    .min(0)
    .max(100)
    .nullable()
    .optional(),
});

export type UpdateCommerceSettingsBody = z.infer<
  typeof updateCommerceSettingsBodySchema
>;
