import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/party_details_page.dart';
import './mobile/party_details_page.dart';
import 'package:flutter/widgets.dart';

class PartyDetailsPage extends StatelessWidget {
  const PartyDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPartyDetailsPage(),
      mobile: const MobilePartyDetailsPage(),
    );
  }
}
