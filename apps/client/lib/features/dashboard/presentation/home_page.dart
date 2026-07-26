import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/home_page.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/home_page.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopHomePage(),
      mobile: MobileHomePage(),
    );
  }
}
