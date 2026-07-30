/** Sync protocol v1 constants — docs/11-sync-api-contract.md */

export const SYNC_PROTOCOL_VERSION = 1;

export const SYNC_MIN_CLIENT_VERSION = '1.4.0';

/** Fallback when schema_version table is empty */
export const SYNC_SCHEMA_VERSION_FALLBACK = 42;

export const SYNC_MAX_PUSH_MUTATIONS = 100;

export const SYNC_MAX_PUSH_BYTES = 1_048_576;

export const SYNC_PULL_LIMIT_DEFAULT = 200;

export const SYNC_PULL_LIMIT_MAX = 500;

export const SYNC_BOOTSTRAP_CHUNK_MAX_BYTES = 2_097_152;

export const SYNC_BOOTSTRAP_TTL_MS = 60 * 60 * 1000;

export const SYNC_NUMBERING_STRATEGY = 'temp_local_remap' as const;

export const SYNC_HEADER_DEVICE_ID = 'x-device-id';

export const SYNC_HEADER_APP_VERSION = 'x-app-version';

export const SYNC_HEADER_PROTOCOL_VERSION = 'x-sync-protocol-version';

export const ZERO_UUID = '00000000-0000-0000-0000-000000000000';
