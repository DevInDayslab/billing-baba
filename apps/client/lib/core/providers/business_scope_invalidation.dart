import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/utils/business_open_debug_log.dart';
import 'package:billing_baba/features/crm/presentation/providers/contacts_provider.dart';
import 'package:billing_baba/features/crm/presentation/providers/deals_provider.dart';
import 'package:billing_baba/features/crm/presentation/providers/leads_provider.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_widget_preferences_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/providers/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pricing/providers/local_item_tier_prices_provider.dart';
import 'package:billing_baba/features/reports/providers/report_refresh_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_line_item_column_visibility_provider.dart';
import 'package:billing_baba/features/settings/providers/print_settings_provider.dart';
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
    ..invalidate(partyListProvider)
    ..invalidate(partyServiceProvider)
    ..invalidate(contactsProvider)
    ..invalidate(leadsProvider)
    ..invalidate(dealsProvider)
    ..invalidate(tasksProvider)
    ..invalidate(printSettingsProvider)
    ..invalidate(printSettingsRepositoryProvider)
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

  BusinessOpenDebugLog.step('warm', 'dashboard');
  await ref.read(dashboardProvider.notifier).refresh();
  _ensureRefMounted(ref, 'warm after dashboard');

  BusinessOpenDebugLog.step('warm', 'dashboard ok');

  BusinessOpenDebugLog.step('warm', 'tasks');
  final taskRepo = await ref.read(taskRepositoryProvider.future);
  _ensureRefMounted(ref, 'warm after task repo');

  final tasks = await taskRepo.load(businessId);
  ref.read(tasksProvider.notifier).replaceWith(tasks);
  BusinessOpenDebugLog.step('warm', 'tasks ok (${tasks.length})');

  ref.read(dashboardWidgetPreferencesProvider);
  BusinessOpenDebugLog.step('warm', 'complete');
}

void _ensureRefMounted(Ref ref, String step) {
  if (ref.mounted) return;
  BusinessOpenDebugLog.step(step, 'aborted — ref disposed');
  throw const BusinessSelectionFailed(
    'Company switch was interrupted. Please try again.',
  );
}
