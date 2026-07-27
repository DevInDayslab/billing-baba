import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/dashboard/presentation/coming_soon_page.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_categories_screen.dart';
import 'package:flutter/widgets.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: ComingSoonPage(title: 'Categories'),
      mobile: MobileCategoriesScreen(),
    );
  }
}
