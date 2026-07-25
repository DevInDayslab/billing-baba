import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/purchase_bills_page.dart';
import './mobile/purchase_bills_page.dart';
import 'package:flutter/widgets.dart';

class PurchaseBillsPage extends StatelessWidget {
  const PurchaseBillsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPurchaseBillsPage(),
      mobile: const MobilePurchaseBillsPage(),
    );
  }
}
