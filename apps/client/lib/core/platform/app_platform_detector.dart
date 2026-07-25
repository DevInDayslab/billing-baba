import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/platform/app_platform_detector_stub.dart'
    if (dart.library.io) 'package:billing_baba/core/platform/app_platform_detector_io.dart'
    as impl;

/// Native OS detection. On web this is unused ([AppPlatform] uses
/// [defaultTargetPlatform] instead).
OperatingSystem detectNativeOperatingSystem() =>
    impl.detectNativeOperatingSystem();
