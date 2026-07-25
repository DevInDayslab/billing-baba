import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/coming_soon_page.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/coming_soon_page.dart';
import 'package:flutter/widgets.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    required this.title, super.key,
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
