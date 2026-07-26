import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/delivery_challan_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/delivery_challan_page.dart';
import 'package:flutter/widgets.dart';

class DeliveryChallanPage extends StatelessWidget {
  const DeliveryChallanPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopDeliveryChallanPage(),
      mobile: MobileDeliveryChallanPage(),
    );
  }
}
