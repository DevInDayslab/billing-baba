import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/auth/presentation/pages/login_page.dart';
import 'package:billing_baba/features/auth/presentation/pages/splash_page.dart';
import 'package:billing_baba/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/presentation/pages/business_list_page.dart';
import 'package:billing_baba/features/business/presentation/pages/edit_profile_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/home_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/shell_page.dart';
import 'package:billing_baba/features/plans_pricing/presentation/pages/plans_pricing_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_sale_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/payment_in_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_invoices_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/estimate_quotation_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/proforma_invoice_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/delivery_challan_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/job_work_out_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/sale_order_page.dart';
import 'package:billing_baba/features/sales/presentation/pages/add_credit_note_page.dart';
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

      if (onSplash) return null;

      switch (auth.status) {
        case AuthStatus.unauthenticated:
          if (!onLogin) return AppRoutes.login;
        case AuthStatus.otpSent:
          if (!onOtp) return AppRoutes.verifyOtp;
        case AuthStatus.authenticated:
          if (onLogin || onOtp) return AppRoutes.home;
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
            builder: (context, state) => _placeholderPage('Parties'),
          ),
          GoRoute(
            path: AppRoutes.items,
            builder: (context, state) => _placeholderPage('Items'),
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
            path: AppRoutes.reports,
            builder: (context, state) => _placeholderPage('Reports'),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => _placeholderPage('Settings'),
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

Widget _placeholderPage(String title) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(child: Text(title)),
  );
}

/// Bridges Riverpod auth state changes into a [Listenable] for GoRouter.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}
