import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileUserProfilePage extends ConsumerWidget {
  const MobileUserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.session?.user;
    final name = user?.name?.trim();
    final phone = auth.phone.isNotEmpty ? auth.phone : user?.phone ?? '';
    final role = user?.role ?? '—';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Profile',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                (name?.isNotEmpty == true
                        ? name![0]
                        : phone.isNotEmpty
                        ? phone[0]
                        : 'U')
                    .toUpperCase(),
                style: AppTypography.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              name?.isNotEmpty == true ? name! : 'User',
              style: AppTypography.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              phone,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Role',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      role,
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'User ID',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      user?.id ?? '—',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
