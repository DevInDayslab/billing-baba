import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/purchase_placeholder_page.dart';
import './mobile/purchase_placeholder_page.dart';
import 'package:flutter/widgets.dart';

class PurchasePlaceholderPage extends StatelessWidget {
  const PurchasePlaceholderPage({
    super.key,
    required this.title,
    required this.route,
  });

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopPurchasePlaceholderPage(title: title, route: route),
      mobile: MobilePurchasePlaceholderPage(title: title, route: route),
    );
  }
}
