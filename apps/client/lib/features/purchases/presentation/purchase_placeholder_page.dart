import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/purchase_placeholder_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/purchase_placeholder_page.dart';
import 'package:flutter/widgets.dart';

class PurchasePlaceholderPage extends StatelessWidget {
  const PurchasePlaceholderPage({
    required this.title, required this.route, super.key,
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
