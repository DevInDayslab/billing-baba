import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Mobile home header with welcome row, actions, and sync status.
class MobileHomeHeader extends ConsumerWidget {
  const MobileHomeHeader({
    super.key,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onAvatarTap,
    this.onBusinessTap,
    this.onSyncTap,
    this.lastSyncLabel = 'Last sync 1 min ago',
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onBusinessTap;
  final VoidCallback? onSyncTap;
  final String lastSyncLabel;

  static const accentPurple = Color(0xFF5D5FEF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(sidebarBusinessProvider);
    final userName = ref.watch(authProvider).session?.user.name ?? 'User';
    final firstName = userName.split(' ').first;
    final nowLabel = DateFormat('hh:mm a, d MMM yyyy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onAvatarTap,
                borderRadius: BorderRadius.circular(22),
                child: BusinessAvatar(
                  name: userName,
                  seed: business.seed,
                  diameter: 44,
                  logoUrl: business.logoUrl,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: InkWell(
                  onTap: onBusinessTap,
                  borderRadius: AppRadius.mdBorder,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $firstName',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                business.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeaderActionButton(
                icon: Icons.notifications_none_rounded,
                label: 'Notification',
                onTap: onNotificationTap,
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeaderActionButton(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: onSettingsTap,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  lastSyncLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              InkWell(
                onTap: onSyncTap,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Text(
                ' | ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              Text(
                nowLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
