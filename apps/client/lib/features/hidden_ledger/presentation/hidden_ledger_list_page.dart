import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/hidden_ledger_list_page.dart';
import './mobile/hidden_ledger_list_page.dart';
import 'package:flutter/widgets.dart';

class HiddenLedgerListPage extends StatelessWidget {
  const HiddenLedgerListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopHiddenLedgerListPage(),
      mobile: const MobileHiddenLedgerListPage(),
    );
  }
}
