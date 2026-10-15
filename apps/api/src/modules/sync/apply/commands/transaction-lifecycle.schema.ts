import { z } from 'zod';
import { RECYCLE_BIN_ENTITY_TYPES } from '../../../recycle-bin/recycle-bin.constants';

export const transactionLifecyclePayloadSchema = z.object({
  entity_type: z.enum(RECYCLE_BIN_ENTITY_TYPES),
  entity_id: z.uuid(),
});
