import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/brands_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_brands_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: BrandsTabContent(),
        ),
      ),
      mobile: MobileBrandsScreen(),
    );
  }
}
