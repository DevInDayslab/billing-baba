import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/party_groups_page.dart';
import './mobile/party_groups_page.dart';
import 'package:flutter/widgets.dart';

class PartyGroupsPage extends StatelessWidget {
  const PartyGroupsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPartyGroupsPage(),
      mobile: const MobilePartyGroupsPage(),
    );
  }
}
