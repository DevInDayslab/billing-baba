import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/purchase_fa_page.dart';
import './mobile/purchase_fa_page.dart';
import 'package:flutter/widgets.dart';

class PurchaseFaPage extends StatelessWidget {
  const PurchaseFaPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPurchaseFaPage(),
      mobile: const MobilePurchaseFaPage(),
    );
  }
}
