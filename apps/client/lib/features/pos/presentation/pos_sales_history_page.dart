import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/pos/presentation/desktop/pos_sales_history_page.dart';
import 'package:billing_baba/features/pos/presentation/mobile/pos_sales_history_page.dart';
import 'package:flutter/widgets.dart';

class PosSalesHistoryPage extends StatelessWidget {
  const PosSalesHistoryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPosSalesHistoryPage(),
      mobile: MobilePosSalesHistoryPage(),
    );
  }
}
