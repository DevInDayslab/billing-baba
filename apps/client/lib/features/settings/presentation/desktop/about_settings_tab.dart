import 'dart:ui';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/app_update/application/update_controller.dart';
import 'package:billing_baba/features/app_update/application/update_state.dart';
import 'package:billing_baba/features/app_update/presentation/update_dialog.dart';
import 'package:billing_baba/shared/widgets/legal/legal_consent_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Premium, minimal About tab — identity and technical metadata only.
class AboutSettingsTab extends ConsumerWidget {
  const AboutSettingsTab({super.key});

  static const _tagline = 'Professional retail management';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateControllerProvider);

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final version = info?.version ?? '—';
        final build = info?.buildNumber ?? '—';

        return Stack(
          fit: StackFit.expand,
          children: [
            const _AboutAmbientBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: listPanelCardBorder.withValues(alpha: 0.9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(
                            alpha: 0.035,
                          ),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 48,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            AppConfig.appName,
                            textAlign: TextAlign.center,
                            style: AppTypography.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.6,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _tagline,
                            textAlign: TextAlign.center,
                            style: AppTypography.inter(
                              fontSize: AppTypography.bodyMediumSize,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.15,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _MetaChip(
                                label: 'Version $version ($build)',
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _AboutUpdateSection(
                            updateState: updateState,
                            onCheck: () async {
                              if (!AppConfig.updateManifestConfigured) return;
                              await ref
                                  .read(updateControllerProvider.notifier)
                                  .checkManually();
                              final next = ref.read(updateControllerProvider);
                              if (next.status == UpdateStatus.updateAvailable) {
                                showUpdateDialog(isForced: next.isForced);
                              } else if (next.status == UpdateStatus.upToDate) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "You're up to date (v$version)",
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          const LegalDocumentLinksRow(),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            '© ${DateTime.now().year} Billing Baba',
                            textAlign: TextAlign.center,
                            style: AppTypography.inter(
                              fontSize: AppTypography.bodySmallSize,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                              letterSpacing: 0.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AboutUpdateSection extends StatelessWidget {
  const _AboutUpdateSection({
    required this.updateState,
    required this.onCheck,
  });

  final UpdateState updateState;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.updateManifestConfigured) {
      return Text(
        'Updates are not configured',
        textAlign: TextAlign.center,
        style: AppTypography.inter(
          fontSize: AppTypography.bodySmallSize,
          color: AppColors.textSecondary,
        ),
      );
    }

    final checking = updateState.status == UpdateStatus.checking;

    return TextButton.icon(
      onPressed: checking ? null : onCheck,
      icon: checking
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.system_update_alt_outlined, size: 18),
      label: Text(checking ? 'Checking for updates…' : 'Check for updates'),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySmallSize,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary.withValues(alpha: 0.78),
            letterSpacing: 0.15,
          ),
        ),
      ),
    );
  }
}

/// Soft, static ambient shapes — low opacity, never competes with content.
class _AboutAmbientBackground extends StatelessWidget {
  const _AboutAmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.background),
            Positioned(
              top: -120,
              right: -80,
              child: _SoftBlob(
                diameter: 420,
                color: AppColors.primary.withValues(alpha: 0.055),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: _SoftBlob(
                diameter: 480,
                color: AppColors.secondary.withValues(alpha: 0.045),
              ),
            ),
            Positioned(
              top: 180,
              left: -60,
              child: _SoftBlob(
                diameter: 280,
                color: AppColors.primary.withValues(alpha: 0.035),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
