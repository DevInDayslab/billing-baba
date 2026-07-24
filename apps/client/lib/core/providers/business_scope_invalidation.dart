import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/providers/commerce_settings_provider.dart';
import 'package:billing_baba/features/business/utils/business_open_debug_log.dart';
import 'package:billing_baba/features/business/utils/switch_company_debug_log.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_directory_provider.dart';
import 'package:billing_baba/features/crm/presentation/providers/contacts_provider.dart';
import 'package:billing_baba/features/crm/presentation/providers/deals_provider.dart';
import 'package:billing_baba/features/crm/presentation/providers/leads_provider.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_widget_preferences_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/providers/party_groups_provider.dart';
import 'package:billing_baba/features/parties/providers/party_reminder_schedule_provider.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/providers/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pricing/providers/local_item_tier_prices_provider.dart';
import 'package:billing_baba/features/reports/providers/report_refresh_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_line_item_column_visibility_provider.dart';
import 'package:billing_baba/features/settings/providers/print_settings_provider.dart';
import 'package:billing_baba/features/settings/providers/transaction_message_settings_provider.dart';
import 'package:billing_baba/features/settings/providers/whatsapp_settings_provider.dart';
import 'package:billing_baba/features/tasks/providers/tasks_provider.dart';
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
void invalidateAllBusinessScopedProviders(
  Ref ref, {
  bool includeBusinessList = false,
  bool includeBusinessService = true,
}) {
  if (includeBusinessList) {
    ref.invalidate(businessListProvider);
  }

  ref
    ..invalidate(businessProfileProvider)
    ..invalidate(currentBusinessProvider)
    ..invalidate(sidebarBusinessProvider)
    ..invalidate(commerceSettingsProvider)
    ..invalidate(partyListProvider)
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
    ..invalidate(localItemTierPricesProvider)
    ..invalidate(posCartProvider)
    ..invalidate(posSalesListProvider)
    ..invalidate(dashboardProvider)
    ..invalidate(inventoryItemsProvider);

  if (includeBusinessService) {
    ref.invalidate(businessServiceProvider);
  }

  invalidateSaleLists(ref);
  invalidatePurchaseLists(ref);
  invalidatePaymentInLists(ref);
  invalidatePaymentOutLists(ref);
  invalidateExpenseLists(ref);
  invalidateSaleFaLists(ref);
  invalidatePurchaseFaLists(ref);
  invalidateJobWorkLists(ref);
  invalidateReports(ref);
  bumpReportDataEpoch(ref);
}

/// Seeds sidebar/profile UI immediately from list-card data before API warm-up.
void seedBusinessProfilePreview(Ref ref, {required CompanyListEntry entry}) {
  ref.read(businessProfileProvider.notifier).replaceWith(
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

/// Loads core business-scoped data for the dashboard shell after a switch.
///
/// Uses direct service/repository calls and seeds provider state instead of
/// awaiting [.future] on providers that were just invalidated (which can hang).
Future<void> warmBusinessScopedProviders(
  Ref ref, {
  required String businessId,
}) async {
  _ensureRefMounted(ref, 'warm');

  BusinessOpenDebugLog.step('warm', 'resolve BusinessService');
  final service = await ref.read(businessServiceProvider.future);
  _ensureRefMounted(ref, 'warm after service resolve');

  BusinessOpenDebugLog.step('warm', 'parallel fetch (profile, dashboard, tasks)');
  await Future.wait<void>([
    _warmBusinessProfile(ref, service, businessId),
    _warmDashboard(ref),
    _warmTasks(ref, businessId),
  ]);
  _ensureRefMounted(ref, 'warm after parallel fetch');

  ref.read(dashboardWidgetPreferencesProvider);
  BusinessOpenDebugLog.step('warm', 'complete');
}

Future<void> _warmBusinessProfile(
  Ref ref,
  BusinessService service,
  String businessId,
) async {
  BusinessOpenDebugLog.step('warm', 'profile fetch');
  final profile = await service.fetchBusinessProfile(forceRefresh: true);
  _ensureRefMounted(ref, 'warm after profile fetch');

  if (profile.id != businessId) {
    throw const BusinessSelectionFailed(
      'Could not load company data. Please try again.',
    );
  }
  await service.persistSavedProfile(profile);
  ref.read(businessProfileProvider.notifier).replaceWith(profile);
  BusinessOpenDebugLog.step('warm', 'profile ok (${profile.name})');
}

Future<void> _warmDashboard(Ref ref) async {
  BusinessOpenDebugLog.step('warm', 'dashboard');
  await ref.read(dashboardProvider.notifier).refresh();
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
