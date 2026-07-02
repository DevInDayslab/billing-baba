import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/auth/presentation/pages/login_page.dart';
import 'package:billing_baba/features/auth/presentation/pages/splash_page.dart';
import 'package:billing_baba/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/presentation/pages/business_list_page.dart';
import 'package:billing_baba/features/business/presentation/pages/edit_profile_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/coming_soon_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/home_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/shell_page.dart';
import 'package:billing_baba/features/inventory/presentation/pages/items_page.dart';
import 'package:billing_baba/features/plans_pricing/presentation/pages/plans_pricing_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_credit_note_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_sale_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/delivery_challan_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/estimate_quotation_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/job_work_out_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/payment_in_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/proforma_invoice_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_invoices_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_order_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_return_page.dart';
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
          AuthStatus.unauthenticated || AuthStatus.initializing =>
            AppRoutes.login,
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
            redirect: (context, state) => AppRoutes.partiesCustomers,
          ),
          GoRoute(
            path: AppRoutes.partiesCustomers,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Customers'),
          ),
          GoRoute(
            path: AppRoutes.partiesSuppliers,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Suppliers'),
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
            path: AppRoutes.saleInvoices,
            builder: (context, state) => const SaleInvoicesPage(),
          ),
          GoRoute(
            path: AppRoutes.addSale,
            name: 'addSale',
            builder: (context, state) => const AddSalePage(),
          ),
          GoRoute(
            path: '${AppRoutes.editSale}/:invoiceId',
            name: 'editSale',
            builder: (context, state) => AddSalePage(
              invoiceId: state.pathParameters['invoiceId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.saleEstimateQuotation,
            builder: (context, state) => const EstimateQuotationPage(),
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
            path: AppRoutes.saleDeliveryChallan,
            builder: (context, state) => const DeliveryChallanPage(),
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
            path: AppRoutes.addCreditNote,
            name: 'addCreditNote',
            builder: (context, state) => const AddCreditNotePage(),
          ),
          GoRoute(
            path: AppRoutes.purchase,
            builder: (context, state) => const ComingSoonPage(title: 'Purchase'),
          ),
          GoRoute(
            path: AppRoutes.purchaseReturn,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Purchase Return'),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            builder: (context, state) => const ComingSoonPage(title: 'Expenses'),
          ),
          GoRoute(
            path: AppRoutes.debitNote,
            builder: (context, state) => const ComingSoonPage(title: 'Debit Note'),
          ),
          GoRoute(
            path: AppRoutes.reports,
            redirect: (context, state) => AppRoutes.reportsDashboard,
          ),
          GoRoute(
            path: AppRoutes.reportsDashboard,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Reports Dashboard'),
          ),
          GoRoute(
            path: AppRoutes.reportsSales,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Sales Reports'),
          ),
          GoRoute(
            path: AppRoutes.reportsPurchase,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Purchase Reports'),
          ),
          GoRoute(
            path: AppRoutes.reportsStock,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Stock Reports'),
          ),
          GoRoute(
            path: AppRoutes.reportsParty,
            builder: (context, state) =>
                const ComingSoonPage(title: 'Party Reports'),
          ),
          GoRoute(
            path: AppRoutes.reportsGst,
            builder: (context, state) =>
                const ComingSoonPage(title: 'GST Reports'),
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
