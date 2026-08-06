import 'package:billing_baba/core/database/database.dart' show AppDatabase;

/// Billing Baba `.biba` backup format version.
const kBibaFormatVersion = 1;

/// Drift schema generation included in backups (see [AppDatabase.schemaVersion]).
const kBibaSchemaVersion = 17;

const kBibaDatabaseEntry = 'database.sqlite';
const kBibaManifestEntry = 'manifest.json';
const kBibaMetaPrefix = 'meta/';

const kBibaSyncMetadataEntry = '${kBibaMetaPrefix}sync_metadata.json';
const kBibaDeviceEntry = '${kBibaMetaPrefix}device.json';
const kBibaBusinessPrefsEntry = '${kBibaMetaPrefix}business_prefs.json';
const kBibaDocumentCountersEntry = '${kBibaMetaPrefix}document_counters.json';
const kBibaPendingQueueEntry = '${kBibaMetaPrefix}pending_queue.json';

/// Tables expected in MVP backups (informational manifest field).
const kBibaTablesIncluded = [
  'categories_local',
  'parties_local',
  'items_local',
  'unit_definitions_local',
  'tax_rates_local',
  'godowns_local',
  'business_settings_local',
  'sales_documents_local',
  'sales_document_lines_local',
  'purchase_documents_local',
  'purchase_document_lines_local',
  'local_document_counters',
  'sync_queue',
  'todos_local',
];

/// Preference keys restored with business-scoped backup (never auth tokens).
const kBibaRestorableBusinessPrefKeys = [
  'print_settings',
  'whatsapp_settings',
  'transaction_message_settings',
];
