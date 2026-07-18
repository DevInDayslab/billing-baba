import { z } from 'zod';

export const barcodeLookupBodySchema = z.object({
  barcode: z.string().trim().min(1).max(50),
});
