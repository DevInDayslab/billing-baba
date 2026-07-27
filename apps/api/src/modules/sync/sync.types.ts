/** MVP: no sync commands implemented yet. */
export const SUPPORTED_SYNC_COMMANDS = [] as const;

export type SupportedSyncCommand = string;

/** MVP registered row entities — keep in sync with apply/row-entities.ts */
export const SUPPORTED_ROW_ENTITY_TYPES = [
  'categories',
  'parties',
  'items',
  'unit_definitions',
  'tax_rates',
  'godowns',
  'business_settings',
] as const;

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
