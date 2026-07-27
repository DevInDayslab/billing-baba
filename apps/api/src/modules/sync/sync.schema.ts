import { z } from 'zod';
import {
  SYNC_HEADER_APP_VERSION,
  SYNC_HEADER_DEVICE_ID,
  SYNC_HEADER_PROTOCOL_VERSION,
  SYNC_MAX_PUSH_MUTATIONS,
  SYNC_PROTOCOL_VERSION,
  SYNC_PULL_LIMIT_DEFAULT,
  SYNC_PULL_LIMIT_MAX,
} from './sync.constants';
import {
  SUPPORTED_ROW_ENTITY_TYPES,
  SYNC_PLATFORMS,
} from './sync.types';

const uuidSchema = z.uuid('Invalid UUID');

const isoDateTimeSchema = z
  .string()
  .datetime({ offset: true, message: 'Must be ISO-8601 datetime' });

export const syncHeadersSchema = z.object({
  [SYNC_HEADER_DEVICE_ID]: uuidSchema,
  [SYNC_HEADER_APP_VERSION]: z.string().min(1).max(64),
  [SYNC_HEADER_PROTOCOL_VERSION]: z
    .string()
    .refine((value) => Number(value) === SYNC_PROTOCOL_VERSION, {
      message: `Protocol version must be ${SYNC_PROTOCOL_VERSION}`,
    }),
});

export type SyncHeaders = z.infer<typeof syncHeadersSchema>;

export const registerDeviceBodySchema = z.object({
  device_id: uuidSchema,
  platform: z.enum(SYNC_PLATFORMS),
  app_version: z.string().min(1).max(64),
  device_name: z.string().min(1).max(200),
});

export type RegisterDeviceBody = z.infer<typeof registerDeviceBodySchema>;

export const bootstrapBodySchema = z.object({
  device_id: uuidSchema,
  schema_version: z.number().int().positive(),
  include_media_metadata: z.boolean().optional().default(true),
});

export type BootstrapBody = z.infer<typeof bootstrapBodySchema>;

export const bootstrapChunkParamsSchema = z.object({
  bootstrap_id: uuidSchema,
  chunk_index: z.coerce.number().int().min(0),
});

export const bootstrapChunkQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
});

const rowMutationSchema = z.object({
  mutation_id: uuidSchema,
  kind: z.literal('row'),
  entity_type: z.enum(SUPPORTED_ROW_ENTITY_TYPES),
  entity_id: uuidSchema,
  operation: z.enum(['create', 'update', 'delete']),
  base_sync_version: z.number().int().min(0),
  payload: z.record(z.string(), z.unknown()),
  client_updated_at: isoDateTimeSchema,
});

const commandMutationSchema = z.object({
  mutation_id: uuidSchema,
  kind: z.literal('command'),
  // Commands not implemented in MVP — accepted by schema, rejected in PushService.
  command: z.string().min(1).max(64),
  command_id: uuidSchema,
  payload: z.record(z.string(), z.unknown()),
  client_updated_at: isoDateTimeSchema,
});

export const pushBodySchema = z
  .object({
    device_id: uuidSchema,
    client_batch_id: uuidSchema,
    mutations: z
      .array(
        z.discriminatedUnion('kind', [
          rowMutationSchema,
          commandMutationSchema,
        ]),
      )
      .min(1)
      .max(SYNC_MAX_PUSH_MUTATIONS),
  })
  .superRefine((body, ctx) => {
    const mutationIds = new Set<string>();
    for (const mutation of body.mutations) {
      if (mutationIds.has(mutation.mutation_id)) {
        ctx.addIssue({
          code: 'custom',
          message: 'Duplicate mutation_id in batch',
          path: ['mutations'],
        });
        break;
      }
      mutationIds.add(mutation.mutation_id);
    }
  });

export type PushBody = z.infer<typeof pushBodySchema>;

export const pullQuerySchema = z.object({
  cursor: z.string().min(1),
  limit: z.coerce
    .number()
    .int()
    .min(1)
    .max(SYNC_PULL_LIMIT_MAX)
    .optional()
    .default(SYNC_PULL_LIMIT_DEFAULT),
  entity_types: z.string().optional(),
});

export type PullQuery = z.infer<typeof pullQuerySchema>;

export const mediaUploadIntentBodySchema = z.object({
  device_id: uuidSchema,
  client_media_id: uuidSchema,
  mime_type: z.string().min(1).max(200),
  file_size: z.number().int().positive(),
  checksum_sha256: z
    .string()
    .regex(/^[a-fA-F0-9]{64}$/, 'checksum_sha256 must be 64 hex chars'),
  purpose: z.string().min(1).max(100),
  filename: z.string().min(1).max(500).optional(),
});

export type MediaUploadIntentBody = z.infer<typeof mediaUploadIntentBodySchema>;

export const mediaUploadCompleteBodySchema = z.object({
  intent_id: uuidSchema,
  client_media_id: uuidSchema,
  checksum_sha256: z
    .string()
    .regex(/^[a-fA-F0-9]{64}$/, 'checksum_sha256 must be 64 hex chars'),
});

export type MediaUploadCompleteBody = z.infer<
  typeof mediaUploadCompleteBodySchema
>;

export const mediaAssetParamsSchema = z.object({
  asset_id: uuidSchema,
});

export const mediaUrlQuerySchema = z.object({
  variant: z
    .enum(['thumbnail', 'medium', 'original'])
    .optional()
    .default('original'),
});
