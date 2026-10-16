import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/other_products/models/other_product_sub_route.dart';
import 'package:billing_baba/features/other_products/presentation/other_products_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _crmAccent = Color(0xFF38BDF8);
const _accountsAccent = Color(0xFF6366F1);

class DesktopOtherProductsPage extends StatelessWidget {
  const DesktopOtherProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Other Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                OtherProductLauncherTile(
                  label: 'CRM',
                  icon: LucideIcons.heartHandshake,
                  iconColor: _crmAccent,
                  onTap: () => context.go(AppRoutes.crm),
                ),
                for (final item in OtherProductSubRoutes.items)
                  OtherProductLauncherTile(
                    label: item.label,
                    icon: LucideIcons.wallet,
                    iconColor: _accountsAccent,
                    onTap: () => context.go(item.route),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
