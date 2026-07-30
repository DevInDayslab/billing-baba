import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_fa_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_fa_summary_card.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_fa_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_page_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopSaleFaPage extends ConsumerWidget {
  const DesktopSaleFaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 768
              ? AppSpacing.md
              : AppSpacing.lg;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSpacing.md,
              horizontalPadding,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SalePageTitleBar(
                  currentRoute: AppRoutes.saleFa,
                ),
                const SizedBox(height: AppSpacing.md),
                const SaleFaFilterBar(),
                const SizedBox(height: AppSpacing.md),
                const SaleFaSummaryCard(),
                const SizedBox(height: AppSpacing.md),
                const SaleFaTable(),
              ],
            ),
          );
        },
      ),
    );
  }
}
