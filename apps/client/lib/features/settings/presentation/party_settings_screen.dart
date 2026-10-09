import 'package:billing_baba/features/settings/presentation/desktop/desktop_party_settings_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class PartySettingsScreen extends StatelessWidget {
  const PartySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPartySettingsScreen(),
      mobile: DesktopPartySettingsScreen(),
    );
  }
}
