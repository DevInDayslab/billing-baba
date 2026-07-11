import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/job_work_out_dialog.dart';
import 'package:billing_baba/features/sales/presentation/widgets/job_work_out_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/providers/job_work_orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobWorkOutPage extends ConsumerWidget {
  const JobWorkOutPage({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref) async {
    final saved = await showJobWorkOutDialog(context);
    if (saved == true) {
      await ref.read(jobWorkOrdersListProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SalePageTitleBar(
              currentRoute: AppRoutes.saleJobWorkOut,
              addButtonLabel: 'Job Work Out',
              addButtonColor: AppColors.error,
              onAddTap: () => _openForm(context, ref),
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            const JobWorkOutTable(),
          ],
        ),
      ),
    );
  }
}
