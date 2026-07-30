import 'package:billing_baba/features/auth/presentation/desktop/user_profile_page.dart';
import 'package:billing_baba/features/auth/presentation/mobile/user_profile_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopUserProfilePage(),
      mobile: MobileUserProfilePage(),
    );
  }
}
