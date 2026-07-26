import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/purchase_bills_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/purchase_bills_page.dart';
import 'package:flutter/widgets.dart';

class PurchaseBillsPage extends StatelessWidget {
  const PurchaseBillsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPurchaseBillsPage(),
      mobile: MobilePurchaseBillsPage(),
    );
  }
}
