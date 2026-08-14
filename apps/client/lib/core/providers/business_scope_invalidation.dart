import 'dart:async';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/network/business_selection_retry_guard.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/application/commerce_settings_provider.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/utils/business_open_debug_log.dart';
import 'package:billing_baba/features/business/utils/switch_company_debug_log.dart';
import 'package:billing_baba/features/collaboration/application/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:billing_baba/features/crm/application/contacts_provider.dart';
import 'package:billing_baba/features/crm/application/deals_provider.dart';
import 'package:billing_baba/features/crm/application/leads_provider.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_service.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_widget_preferences_provider.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/application/item_alternatives_index_provider.dart';
import 'package:billing_baba/features/inventory/application/item_bom_provider.dart';
import 'package:billing_baba/features/inventory/application/item_suppliers_provider.dart';
import 'package:billing_baba/features/inventory/application/item_tier_prices_provider.dart';
import 'package:billing_baba/features/inventory/data/item_local_source.dart';
import 'package:billing_baba/features/parties/application/party_groups_provider.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_optimistic_profile_images_provider.dart';
import 'package:billing_baba/features/parties/application/party_reminder_schedule_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_sales_list_provider.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_provider.dart';
import 'package:billing_baba/features/reports/application/report_refresh_provider.dart';
import 'package:billing_baba/features/sales/application/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/application/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/application/job_work_orders_provider.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/application/sale_fa_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/application/sale_line_item_column_visibility_provider.dart';
import 'package:billing_baba/features/sales/application/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/application/sale_return_provider.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/settings/application/print_settings_provider.dart';
import 'package:billing_baba/features/settings/application/transaction_message_settings_provider.dart';
import 'package:billing_baba/features/settings/application/whatsapp_settings_provider.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_view_provider.dart';
import 'package:billing_baba/features/subscription/application/purchase_history_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_plans_provider.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/data/task_repository.dart';
import 'package:billing_baba/shared/attachments/document_attachment_providers.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Non-null while a business open/switch initialization is in progress.
final businessSessionLoadingProvider =
    NotifierProvider<_BusinessSessionLoading, String?>(
      _BusinessSessionLoading.new,
    );

class _BusinessSessionLoading extends Notifier<String?> {
  @override
  String? build() => null;

  void start(String businessId) => state = businessId;

  void clear() => state = null;
}

/// True while navigating to the company picker after "Switch Company".
final businessSelectionTransitionProvider =
    NotifierProvider<_BusinessSelectionTransition, bool>(
      _BusinessSelectionTransition.new,
    );

class _BusinessSelectionTransition extends Notifier<bool> {
  @override
  bool build() => false;

  void start() {
    SwitchCompanyDebugLog.loading('businessSelectionTransition → true');
    state = true;
  }

  void clear() {
    SwitchCompanyDebugLog.loading('businessSelectionTransition → false');
    state = false;
  }
}

/// Blocking overlay + session reset until the company directory has reloaded.
///
/// Owns the transition overlay end-to-end so the Companies page does not clear
/// it early (which caused a flash + second spinner).
Future<void> switchToBusinessSelection(
  WidgetRef ref, {
  required Future<void> Function() navigateToBusinessList,
}) async {
  final container = ref.container;
  SwitchCompanyDebugLog.action('switchToBusinessSelection begin');
  container.read(businessSelectionTransitionProvider.notifier).start();
  try {
    await container.read(authProvider.notifier).enterBusinessSelection();
    final auth = container.read(authProvider);
    if (auth.status != AuthStatus.needsBusinessSelection) {
      SwitchCompanyDebugLog.action(
        'switch aborted — auth=${auth.status.name}',
      );
      return;
    }
    SwitchCompanyDebugLog.nav('explicit navigateToBusinessList');
    await navigateToBusinessList();
    SwitchCompanyDebugLog.loading('await companyDirectoryProvider.future');
    final entries = await container.read(companyDirectoryProvider.future);
    SwitchCompanyDebugLog.loading(
      'companyDirectory ready (${entries.length} entries)',
    );
  } finally {
    container.read(businessSelectionTransitionProvider.notifier).clear();
    SwitchCompanyDebugLog.action('switchToBusinessSelection end');
  }
}

/// Invalidates providers that cache or display business-scoped data.
///
/// Uses [ProviderContainer.invalidate] (not [Ref.invalidate]) so callers like
/// [authProvider] can clear dependents that watch auth without hitting
/// CircularDependencyError (e.g. [businessProfileProvider]).
void invalidateAllBusinessScopedProviders(
  Ref ref, {
  bool includeBusinessList = false,
  bool includeBusinessService = true,
  bool includeBusinessProfile = true,
}) {
  invalidateAllBusinessScopedProvidersOn(
    ref.container,
    includeBusinessList: includeBusinessList,
    includeBusinessService: includeBusinessService,
    includeBusinessProfile: includeBusinessProfile,
  );
}

/// Same as [invalidateAllBusinessScopedProviders] for [WidgetRef]/menu callers.
void invalidateAllBusinessScopedProvidersOn(
  ProviderContainer container, {
  bool includeBusinessList = false,
  bool includeBusinessService = true,
  bool includeBusinessProfile = true,
}) {
  if (includeBusinessList) {
    container.invalidate(businessListProvider);
  }

  if (includeBusinessProfile) {
    container
      ..invalidate(businessProfileProvider)
      ..invalidate(currentBusinessProvider)
      ..invalidate(sidebarBusinessProvider);
  }

  container
    ..invalidate(commerceSettingsProvider)
    ..invalidate(partyListProvider)
    ..invalidate(partyLedgerBusinessIdProvider)
    ..invalidate(partyServiceProvider)
    ..invalidate(partyGroupsProvider)
    ..invalidate(partyGroupsStorageReadyProvider)
    ..invalidate(contactsProvider)
    ..invalidate(leadsProvider)
    ..invalidate(dealsProvider)
    ..invalidate(tasksProvider)
    ..invalidate(printSettingsProvider)
    ..invalidate(printSettingsRepositoryProvider)
    ..invalidate(whatsAppSettingsProvider)
    ..invalidate(whatsappSettingsRepositoryProvider)
    ..invalidate(transactionMessageSettingsProvider)
    ..invalidate(transactionMessageSettingsRepositoryProvider)
    ..invalidate(partyReminderScheduleMapProvider)
    ..invalidate(partyReminderScheduleRepositoryProvider)
    ..invalidate(dashboardWidgetPreferencesProvider)
    ..invalidate(saleLineItemColumnVisibilityStateProvider)
    ..invalidate(itemTierPricesProvider)
    ..invalidate(itemSuppliersProvider)
    ..invalidate(itemBomProvider)
    ..invalidate(itemAlternativesIndexProvider)
    ..invalidate(posCartProvider)
    ..invalidate(posSalesListProvider)
    ..invalidate(dashboardProvider)
    ..invalidate(inventoryItemsProvider)
    ..invalidate(currentSubscriptionStateProvider)
    ..invalidate(subscriptionPlansProvider)
    ..invalidate(purchaseHistoryStateProvider)
    ..invalidate(plansPricingViewProvider)
    ..invalidate(imageServiceProvider)
    ..invalidate(partyOptimisticProfileImagesProvider)
    ..invalidate(documentAttachmentServiceProvider)
    ..invalidate(syncMetadataStoreProvider)
    ..invalidate(syncCoordinatorProvider)
    ..invalidate(syncEngineProvider)
    ..invalidate(commandAwareSyncEngineProvider);

  if (includeBusinessService) {
    container.invalidate(businessServiceProvider);
  }

  container
    ..invalidate(saleInvoicesProvider)
    ..invalidate(saleOrdersProvider)
    ..invalidate(saleReturnsProvider)
    ..invalidate(estimateQuotationsProvider)
    ..invalidate(deliveryChallansProvider)
    ..invalidate(salesDocumentsListProvider(saleOrderListScope()))
    ..invalidate(salesDocumentsListProvider(deliveryChallanListScope()))
    ..invalidate(salesDocumentsListProvider(salesReturnListScope()))
    ..invalidate(salesDocumentsListProvider(estimateListScope()))
    ..invalidate(salesDocumentsListProvider(proformaListScope()))
    ..invalidate(saleFaProvider)
    ..invalidate(purchaseBillsProvider)
    ..invalidate(paymentInRecordsProvider)
    ..invalidate(paymentOutRecordsProvider)
    ..invalidate(expenseCategoriesProvider)
    ..invalidate(expenseTransactionsProvider)
    ..invalidate(purchaseFaProvider)
    ..invalidate(jobWorkOrdersListProvider);

  container.read(reportDataEpochProvider.notifier).bump();
}

/// Seeds sidebar/profile UI immediately from list-card data before API warm-up.
void seedBusinessProfilePreview(Ref ref, {required CompanyListEntry entry}) {
  ref
      .read(businessProfileProvider.notifier)
      .replaceWith(
        BusinessProfileModel(
          id: entry.id,
          name: entry.name,
          ownerName: entry.ownerName,
          phone: entry.phone,
          email: entry.email,
          gstin: entry.gstin,
          address: entry.address,
          logoUrl: entry.logoUrl,
        ),
      );
}

/// Fast path for company open — cache/local reads only; blocks the overlay.
Future<void> warmBusinessScopedProvidersCritical(
  Ref ref, {
  required String businessId,
}) async {
  _ensureRefMounted(ref, 'warm-critical');

  BusinessOpenDebugLog.step('warm-critical', 'resolve BusinessService');
  final service = await ref.read(businessServiceProvider.future);
  _ensureRefMounted(ref, 'warm-critical after service resolve');

  BusinessOpenDebugLog.step(
    'warm-critical',
    'parallel (profile cache, dashboard cache, tasks)',
  );
  await Future.wait<void>([
    _warmBusinessProfileCache(ref, service, businessId),
    _warmDashboardCache(ref),
    _warmTasks(ref, businessId),
  ]);
  _ensureRefMounted(ref, 'warm-critical after parallel fetch');

  ref.read(dashboardWidgetPreferencesProvider);
  BusinessOpenDebugLog.step('warm-critical', 'complete');
}

/// Network refresh and catalog hydration — runs after the overlay dismisses.
Future<void> warmBusinessScopedProvidersDeferred(
  Ref ref, {
  required String businessId,
}) async {
  _ensureRefMounted(ref, 'warm-deferred');

  BusinessOpenDebugLog.step('warm-deferred', 'resolve BusinessService');
  final service = await ref.read(businessServiceProvider.future);
  _ensureRefMounted(ref, 'warm-deferred after service resolve');

  BusinessOpenDebugLog.step(
    'warm-deferred',
    'parallel (profile network, dashboard, inventory if empty)',
  );
  await Future.wait<void>([
    _warmBusinessProfileNetwork(ref, service, businessId),
    _warmDashboard(ref),
    _warmInventoryCatalogIfEmpty(ref, businessId),
  ]);
  _ensureRefMounted(ref, 'warm-deferred after parallel fetch');
  BusinessOpenDebugLog.step('warm-deferred', 'complete');
}

/// Loads core business-scoped data for the dashboard shell after a switch.
///
/// Uses direct service/repository calls and seeds provider state instead of
/// awaiting [.future] on providers that were just invalidated (which can hang).
Future<void> warmBusinessScopedProviders(
  Ref ref, {
  required String businessId,
}) async {
  await warmBusinessScopedProvidersCritical(ref, businessId: businessId);
  await warmBusinessScopedProvidersDeferred(ref, businessId: businessId);
}

/// Pulls the item catalog into local SQLite when empty (e.g. first API login).
Future<void> _warmInventoryCatalog(Ref ref) async {
  BusinessOpenDebugLog.step('warm', 'inventory');
  try {
    final inventory = await ref.read(inventoryServiceProvider.future);
    _ensureRefMounted(ref, 'warm after inventory service');
    await inventory.fetchItemsPage();
    BusinessOpenDebugLog.step('warm', 'inventory ok');
  } on Object catch (error) {
    BusinessOpenDebugLog.step('warm', 'inventory skipped ($error)');
  }
}

Future<void> _warmInventoryCatalogIfEmpty(
  Ref ref,
  String businessId,
) async {
  final db = ref.read(appDatabaseProvider);
  final count = await ItemLocalSource(db).countActive(businessId);
  if (count > 0) {
    BusinessOpenDebugLog.step(
      'warm',
      'inventory skipped — $count local items',
    );
    return;
  }
  await _warmInventoryCatalog(ref);
}

Future<void> _warmBusinessProfileCache(
  Ref ref,
  BusinessService service,
  String businessId,
) async {
  BusinessOpenDebugLog.step('warm', 'profile cache');
  final cached = await service.readCachedBusinessProfile();
  if (cached != null && cached.id == businessId && ref.mounted) {
    ref.read(businessProfileProvider.notifier).replaceWith(cached);
    BusinessOpenDebugLog.step(
      'warm',
      'profile cache ok (${cached.name})',
    );
    return;
  }
  BusinessOpenDebugLog.step('warm', 'profile cache miss');
}

Future<void> _warmBusinessProfileNetwork(
  Ref ref,
  BusinessService service,
  String businessId,
) async {
  if (BusinessSelectionRetryGuard.isBlocked(businessId)) {
    BusinessOpenDebugLog.step(
      'warm',
      'profile network skipped — backend unreachable',
    );
    return;
  }

  // Cache-first; network only when cache is missing or stale.
  BusinessOpenDebugLog.step('warm', 'profile network fetch');
  final profile = await service.fetchBusinessProfile();
  _ensureRefMounted(ref, 'warm after profile fetch');

  if (profile.id != businessId) {
    throw const BusinessSelectionFailed(
      'Could not load company data. Please try again.',
    );
  }
  await service.persistSavedProfile(profile);
  ref.read(businessProfileProvider.notifier).replaceWith(profile);
  BusinessOpenDebugLog.step('warm', 'profile network ok (${profile.name})');
}

Future<void> _warmDashboardCache(Ref ref) async {
  BusinessOpenDebugLog.step('warm', 'dashboard cache');
  final service = await ref.read(dashboardServiceProvider.future);
  final period = ref.read(dashboardPeriodFilterProvider);
  final cached = service.readCachedViewState(DashboardQuery(period: period));
  if (cached != null && ref.mounted) {
    ref.read(dashboardProvider.notifier).seedCached(cached);
    BusinessOpenDebugLog.step('warm', 'dashboard cache ok');
    return;
  }
  BusinessOpenDebugLog.step('warm', 'dashboard cache miss');
}

Future<void> _warmDashboard(Ref ref) async {
  // Share the single in-flight [dashboardProvider] build after invalidation.
  // Calling [Dashboard.refresh] here raced with Home's watch and issued
  // duplicate GETs.
  BusinessOpenDebugLog.step('warm', 'dashboard');
  await ref.read(dashboardProvider.future);
  _ensureRefMounted(ref, 'warm after dashboard');
  BusinessOpenDebugLog.step('warm', 'dashboard ok');
}

Future<void> _warmTasks(Ref ref, String businessId) async {
  BusinessOpenDebugLog.step('warm', 'tasks');
  final taskRepo = await ref.read(taskRepositoryProvider.future);
  _ensureRefMounted(ref, 'warm after task repo');

  final tasks = await taskRepo.load(businessId);
  ref.read(tasksProvider.notifier).replaceWith(tasks);
  BusinessOpenDebugLog.step('warm', 'tasks ok (${tasks.length})');
}

void _ensureRefMounted(Ref ref, String step) {
  if (ref.mounted) return;
  BusinessOpenDebugLog.step(step, 'aborted — ref disposed');
  throw const BusinessSelectionFailed(
    'Company switch was interrupted. Please try again.',
  );
}
