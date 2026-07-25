import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/transaction_messages_screen.dart';
import './mobile/transaction_messages_screen.dart';
import 'package:flutter/widgets.dart';

class TransactionMessagesScreen extends StatelessWidget {
  const TransactionMessagesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopTransactionMessagesScreen(),
      mobile: const MobileTransactionMessagesScreen(),
    );
  }
}
