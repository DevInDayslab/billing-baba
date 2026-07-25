import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/pos_sales_history_page.dart';
import './mobile/pos_sales_history_page.dart';
import 'package:flutter/widgets.dart';

class PosSalesHistoryPage extends StatelessWidget {
  const PosSalesHistoryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPosSalesHistoryPage(),
      mobile: const MobilePosSalesHistoryPage(),
    );
  }
}
