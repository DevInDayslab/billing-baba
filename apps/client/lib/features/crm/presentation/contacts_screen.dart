import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/crm/presentation/desktop/contacts_screen.dart';
import 'package:billing_baba/features/crm/presentation/mobile/contacts_screen.dart';
import 'package:flutter/widgets.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopContactsScreen(),
      mobile: MobileContactsScreen(),
    );
  }
}
