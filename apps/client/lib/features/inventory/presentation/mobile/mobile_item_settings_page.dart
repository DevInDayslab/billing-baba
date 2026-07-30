import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_settings_screen.dart';
import 'package:flutter/material.dart';

/// Entry point kept for callers that still reference [MobileItemSettingsPage].
///
/// Canonical implementation lives in [MobileItemSettingsScreen], which uses the
/// shared [ItemSettings] provider/repository.
class MobileItemSettingsPage extends StatelessWidget {
  const MobileItemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileItemSettingsScreen();
  }
}
