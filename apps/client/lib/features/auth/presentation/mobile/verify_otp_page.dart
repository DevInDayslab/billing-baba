import 'package:billing_baba/features/auth/presentation/desktop/verify_otp_page.dart';
import 'package:flutter/widgets.dart';

/// Reuses the existing OTP verification UI and auth providers on mobile.
class MobileVerifyOtpPage extends StatelessWidget {
  const MobileVerifyOtpPage({super.key});

  @override
  Widget build(BuildContext context) => const DesktopVerifyOtpPage();
}
