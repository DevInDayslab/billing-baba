import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/parties/presentation/desktop/party_groups_page.dart';
import 'package:billing_baba/features/parties/presentation/mobile/party_groups_page.dart';
import 'package:flutter/widgets.dart';

class PartyGroupsPage extends StatelessWidget {
  const PartyGroupsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPartyGroupsPage(),
      mobile: MobilePartyGroupsPage(),
    );
  }
}
