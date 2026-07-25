import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/sale_placeholder_page.dart';
import './mobile/sale_placeholder_page.dart';
import 'package:flutter/widgets.dart';

class SalePlaceholderPage extends StatelessWidget {
  const SalePlaceholderPage({
    super.key,
    required this.title,
    required this.route,
  });

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopSalePlaceholderPage(title: title, route: route),
      mobile: MobileSalePlaceholderPage(title: title, route: route),
    );
  }
}
