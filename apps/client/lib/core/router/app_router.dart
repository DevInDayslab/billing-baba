import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/auth/presentation/pages/splash_page.dart';
import 'package:billing_baba/features/business/presentation/pages/business_list_page.dart';
import 'package:billing_baba/features/business/presentation/pages/edit_profile_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/home_page.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
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
            builder: (context, state) => _placeholderPage('Sale'),
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
