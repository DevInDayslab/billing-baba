import 'package:billing_baba/features/business/presentation/desktop/edit_profile_page.dart';
import 'package:billing_baba/features/business/presentation/mobile/edit_profile_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopEditProfilePage(),
      mobile: MobileEditProfilePage(),
    );
  }
}
