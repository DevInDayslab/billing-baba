import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _addSaleRed = Color(0xFFE53935);

class SaleReportTitleBar extends StatelessWidget {
  const SaleReportTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Sale Report',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.addSale),
          style: FilledButton.styleFrom(
            backgroundColor: _addSaleRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Sale',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textSecondary,
          tooltip: 'Settings',
        ),
      ],
    );
  }
}
