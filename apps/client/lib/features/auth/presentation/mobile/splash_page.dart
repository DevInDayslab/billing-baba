import 'package:billing_baba/features/auth/presentation/desktop/splash_page.dart';
import 'package:flutter/widgets.dart';

/// Mobile startup splash — same branded splash as desktop.
///
/// Shown as the mobile router [initialLocation] (`/`) while auth initializes
/// (minimum duration enforced by [AuthNotifier.tryAutoLogin]).
class MobileSplashPage extends StatelessWidget {
  const MobileSplashPage({super.key});

  @override
  Widget build(BuildContext context) => const DesktopSplashPage();
}
