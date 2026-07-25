import 'package:billing_baba/features/business/presentation/desktop/business_list_page.dart';
import 'package:flutter/widgets.dart';

/// Reuses the existing company-selection UI on mobile so post-OTP navigation
/// can complete into [MobileShell] without a separate auth/business flow.
class MobileBusinessListPage extends StatelessWidget {
  const MobileBusinessListPage({super.key});

  @override
  Widget build(BuildContext context) => const DesktopBusinessListPage();
}
