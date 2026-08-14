import 'package:billing_baba/features/dashboard/presentation/coming_soon_page.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_godowns_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class GodownsScreen extends StatelessWidget {
  const GodownsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: ComingSoonPage(title: 'Godowns'),
      mobile: MobileGodownsScreen(),
    );
  }
}
