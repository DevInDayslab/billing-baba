import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/features/plans_pricing/application/plans_pricing_license_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void openMobileLicenseInfoPage(
  BuildContext context, {
  MobileLicenseInfoSection section = MobileLicenseInfoSection.none,
}) {
  final uri = Uri(
    path: AppRoutes.plansPricingLicenseInfo,
    queryParameters: section == MobileLicenseInfoSection.none
        ? const {}
        : {'section': section.name},
  );
  context.push(uri.toString());
}
