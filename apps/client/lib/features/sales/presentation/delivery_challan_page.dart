import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/delivery_challan_page.dart';
import './mobile/delivery_challan_page.dart';
import 'package:flutter/widgets.dart';

class DeliveryChallanPage extends StatelessWidget {
  const DeliveryChallanPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopDeliveryChallanPage(),
      mobile: const MobileDeliveryChallanPage(),
    );
  }
}
