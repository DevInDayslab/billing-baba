import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/presentation/login_page.dart';
import 'package:billing_baba/features/auth/presentation/splash_page.dart';
import 'package:billing_baba/features/auth/presentation/user_profile_page.dart';
import 'package:billing_baba/features/auth/presentation/verify_otp_page.dart';
import 'package:billing_baba/features/business/presentation/business_list_page.dart';
import 'package:billing_baba/features/business/presentation/edit_profile_page.dart';
import 'package:billing_baba/features/business/utils/switch_company_debug_log.dart';
import 'package:billing_baba/features/collaboration/application/company_session_bootstrap_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/guards/access_denied_page.dart';
import 'package:billing_baba/features/collaboration/guards/permission_guard.dart';
import 'package:billing_baba/features/collaboration/presentation/sync_share_page.dart';
import 'package:billing_baba/features/crm/presentation/contacts_screen.dart';
import 'package:billing_baba/features/crm/presentation/deals_screen.dart';
import 'package:billing_baba/features/crm/presentation/leads_screen.dart';
import 'package:billing_baba/features/dashboard/presentation/coming_soon_page.dart';
import 'package:billing_baba/features/dashboard/presentation/home_page.dart';
import 'package:billing_baba/features/developer/models/developer_sub_route.dart';
import 'package:billing_baba/features/developer/presentation/developer_components_page.dart';
import 'package:billing_baba/features/developer/presentation/diagnostics_page.dart';
import 'package:billing_baba/features/developer/presentation/table_filters_playground_page.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/hidden_ledger_list_page.dart';
import 'package:billing_baba/features/inventory/presentation/add_items_barcode_screen.dart';
import 'package:billing_baba/features/inventory/presentation/categories_screen.dart';
import 'package:billing_baba/features/inventory/presentation/item_settings_screen.dart';
import 'package:billing_baba/features/inventory/presentation/item_details_screen.dart';
import 'package:billing_baba/features/inventory/presentation/items_page.dart';
import 'package:billing_baba/features/inventory/presentation/units_screen.dart';
import 'package:billing_baba/features/parties/presentation/party_details_page.dart';
import 'package:billing_baba/features/parties/presentation/party_groups_page.dart';
import 'package:billing_baba/features/plans_pricing/presentation/plans_pricing_page.dart';
import 'package:billing_baba/features/pos/presentation/pos_page.dart';
import 'package:billing_baba/features/purchases/presentation/add_debit_note_page.dart';
import 'package:billing_baba/features/purchases/presentation/add_expense_page.dart';
import 'package:billing_baba/features/purchases/presentation/add_purchase_fa_page.dart';
import 'package:billing_baba/features/purchases/presentation/add_purchase_order_page.dart';
import 'package:billing_baba/features/purchases/presentation/add_purchase_page.dart';
import 'package:billing_baba/features/purchases/presentation/expenses_page.dart';
import 'package:billing_baba/features/purchases/presentation/payment_out_page.dart';
import 'package:billing_baba/features/purchases/presentation/purchase_bills_page.dart';
import 'package:billing_baba/features/purchases/presentation/purchase_fa_page.dart';
import 'package:billing_baba/features/purchases/presentation/purchase_order_page.dart';
import 'package:billing_baba/features/purchases/presentation/purchase_return_page.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/stock_summary_mobile_filters.dart';
import 'package:billing_baba/features/reports/presentation/mobile/screens/mobile_item_detail_report_screen.dart';
import 'package:billing_baba/features/reports/presentation/mobile/screens/mobile_stock_summary_screen.dart';
import 'package:billing_baba/features/reports/presentation/reports_page.dart';
import 'package:billing_baba/features/sales/presentation/add_credit_note_page.dart';
import 'package:billing_baba/features/sales/presentation/add_delivery_challan_page.dart';
import 'package:billing_baba/features/sales/presentation/add_estimate_page.dart';
import 'package:billing_baba/features/sales/presentation/add_sale_fa_page.dart';
import 'package:billing_baba/features/sales/presentation/add_sale_order_page.dart';
import 'package:billing_baba/features/sales/presentation/add_sale_page.dart';
import 'package:billing_baba/features/sales/presentation/delivery_challan_page.dart';
import 'package:billing_baba/features/sales/presentation/estimate_quotation_page.dart';
import 'package:billing_baba/features/sales/presentation/job_work_out_page.dart';
import 'package:billing_baba/features/sales/presentation/payment_in_page.dart';
import 'package:billing_baba/features/sales/presentation/proforma_invoice_page.dart';
import 'package:billing_baba/features/sales/presentation/sale_fa_page.dart';
import 'package:billing_baba/features/sales/presentation/sale_invoices_page.dart';
import 'package:billing_baba/features/sales/presentation/sale_order_page.dart';
import 'package:billing_baba/features/sales/presentation/sale_return_page.dart';
import 'package:billing_baba/features/settings/presentation/print_settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/taxes_settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/transaction_messages_screen.dart';
import 'package:billing_baba/features/settings/presentation/whatsapp_settings_screen.dart';
import 'package:billing_baba/features/utilities/presentation/barcode_generator_page.dart';
import 'package:billing_baba/features/utilities/presentation/import_items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef AppShellBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

/// Shared GoRouter configuration used by desktop and mobile routers.
GoRouter createAppRouter({
  required Ref ref,
  required AppShellBuilder shellBuilder,
  String initialLocation = AppRoutes.splash,
  bool showSplash = true,
}) {
  ref.watch(companySessionBootstrapProvider);
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: RouterRefreshListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      final onSplash = location == AppRoutes.splash;
      final onLogin = location == AppRoutes.login;
      final onOtp = location == AppRoutes.verifyOtp;
      final onBusinessList = location == AppRoutes.businessList;

      if (auth.status == AuthStatus.initializing) {
        if (!showSplash) {
          // Mobile: no splash — stay on / go to login while auth boots.
          return onLogin ? null : AppRoutes.login;
        }
        return onSplash ? null : AppRoutes.splash;
      }

      if (onSplash) {
        // Mobile never keeps the splash route.
        if (!showSplash) {
          return switch (auth.status) {
            AuthStatus.authenticated => AppRoutes.home,
            AuthStatus.needsBusinessSelection ||
            AuthStatus.needsBusinessCreation =>
              AppRoutes.businessList,
            AuthStatus.otpSent => AppRoutes.verifyOtp,
            AuthStatus.unauthenticated || AuthStatus.initializing =>
              AppRoutes.login,
          };
        }
        return switch (auth.status) {
          AuthStatus.authenticated => AppRoutes.home,
          AuthStatus.needsBusinessSelection => AppRoutes.businessList,
          AuthStatus.needsBusinessCreation => AppRoutes.businessList,
          AuthStatus.otpSent => AppRoutes.verifyOtp,
          AuthStatus.unauthenticated ||
          AuthStatus.initializing => AppRoutes.login,
        };
      }

      switch (auth.status) {
        case AuthStatus.unauthenticated:
          if (!onLogin) return AppRoutes.login;
        case AuthStatus.otpSent:
          if (!onOtp) return AppRoutes.verifyOtp;
        case AuthStatus.needsBusinessCreation:
        case AuthStatus.needsBusinessSelection:
          if (!onBusinessList) {
            final hasActiveCompany = ref.read(companySessionProvider) != null;
            if (!hasActiveCompany) {
              SwitchCompanyDebugLog.nav(
                'GoRouter redirect $location → ${AppRoutes.businessList} '
                '(${auth.status.name})',
              );
              return AppRoutes.businessList;
            }
          }
        case AuthStatus.authenticated:
          if (onLogin || onOtp) return AppRoutes.home;
          final permission = ref.read(permissionServiceProvider);
          return PermissionGuard.redirect(location, permission);
        case AuthStatus.initializing:
          return showSplash ? AppRoutes.splash : AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) => const VerifyOtpPage(),
      ),
      GoRoute(
        path: AppRoutes.businessList,
        builder: (context, state) => const BusinessListPage(),
      ),
      GoRoute(
        path: AppRoutes.accessDenied,
        builder: (context, state) => AccessDeniedPage(
          fromRoute: state.uri.queryParameters['from'],
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => shellBuilder(context, state, child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.parties,
            redirect: (_, _) => AppRoutes.partyDetails,
          ),
          GoRoute(
            path: AppRoutes.partyDetails,
            builder: (context, state) => const PartyDetailsPage(),
          ),
          GoRoute(
            path: AppRoutes.partyGroups,
            builder: (context, state) => const PartyGroupsPage(),
          ),
          GoRoute(
            path: AppRoutes.partyHiddenLedger,
            builder: (context, state) => const HiddenLedgerListPage(),
          ),
          GoRoute(
            path: AppRoutes.crm,
            redirect: (_, _) => AppRoutes.crmLeads,
          ),
          GoRoute(
            path: AppRoutes.crmLeads,
            builder: (context, state) => const LeadsScreen(),
          ),
          GoRoute(
            path: AppRoutes.crmContacts,
            builder: (context, state) => const ContactsScreen(),
          ),
          GoRoute(
            path: AppRoutes.crmDeals,
            builder: (context, state) => const DealsScreen(),
          ),
          GoRoute(
            path: AppRoutes.items,
            builder: (context, state) => const ItemsPage(),
          ),
          GoRoute(
            path: '${AppRoutes.itemsDetail}/:itemId',
            name: 'itemDetails',
            builder: (context, state) => ItemDetailsScreen(
              itemId: state.pathParameters['itemId']!,
              fallbackItem: state.extra,
            ),
          ),
          GoRoute(
            path: AppRoutes.itemsCategories,
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: AppRoutes.itemsUnits,
            builder: (context, state) => const UnitsScreen(),
          ),
          GoRoute(
            path: AppRoutes.itemsGodowns,
            builder: (context, state) => const ComingSoonPage(title: 'Godowns'),
          ),
          GoRoute(
            path: AppRoutes.itemsStockTransfer,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Stock Transfer'),
          ),
          GoRoute(
            path: AppRoutes.itemsSettings,
            builder: (context, state) => const ItemSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.sale,
            redirect: (context, state) => AppRoutes.saleInvoices,
          ),
          GoRoute(
            path: AppRoutes.pos,
            builder: (context, state) => const PosPage(),
          ),
          GoRoute(
            path: AppRoutes.saleInvoices,
            builder: (context, state) => const SaleInvoicesPage(),
          ),
          GoRoute(
            path: AppRoutes.addSale,
            name: 'addSale',
            builder: (context, state) => AddSalePage(
              attachOrderIds: state.extra is List<String>
                  ? state.extra! as List<String>
                  : null,
            ),
          ),
          GoRoute(
            path: '${AppRoutes.editSale}/:invoiceId',
            name: 'editSale',
            builder: (context, state) => AddSalePage(
              invoiceId: state.pathParameters['invoiceId'],
            ),
          ),
          GoRoute(
            path: '${AppRoutes.viewSale}/:invoiceId',
            name: 'viewSale',
            builder: (context, state) => AddSalePage(
              invoiceId: state.pathParameters['invoiceId'],
              readOnly: true,
            ),
          ),
          GoRoute(
            path: AppRoutes.saleEstimateQuotation,
            builder: (context, state) => const EstimateQuotationPage(),
          ),
          GoRoute(
            path: AppRoutes.addEstimate,
            name: 'addEstimate',
            builder: (context, state) => const AddEstimatePage(),
          ),
          GoRoute(
            path: '${AppRoutes.duplicateEstimate}/:sourceId',
            name: 'duplicateEstimate',
            builder: (context, state) => AddEstimatePage(
              duplicateFromId: state.pathParameters['sourceId'],
            ),
          ),
          GoRoute(
            path: '${AppRoutes.editEstimate}/:estimateId',
            name: 'editEstimate',
            builder: (context, state) => AddEstimatePage(
              estimateId: state.pathParameters['estimateId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.saleProformaInvoice,
            builder: (context, state) => const ProformaInvoicePage(),
          ),
          GoRoute(
            path: AppRoutes.salePaymentIn,
            builder: (context, state) => const PaymentInPage(),
          ),
          GoRoute(
            path: AppRoutes.saleOrder,
            builder: (context, state) => const SaleOrderPage(),
          ),
          GoRoute(
            path: AppRoutes.addSaleOrder,
            name: 'addSaleOrder',
            builder: (context, state) => const AddSaleOrderPage(),
          ),
          GoRoute(
            path: '${AppRoutes.editSaleOrder}/:orderId',
            name: 'editSaleOrder',
            builder: (context, state) => AddSaleOrderPage(
              orderId: state.pathParameters['orderId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.saleDeliveryChallan,
            builder: (context, state) => const DeliveryChallanPage(),
          ),
          GoRoute(
            path: AppRoutes.addDeliveryChallan,
            name: 'addDeliveryChallan',
            builder: (context, state) => const AddDeliveryChallanPage(),
          ),
          GoRoute(
            path: '${AppRoutes.editDeliveryChallan}/:challanId',
            name: 'editDeliveryChallan',
            builder: (context, state) => AddDeliveryChallanPage(
              challanId: state.pathParameters['challanId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.saleJobWorkOut,
            builder: (context, state) => const JobWorkOutPage(),
          ),
          GoRoute(
            path: AppRoutes.saleReturnCreditNote,
            builder: (context, state) => const SaleReturnPage(),
          ),
          GoRoute(
            path: AppRoutes.saleFa,
            builder: (context, state) => const SaleFaPage(),
          ),
          GoRoute(
            path: AppRoutes.addSaleFa,
            name: 'addSaleFa',
            builder: (context, state) => const AddSaleFaPage(),
          ),
          GoRoute(
            path: '${AppRoutes.editSaleFa}/:batchId',
            name: 'editSaleFa',
            builder: (context, state) => AddSaleFaPage(
              batchId: state.pathParameters['batchId'],
            ),
          ),
          GoRoute(
            path: '${AppRoutes.duplicateSale}/:sourceId',
            name: 'duplicateSale',
            builder: (context, state) => AddSalePage(
              duplicateFromId: state.pathParameters['sourceId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.addCreditNote,
            name: 'addCreditNote',
            builder: (context, state) => AddCreditNotePage(
              fromInvoiceId: state.uri.queryParameters['fromInvoice'],
            ),
          ),
          GoRoute(
            path: '${AppRoutes.editCreditNote}/:creditNoteId',
            name: 'editCreditNote',
            builder: (context, state) => AddCreditNotePage(
              creditNoteId: state.pathParameters['creditNoteId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.purchase,
            redirect: (context, state) => AppRoutes.purchaseBills,
          ),
          GoRoute(
            path: AppRoutes.purchaseBills,
            builder: (context, state) => const PurchaseBillsPage(),
          ),
          GoRoute(
            path: AppRoutes.purchasePaymentOut,
            builder: (context, state) => const PaymentOutPage(),
          ),
          GoRoute(
            path: AppRoutes.purchaseExpenses,
            builder: (context, state) => const ExpensesPage(),
          ),
          GoRoute(
            path: AppRoutes.purchaseOrder,
            builder: (context, state) => const PurchaseOrderPage(),
          ),
          GoRoute(
            path: AppRoutes.purchaseReturnDebitNote,
            builder: (context, state) => const PurchaseReturnPage(),
          ),
          GoRoute(
            path: AppRoutes.addDebitNote,
            name: 'addDebitNote',
            builder: (context, state) => const AddDebitNotePage(),
          ),
          GoRoute(
            path: '${AppRoutes.editDebitNote}/:debitNoteId',
            name: 'editDebitNote',
            builder: (context, state) => AddDebitNotePage(
              debitNoteId: state.pathParameters['debitNoteId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.purchaseFa,
            builder: (context, state) => const PurchaseFaPage(),
          ),
          GoRoute(
            path: AppRoutes.addPurchaseFa,
            name: 'addPurchaseFa',
            builder: (context, state) => const AddPurchaseFaPage(),
          ),
          GoRoute(
            path: '${AppRoutes.editPurchaseFa}/:batchId',
            name: 'editPurchaseFa',
            builder: (context, state) => AddPurchaseFaPage(
              batchId: state.pathParameters['batchId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.addPurchase,
            name: 'addPurchase',
            builder: (context, state) => const AddPurchasePage(),
          ),
          GoRoute(
            path: '${AppRoutes.editPurchase}/:billId',
            name: 'editPurchase',
            builder: (context, state) => AddPurchasePage(
              billId: state.pathParameters['billId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.addPurchaseOrder,
            name: 'addPurchaseOrder',
            builder: (context, state) => const AddPurchaseOrderPage(),
          ),
          GoRoute(
            path: '${AppRoutes.editPurchaseOrder}/:orderId',
            name: 'editPurchaseOrder',
            builder: (context, state) => AddPurchaseOrderPage(
              orderId: state.pathParameters['orderId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.addExpense,
            name: 'addExpense',
            builder: (context, state) => const AddExpensePage(),
          ),
          GoRoute(
            path: '${AppRoutes.editExpense}/:expenseId',
            name: 'editExpense',
            builder: (context, state) => AddExpensePage(
              expenseId: state.pathParameters['expenseId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsDashboard,
            redirect: (context, state) => AppRoutes.reports,
          ),
          GoRoute(
            path: AppRoutes.reportsSales,
            redirect: (context, state) => AppRoutes.reports,
          ),
          GoRoute(
            path: AppRoutes.reportsPurchase,
            redirect: (context, state) => AppRoutes.reports,
          ),
          GoRoute(
            path: AppRoutes.reportsStock,
            redirect: (context, state) => AppRoutes.reportsStockSummary,
          ),
          GoRoute(
            path: AppRoutes.reportsStockSummary,
            builder: (context, state) => MobileStockSummaryScreen(
              initialStockFilter: StockSummaryMobileFilters.stockFilterFromQuery(
                state.uri.queryParameters['stock'],
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.reportsItemDetail,
            builder: (context, state) => const MobileItemDetailReportScreen(),
          ),
          GoRoute(
            path: AppRoutes.reportsParty,
            redirect: (context, state) => AppRoutes.reports,
          ),
          GoRoute(
            path: AppRoutes.reportsGst,
            redirect: (context, state) => AppRoutes.reports,
          ),
          GoRoute(
            path: AppRoutes.collaboration,
            redirect: (_, _) => AppRoutes.collaborationSyncShare,
          ),
          GoRoute(
            path: AppRoutes.collaborationSyncShare,
            builder: (context, state) => const SyncSharePage(),
          ),
          GoRoute(
            path: AppRoutes.utilities,
            redirect: (_, _) => AppRoutes.utilitiesImportItems,
          ),
          GoRoute(
            path: AppRoutes.utilitiesImportItems,
            builder: (context, state) => const ImportItemsPage(),
          ),
          GoRoute(
            path: AppRoutes.utilitiesAddItemsBarcode,
            builder: (context, state) => const AddItemsBarcodeScreen(),
          ),
          GoRoute(
            path: AppRoutes.utilitiesBarcodeGenerator,
            builder: (context, state) => const BarcodeGeneratorPage(),
          ),
          GoRoute(
            path: AppRoutes.developer,
            redirect: (_, _) => AppRoutes.developerComponents,
          ),
          GoRoute(
            path: AppRoutes.developerComponents,
            builder: (context, state) => const DeveloperComponentsPage(),
          ),
          GoRoute(
            path: AppRoutes.developerComponentsTableFilters,
            builder: (context, state) => const TableFiltersPlaygroundPage(),
          ),
          GoRoute(
            path: AppRoutes.developerDiagnostics,
            builder: (context, state) => const DiagnosticsPage(),
          ),
          for (final item in DeveloperSubRoutes.items)
            if (item.route != AppRoutes.developerComponentsTableFilters)
              GoRoute(
                path: item.route,
                builder: (context, state) => DeveloperComponentPlaceholderPage(
                  title: item.label,
                ),
              ),
          GoRoute(
            path: AppRoutes.settings,
            redirect: (context, state) => AppRoutes.settingsPreferences,
          ),
          GoRoute(
            path: AppRoutes.settingsUsers,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Users & Roles'),
          ),
          GoRoute(
            path: AppRoutes.settingsTaxes,
            builder: (context, state) => const TaxesSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsInvoiceTemplates,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Invoice Templates'),
          ),
          GoRoute(
            path: AppRoutes.settingsPreferences,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsPrint,
            builder: (context, state) => const PrintSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsWhatsapp,
            builder: (context, state) => const WhatsAppSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsTransactionMessages,
            builder: (context, state) => const TransactionMessagesScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsBackup,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Backup & Restore'),
          ),
          GoRoute(
            path: AppRoutes.plansPricing,
            builder: (context, state) => const PlansPricingPage(),
          ),
          GoRoute(
            path: AppRoutes.editProfile,
            builder: (context, state) => const EditProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.userProfile,
            builder: (context, state) => const UserProfilePage(),
          ),
        ],
      ),
    ],
  );
}

/// Bridges Riverpod auth and company session changes into a [Listenable].
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    ref..listen<AuthState>(authProvider, (_, _) => notifyListeners())
    ..listen<CompanySession?>(companySessionProvider, (_, _) {
      notifyListeners();
    });
  }
}
