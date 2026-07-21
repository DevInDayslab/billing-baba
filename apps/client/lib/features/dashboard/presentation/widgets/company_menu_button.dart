import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Company switcher for the top bar — extracted from the shell sidebar footer.
class CompanyMenuButton extends ConsumerStatefulWidget {
  const CompanyMenuButton({super.key});

  @override
  ConsumerState<CompanyMenuButton> createState() => _CompanyMenuButtonState();
}

class _CompanyMenuButtonState extends ConsumerState<CompanyMenuButton> {
  final _layerLink = LayerLink();
  OverlayEntry? _menuOverlay;
  var _menuOpen = false;

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  void _toggleMenu() {
    if (_menuOpen) {
      _removeMenu();
    } else {
      _showMenu();
    }
  }

  void _showMenu() {
    final business = ref.read(sidebarBusinessProvider);
    final overlay = Overlay.of(context);
    _menuOverlay = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeMenu,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, AppSpacing.xs),
            child: CompanyProfileMenuCard(
              companyName: business.name,
              onEditProfile: () {
                _removeMenu();
                context.go(AppRoutes.editProfile);
              },
              onMyProfile: () {
                _removeMenu();
                context.go(AppRoutes.userProfile);
              },
              onSwitchCompany: () {
                _removeMenu();
                unawaited(_switchCompany());
              },
              onLogout: () {
                _removeMenu();
                unawaited(_logout());
              },
            ),
          ),
        ],
      ),
    );
    overlay.insert(_menuOverlay!);
    setState(() => _menuOpen = true);
  }

  void _removeMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
    if (_menuOpen) {
      setState(() => _menuOpen = false);
    }
  }

  Future<void> _switchCompany() async {
    await ref.read(authProvider.notifier).enterBusinessSelection();
    if (!mounted) return;
    context.go(AppRoutes.businessList);
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(sidebarBusinessProvider);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleMenu,
          borderRadius: AppRadius.mdBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BusinessAvatar(
                  name: business.name,
                  seed: business.seed,
                  logoUrl: business.logoUrl,
                  diameter: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        business.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Company',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                AnimatedRotation(
                  turns: _menuOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompanyProfileMenuCard extends StatelessWidget {
  const CompanyProfileMenuCard({
    required this.companyName,
    required this.onEditProfile,
    required this.onMyProfile,
    required this.onSwitchCompany,
    required this.onLogout,
    super.key,
  });

  final String companyName;
  final VoidCallback onEditProfile;
  final VoidCallback onMyProfile;
  final VoidCallback onSwitchCompany;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: AppRadius.mdBorder,
      color: AppColors.surface,
      child: SizedBox(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Company',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    companyName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            _CompanyMenuItem(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: onEditProfile,
            ),
            _CompanyMenuItem(
              icon: Icons.person_outline,
              label: 'My Profile',
              onTap: onMyProfile,
            ),
            _CompanyMenuItem(
              icon: Icons.autorenew,
              label: 'Switch Company',
              onTap: onSwitchCompany,
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            _CompanyMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              color: AppColors.error,
              onTap: onLogout,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

class _CompanyMenuItem extends StatelessWidget {
  const _CompanyMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: itemColor),
            const SizedBox(width: AppSpacing.sm + 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: itemColor),
            ),
          ],
        ),
      ),
    );
  }
}
