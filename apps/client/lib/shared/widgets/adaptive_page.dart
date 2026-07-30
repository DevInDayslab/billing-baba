import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:flutter/widgets.dart';

/// Chooses [desktop] or [mobile] from [AppPlatform.family].
class AdaptivePage extends StatelessWidget {
  const AdaptivePage({
    required this.desktop,
    required this.mobile,
    super.key,
  });

  final Widget desktop;
  final Widget mobile;

  @override
  Widget build(BuildContext context) {
    return AppPlatform.current.isDesktop ? desktop : mobile;
  }
}
