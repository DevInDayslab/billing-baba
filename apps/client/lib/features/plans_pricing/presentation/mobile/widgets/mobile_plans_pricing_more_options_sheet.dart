import 'package:billing_baba/core/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/features/plans_pricing/application/plans_pricing_license_constants.dart';
import 'package:billing_baba/features/plans_pricing/presentation/desktop/widgets/buy_licenses_dialog.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/mobile_license_info_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void _openLicenseInfoAfterSheet(
  BuildContext context,
  MobileLicenseInfoSection section,
) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    openMobileLicenseInfoPage(context, section: section);
  });
}

/// Vyapar-style overflow menu for the mobile Plans & Pricing screen.
Future<void> showMobilePlansPricingMoreOptionsSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showMobileMoreActionsSheet(
    context: context,
    title: 'More Options',
    actions: [
      MobileSheetAction(
        label: 'License Info',
        icon: Icons.info_outline_rounded,
        onTap: () => _openLicenseInfoAfterSheet(
          context,
          MobileLicenseInfoSection.offlinePayment,
        ),
      ),
      MobileSheetAction(
        label: 'Attach License',
        icon: Icons.info_outline_rounded,
        onTap: () => _openLicenseInfoAfterSheet(
          context,
          MobileLicenseInfoSection.attachLicense,
        ),
      ),
      MobileSheetAction(
        label: 'Offline Payment',
        icon: Icons.currency_rupee_rounded,
        onTap: () => _openLicenseInfoAfterSheet(
          context,
          MobileLicenseInfoSection.offlinePayment,
        ),
      ),
      MobileSheetAction(
        label: 'Buy Multiple Licenses',
        icon: Icons.library_add_outlined,
        onTap: () => showBuyLicensesDialog(context),
      ),
      MobileSheetAction(
        label: 'Version: 1.0.0',
        icon: Icons.info_outline_rounded,
        enabled: false,
        onTap: () {},
      ),
    ],
  );
}
