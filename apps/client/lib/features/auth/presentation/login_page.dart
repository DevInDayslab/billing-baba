import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/login_page.dart';
import './mobile/login_page.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopLoginPage(),
      mobile: const MobileLoginPage(),
    );
  }
}
