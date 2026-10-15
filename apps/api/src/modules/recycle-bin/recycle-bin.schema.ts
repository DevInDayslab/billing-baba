import { z } from 'zod';
import { RECYCLE_BIN_ENTITY_TYPES } from './recycle-bin.constants';

export const recycleBinListQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  entity_type: z.enum(RECYCLE_BIN_ENTITY_TYPES).optional(),
});

export const recycleBinEntityParamsSchema = z.object({
  entityType: z.enum(RECYCLE_BIN_ENTITY_TYPES),
  entityId: z.uuid(),
});

export type RecycleBinListQuery = z.infer<typeof recycleBinListQuerySchema>;
