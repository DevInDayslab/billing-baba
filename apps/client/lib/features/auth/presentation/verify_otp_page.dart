import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/auth/presentation/desktop/verify_otp_page.dart';
import 'package:billing_baba/features/auth/presentation/mobile/verify_otp_page.dart';
import 'package:flutter/widgets.dart';

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopVerifyOtpPage(),
      mobile: MobileVerifyOtpPage(),
    );
  }
}
