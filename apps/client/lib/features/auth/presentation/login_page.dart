import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/auth/presentation/desktop/login_page.dart';
import 'package:billing_baba/features/auth/presentation/mobile/login_page.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopLoginPage(),
      mobile: MobileLoginPage(),
    );
  }
}
