import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/auth/presentation/pages/login_page.dart';
import 'package:billing_baba/features/auth/presentation/pages/splash_page.dart';
import 'package:billing_baba/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/presentation/pages/business_list_page.dart';
import 'package:billing_baba/features/business/presentation/pages/edit_profile_page.dart';
import 'package:billing_baba/features/developer/models/developer_sub_route.dart';
import 'package:billing_baba/features/developer/presentation/pages/developer_components_page.dart';
import 'package:billing_baba/features/developer/presentation/pages/table_filters_playground_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/coming_soon_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/home_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/shell_page.dart';
import 'package:billing_baba/features/inventory/presentation/pages/items_page.dart';
import 'package:billing_baba/features/parties/presentation/pages/party_details_page.dart';
import 'package:billing_baba/features/plans_pricing/presentation/pages/plans_pricing_page.dart';
import 'package:billing_baba/features/pos/presentation/pages/pos_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/add_debit_note_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/add_expense_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/add_purchase_fa_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/add_purchase_order_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/add_purchase_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/expenses_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/payment_out_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/purchase_bills_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/purchase_fa_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/purchase_order_page.dart';
import 'package:billing_baba/features/purchases/presentation/pages/purchase_return_page.dart';
import 'package:billing_baba/features/reports/presentation/pages/reports_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_credit_note_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_estimate_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_sale_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_delivery_challan_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/delivery_challan_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/estimate_quotation_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/job_work_out_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/payment_in_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/proforma_invoice_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_invoices_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_sale_order_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_order_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_sale_fa_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_fa_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_return_page.dart';
import 'package:billing_baba/features/utilities/presentation/pages/import_items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      final onSplash = location == AppRoutes.splash;
      final onLogin = location == AppRoutes.login;
      final onOtp = location == AppRoutes.verifyOtp;
      final onBusinessList = location == AppRoutes.businessList;

      if (auth.status == AuthStatus.initializing) {
        return onSplash ? null : AppRoutes.splash;
      }

      if (onSplash) {
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
          if (!onBusinessList) return AppRoutes.businessList;
        case AuthStatus.authenticated:
          if (onLogin || onOtp) return AppRoutes.home;
        case AuthStatus.initializing:
          return AppRoutes.splash;
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
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
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
            path: AppRoutes.items,
            builder: (context, state) => const ItemsPage(),
          ),
          GoRoute(
            path: AppRoutes.itemsCategories,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Categories'),
          ),
          GoRoute(
            path: AppRoutes.itemsUnits,
            builder: (context, state) => const ComingSoonPage(title: 'Units'),
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
            redirect: (context, state) => AppRoutes.reports,
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
            path: AppRoutes.utilities,
            redirect: (_, _) => AppRoutes.utilitiesImportItems,
          ),
          GoRoute(
            path: AppRoutes.utilitiesImportItems,
            builder: (context, state) => const ImportItemsPage(),
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
            builder: (context, state) => const ComingSoonPage(title: 'Taxes'),
          ),
          GoRoute(
            path: AppRoutes.settingsInvoiceTemplates,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Invoice Templates'),
          ),
          GoRoute(
            path: AppRoutes.settingsPreferences,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Preferences'),
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
        ],
      ),
    ],
  );
});

/// Bridges Riverpod auth state changes into a [Listenable] for GoRouter.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}
