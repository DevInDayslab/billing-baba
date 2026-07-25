import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/purchase_return_page.dart';
import './mobile/purchase_return_page.dart';
import 'package:flutter/widgets.dart';

class PurchaseReturnPage extends StatelessWidget {
  const PurchaseReturnPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPurchaseReturnPage(),
      mobile: const MobilePurchaseReturnPage(),
    );
  }
}
