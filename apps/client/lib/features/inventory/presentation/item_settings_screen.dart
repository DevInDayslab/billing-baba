import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/screens/item_settings_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_settings_screen.dart';
import 'package:flutter/widgets.dart';

class ItemSettingsScreen extends StatelessWidget {
  const ItemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopItemSettingsScreen(),
      mobile: MobileItemSettingsScreen(),
    );
  }
}
