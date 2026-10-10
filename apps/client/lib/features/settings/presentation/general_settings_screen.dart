import 'package:billing_baba/features/settings/presentation/desktop/desktop_general_settings_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopGeneralSettingsScreen(),
      mobile: DesktopGeneralSettingsScreen(),
    );
  }
}
