/// Secure storage and preference keys.
abstract final class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const selectedBusinessId = 'selected_business_id';
  static const accountPhone = 'account_phone';

  /// Survives logout — used for login greeting ("Welcome" vs "Welcome Back").
  static const hasLoggedInBefore = 'has_logged_in_before';
  static const cachedBusinesses = 'cached_businesses';
  static const cachedBusinessesAccountId = 'cached_businesses_account_id';
  static const cachedProfile = 'cached_profile';
  static const lastOpenedBusinessId = 'last_opened_business_id';
  static const pendingBusinessCreates = 'pending_business_creates';
  static const cachedBusinessProfile = 'cached_business_profile';
  static const bulkItemsUpdateCalloutDismissed =
      'bulk_items_update_callout_dismissed';
  static const sidebarCollapsed = 'sidebar_collapsed';
  static const sidebarExpandedSections = 'sidebar_expanded_sections';
  static const cachedParties = 'cached_parties';
  static const partyLocalExtensions = 'party_local_extensions';
  static const pendingPartyOperations = 'pending_party_operations';
  static const partyListFilter = 'party_list_filter';
  static const selectedPartyId = 'selected_party_id';
  static const partyGroupNames = 'party_group_names';
  static const partyDetailUpperPaneRatio = 'party_detail_upper_pane_ratio';
  static const localItemTierPrices = 'local_item_tier_prices';
  static const localItemSuppliers = 'local_item_suppliers';

  /// Marks one-time migration from [localItemSuppliers] SharedPreferences cache.
  static String itemSuppliersMigratedFor(String businessId) =>
      'item_suppliers_migrated_$businessId';

  /// Marks one-time migration from [localItemTierPrices] SharedPreferences cache.
  static String itemTierPricesMigratedFor(String businessId) =>
      'item_tier_prices_migrated_$businessId';
  static const saleLineItemColumnVisibility =
      'sale_line_item_column_visibility';
  static const itemSettings = 'item_settings';
  static const saleInvoiceSettings = 'sale_invoice_settings';
  static const dashboardTasks = 'dashboard_tasks';

  /// Marks one-time migration from [dashboardTasks] SharedPreferences cache.
  static String dashboardTasksMigratedFor(String businessId) =>
      'dashboard_tasks_migrated_$businessId';

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
  static const mobileMenuExpandedSection = 'mobile_menu_expanded_section';
  static const notificationFilter = 'notification_filter';
  static const notificationPermissionAsked = 'notification_permission_asked';
  static const notificationPermissionDenied = 'notification_permission_denied';

  static String notificationPreferencesFor(String businessId) =>
      'notification_preferences_$businessId';

  static String scheduledRemindersFor(String businessId) =>
      'scheduled_reminders_$businessId';

  /// Stable install-lifetime sync device id (UUID).
  static const syncDeviceId = 'sync_device_id';

  /// Device trust for "Remember for 30 days" — survives logout.
  static const deviceTrustToken = 'device_trust_token';
  static const deviceTrustPhone = 'device_trust_phone';
  static const deviceTrustExpiresAt = 'device_trust_expires_at';

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

  /// ISO-8601 timestamp when stock_levels pull was first reconciled for a business.
  static String syncStockLevelsReconciledAtFor(String businessId) =>
      'sync_stock_levels_reconciled_at_$businessId';

  /// Per-business local POS session id used while offline.
  static String localPosSessionId(String businessId) =>
      'local_pos_session_$businessId';
}
