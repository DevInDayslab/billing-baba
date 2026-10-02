import { REGISTERED_ROW_ENTITY_TYPES } from './apply/row-entities';

/** MVP: finalize commands for Phase 2 transactional documents. */
export const SUPPORTED_SYNC_COMMANDS = [
  'finalize_sale',
  'finalize_purchase',
  'finalize_credit_note',
  'finalize_debit_note',
  'stock_adjustment',
] as const;

export type SupportedSyncCommand = string;

/** * Row entity types accepted in push mutation schema.
 * Derived from [ROW_ENTITIES] so status, push validation, and appliers stay aligned.
 * Pull-only entities (e.g. stock_levels) validate here but are rejected in push apply.
 */
export const SUPPORTED_ROW_ENTITY_TYPES = REGISTERED_ROW_ENTITY_TYPES;

export type SupportedRowEntityType =
  (typeof SUPPORTED_ROW_ENTITY_TYPES)[number];

export const SYNC_PLATFORMS = [
  'windows',
  'macos',
  'android',
  'ios',
  'linux',
] as const;

export type SyncPlatform = (typeof SYNC_PLATFORMS)[number];

export type SyncDeviceRecord = {
  device_id: string;
  business_id: string;
  platform: string;
  app_version: string;
  device_name: string;
  last_sync_at: string | null;
  registered_at: string;
};
