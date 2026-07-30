import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_items_screen.dart';
import 'package:flutter/material.dart';

/// Mobile Items tab entry — routed via [AdaptivePage] on `/items`.
class MobileItemsPage extends StatelessWidget {
  const MobileItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileItemsScreen();
  }
}
