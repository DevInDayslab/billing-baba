import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/purchase_fa_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/purchase_fa_page.dart';
import 'package:flutter/widgets.dart';

class PurchaseFaPage extends StatelessWidget {
  const PurchaseFaPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPurchaseFaPage(),
      mobile: MobilePurchaseFaPage(),
    );
  }
}
