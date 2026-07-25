import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/home_page.dart';
import './mobile/home_page.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopHomePage(),
      mobile: const MobileHomePage(),
    );
  }
}
