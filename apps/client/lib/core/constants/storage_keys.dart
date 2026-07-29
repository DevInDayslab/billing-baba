/// Secure storage and preference keys.
abstract final class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const selectedBusinessId = 'selected_business_id';
  static const accountPhone = 'account_phone';
  static const cachedBusinesses = 'cached_businesses';
  static const cachedBusinessesAccountId = 'cached_businesses_account_id';
  static const cachedProfile = 'cached_profile';
  static const lastOpenedBusinessId = 'last_opened_business_id';
  static const pendingBusinessCreates = 'pending_business_creates';
  static const cachedBusinessProfile = 'cached_business_profile';
  static const sidebarCollapsed = 'sidebar_collapsed';
  static const sidebarExpandedSections = 'sidebar_expanded_sections';
  static const cachedParties = 'cached_parties';
  static const partyLocalExtensions = 'party_local_extensions';
  static const pendingPartyOperations = 'pending_party_operations';
  static const partyListFilter = 'party_list_filter';
  static const selectedPartyId = 'selected_party_id';
  static const partyGroupNames = 'party_group_names';
  static const localItemTierPrices = 'local_item_tier_prices';
  static const saleLineItemColumnVisibility =
      'sale_line_item_column_visibility';
  static const dashboardTasks = 'dashboard_tasks';
  static const dashboardSideWidgets = 'dashboard_side_widgets';
  static const dashboardSnapshots = 'dashboard_snapshots';
  static const barcodeImportDraft = 'barcode_import_draft';
  static const printSettings = 'print_settings';
  static const whatsappSettings = 'whatsapp_settings';
  static const transactionMessageSettings = 'transaction_message_settings';
  static const partyReminderSchedule = 'party_reminder_schedule';
  static const recentSearchPageIds = 'recent_search_page_ids';
  static const collaborationMembers = 'collaboration_members';
  static const collaborationInvitations = 'collaboration_invitations';

  /// Stable install-lifetime sync device id (UUID).
  static const syncDeviceId = 'sync_device_id';
  /// Legacy global keys — migrated to per-business keys on first read.
  static const syncPullCursor = 'sync_pull_cursor';
  static const syncBootstrappedAt = 'sync_bootstrapped_at';
  static const syncLastServerSchemaVersion = 'sync_last_server_schema_version';

  static const syncLocalSchemaVersion = 'sync_local_schema_version';

  static String syncPullCursorFor(String businessId) =>
      'sync_pull_cursor_$businessId';

  static String syncBootstrappedAtFor(String businessId) =>
      'sync_bootstrapped_at_$businessId';

  static String syncLastServerSchemaVersionFor(String businessId) =>
      'sync_last_server_schema_version_$businessId';

  /// Per-business local POS session id used while offline.
  static String localPosSessionId(String businessId) =>
      'local_pos_session_$businessId';
}
