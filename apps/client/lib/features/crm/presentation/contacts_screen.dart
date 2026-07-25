import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/contacts_screen.dart';
import './mobile/contacts_screen.dart';
import 'package:flutter/widgets.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopContactsScreen(),
      mobile: const MobileContactsScreen(),
    );
  }
}
