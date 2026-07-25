import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/coming_soon_page.dart';
import './mobile/coming_soon_page.dart';
import 'package:flutter/widgets.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopComingSoonPage(title: title),
      mobile: MobileComingSoonPage(title: title),
    );
  }
}
