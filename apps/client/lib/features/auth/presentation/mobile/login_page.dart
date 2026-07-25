import 'package:billing_baba/features/auth/presentation/desktop/login_page.dart';
import 'package:flutter/widgets.dart';

/// Reuses the existing login UI and auth providers on mobile.
class MobileLoginPage extends StatelessWidget {
  const MobileLoginPage({super.key});

  @override
  Widget build(BuildContext context) => const DesktopLoginPage();
}
