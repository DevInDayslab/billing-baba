import 'package:billing_baba/features/dashboard/presentation/coming_soon_page.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_brands_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: ComingSoonPage(title: 'Brands'),
      mobile: MobileBrandsScreen(),
    );
  }
}
