import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/other_products/presentation/desktop/desktop_other_products_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class OtherProductsPage extends StatelessWidget {
  const OtherProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopOtherProductsPage(),
      mobile: DesktopOtherProductsPage(),
    );
  }
}

/// Square launcher tile for an product under Other Products.
class OtherProductLauncherTile extends StatelessWidget {
  const OtherProductLauncherTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  static const double size = 132;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE8EAED)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.primary.withValues(alpha: 0.06),
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
