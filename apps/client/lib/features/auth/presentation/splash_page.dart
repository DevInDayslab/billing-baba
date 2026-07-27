import 'package:billing_baba/features/auth/presentation/desktop/splash_page.dart';
import 'package:billing_baba/features/auth/presentation/mobile/splash_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopSplashPage(),
      mobile: MobileSplashPage(),
    );
  }
}
