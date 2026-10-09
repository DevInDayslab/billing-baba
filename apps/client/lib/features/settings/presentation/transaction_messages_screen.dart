import 'package:billing_baba/features/settings/presentation/desktop/transaction_messages_screen.dart';
import 'package:billing_baba/features/settings/presentation/mobile/transaction_messages_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class TransactionMessagesScreen extends StatelessWidget {
  const TransactionMessagesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      // Same body as the legacy Settings → Transaction Messages tab.
      desktop: DesktopTransactionMessagesScreen(embedded: true),
      mobile: MobileTransactionMessagesScreen(),
    );
  }
}
