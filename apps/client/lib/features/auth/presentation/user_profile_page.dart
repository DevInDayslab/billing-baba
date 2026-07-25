import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/user_profile_page.dart';
import './mobile/user_profile_page.dart';
import 'package:flutter/widgets.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopUserProfilePage(),
      mobile: const MobileUserProfilePage(),
    );
  }
}
