import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/sale_placeholder_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/sale_placeholder_page.dart';
import 'package:flutter/widgets.dart';

class SalePlaceholderPage extends StatelessWidget {
  const SalePlaceholderPage({
    required this.title, required this.route, super.key,
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
