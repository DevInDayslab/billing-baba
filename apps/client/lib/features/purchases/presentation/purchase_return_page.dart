import 'package:billing_baba/features/purchases/presentation/desktop/purchase_return_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/purchase_return_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class PurchaseReturnPage extends StatelessWidget {
  const PurchaseReturnPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPurchaseReturnPage(),
      mobile: MobilePurchaseReturnPage(),
    );
  }
}
