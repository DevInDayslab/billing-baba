import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Billing Baba'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.businessSelection),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
