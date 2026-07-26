import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/hidden_ledger_list_page.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/mobile/hidden_ledger_list_page.dart';
import 'package:flutter/widgets.dart';

class HiddenLedgerListPage extends StatelessWidget {
  const HiddenLedgerListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopHiddenLedgerListPage(),
      mobile: MobileHiddenLedgerListPage(),
    );
  }
}
