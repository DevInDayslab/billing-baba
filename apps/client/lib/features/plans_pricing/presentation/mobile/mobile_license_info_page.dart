import 'dart:async';
import 'dart:io' show Platform;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/features/plans_pricing/application/plans_pricing_license_constants.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/application/mobile_plans_selection_provider.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/widgets/mobile_license_expandable_card.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vyapar-style full-screen license info with attach license & offline payment.
class MobileLicenseInfoPage extends ConsumerStatefulWidget {
  const MobileLicenseInfoPage({
    this.initialSection = MobileLicenseInfoSection.none,
    super.key,
  });

  final MobileLicenseInfoSection initialSection;

  @override
  ConsumerState<MobileLicenseInfoPage> createState() =>
      _MobileLicenseInfoPageState();
}

class _MobileLicenseInfoPageState extends ConsumerState<MobileLicenseInfoPage> {
  late var _attachLicenseExpanded =
      widget.initialSection == MobileLicenseInfoSection.attachLicense;
  late var _offlinePaymentExpanded =
      widget.initialSection == MobileLicenseInfoSection.offlinePayment;
  final _licenseKeyController = TextEditingController();
  var _deviceId = PlansPricingLicenseConstants.fallbackDeviceId;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDeviceId());
  }

  @override
  void dispose() {
    _licenseKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceId() async {
    if (kIsWeb) return;

    try {
      final info = DeviceInfoPlugin();
      String? id;
      if (Platform.isAndroid) {
        id = (await info.androidInfo).id;
      } else if (Platform.isIOS) {
        id = (await info.iosInfo).identifierForVendor;
      }
      if (id != null && id.isNotEmpty && mounted) {
        setState(() => _deviceId = id!);
      }
    } on Object {
      // Keep fallback device id.
    }
  }

  String _planLabel(CurrentSubscription current, PlanPlatform platform) {
    if (current.hasActivePlan) {
      return '${platform.label} ${current.planName}';
    }
    return '${platform.label} Freemium';
  }

  String _syncCompanyId() {
    final business = ref.read(sidebarBusinessProvider);
    final session = ref.read(companySessionProvider);
    if (session != null) {
      final slug = business.name.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      return '${slug}_t_${session.companyId}';
    }
    return PlansPricingLicenseConstants.fallbackSyncCompanyId;
  }

  void _attachLicense() {
    final key = _licenseKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a license key to continue.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attaching license $key…')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAsync = ref.watch(currentSubscriptionStateProvider);
    final platform = ref.watch(mobilePlansSelectionProvider).platform;
    final syncCompanyId = _syncCompanyId();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'View License Info',
        showBackButton: true,
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
      ),
      body: currentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text(
            'Unable to load license info.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (current) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  _CurrentPlanCard(
                    label: _planLabel(current, platform),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MobileLicenseExpandableCard(
                    title: 'Already have a License?',
                    icon: Icons.badge_outlined,
                    isExpanded: _attachLicenseExpanded,
                    onToggle: () => setState(
                      () => _attachLicenseExpanded = !_attachLicenseExpanded,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _licenseKeyController,
                          decoration: InputDecoration(
                            labelText: 'License Key',
                            hintText: 'Enter your license key',
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mdBorder,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: _attachLicense,
                            child: const Text('Attach License'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MobileLicenseExpandableCard(
                    title: 'Offline Payment',
                    icon: Icons.payments_outlined,
                    isExpanded: _offlinePaymentExpanded,
                    onToggle: () => setState(
                      () => _offlinePaymentExpanded = !_offlinePaymentExpanded,
                    ),
                    child: Column(
                      children: [
                        for (final entry
                            in PlansPricingLicenseConstants
                                .offlinePaymentDetails.entries)
                          MobileLicenseDetailRow(
                            label: entry.key,
                            value: entry.value,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _LicenseFooter(
              deviceId: _deviceId,
              syncCompanyId: syncCompanyId,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _LicenseFooter extends StatelessWidget {
  const _LicenseFooter({
    required this.deviceId,
    required this.syncCompanyId,
  });

  final String deviceId;
  final String syncCompanyId;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 11,
      color: AppColors.textSecondary,
      height: 1.3,
    );

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Device ID: $deviceId', style: labelStyle),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sync Company ID: ', style: labelStyle),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      unawaited(
                        Clipboard.setData(ClipboardData(text: syncCompanyId)),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sync Company ID copied'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      syncCompanyId,
                      style: labelStyle.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
