import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/verify_otp_page.dart';
import './mobile/verify_otp_page.dart';
import 'package:flutter/widgets.dart';

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopVerifyOtpPage(),
      mobile: const MobileVerifyOtpPage(),
    );
  }
}
