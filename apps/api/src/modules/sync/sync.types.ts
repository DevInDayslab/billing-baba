export const SUPPORTED_SYNC_COMMANDS = [
  'finalize_sale',
  'finalize_purchase',
  'finalize_credit_note',
  'finalize_debit_note',
  'record_payment',
  'record_receipt',
  'stock_adjustment',
  'stock_transfer',
  'post_journal_entry',
] as const;

export type SupportedSyncCommand = (typeof SUPPORTED_SYNC_COMMANDS)[number];

export const SUPPORTED_ROW_ENTITY_TYPES = [
  'areas',
  'business_settings',
  'tax_rates',
  'loyalty_rules',
  'document_number_sequences',
  'parties',
  'party_phones',
  'party_links',
  'party_tags',
  'party_tag_assignments',
  'party_visits',
  'categories',
  'brands',
  'unit_definitions',
  'unit_conversions',
  'items',
  'item_units',
  'item_tier_prices',
  'item_alternatives',
  'godowns',
  'item_locations',
  'users',
  'branches',
  'leads',
  'lead_activities',
  'contacts',
  'contact_activities',
  'deals',
  'sales_documents',
  'sales_document_lines',
  'purchase_documents',
  'purchase_document_lines',
  'expense_categories',
  'expenses',
  'pos_sessions',
  'job_work_orders',
  'document_attachments',
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
