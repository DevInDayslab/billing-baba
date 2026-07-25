import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/edit_profile_page.dart';
import './mobile/edit_profile_page.dart';
import 'package:flutter/widgets.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopEditProfilePage(),
      mobile: const MobileEditProfilePage(),
    );
  }
}
