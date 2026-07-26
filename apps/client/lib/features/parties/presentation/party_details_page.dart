import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/parties/presentation/desktop/party_details_page.dart';
import 'package:billing_baba/features/parties/presentation/mobile/party_details_page.dart';
import 'package:flutter/widgets.dart';

class PartyDetailsPage extends StatelessWidget {
  const PartyDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPartyDetailsPage(),
      mobile: MobilePartyDetailsPage(),
    );
  }
}
