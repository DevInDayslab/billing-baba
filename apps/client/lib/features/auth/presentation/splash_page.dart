import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/splash_page.dart';
import './mobile/splash_page.dart';
import 'package:flutter/widgets.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopSplashPage(),
      mobile: const MobileSplashPage(),
    );
  }
}
