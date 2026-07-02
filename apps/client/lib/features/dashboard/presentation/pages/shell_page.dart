import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/dashboard/application/sidebar_provider.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main app shell with collapsible sidebar and top action bar.
class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  String? _lastSyncedLocation;

  String _activeCompanyName(AuthSession? session) {
    if (session == null || session.businesses.isEmpty) {
      return 'My Business';
    }
    final businesses = session.businesses;
    if (businesses.length == 1) {
      return businesses.first.name;
    }
    final role = session.user.role;
    if (role != null) {
      for (final business in businesses) {
        if (business.role == role) {
          return business.name;
        }
      }
    }
    return businesses.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    if (_lastSyncedLocation != currentLocation) {
      _lastSyncedLocation = currentLocation;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(sidebarProvider.notifier)
            .syncExpansionForLocation(currentLocation);
      });
    }

    final sidebarState = ref.watch(sidebarProvider);
    final session = ref.watch(authProvider).session;
    final companyName = _activeCompanyName(session);
    final isCompact = MediaQuery.sizeOf(context).width < 900;
    final collapsed = sidebarState.isCollapsed;

    final sidebar = AppSidebar(
      currentLocation: currentLocation,
      collapsed: !isCompact && collapsed,
      expandedSections: sidebarState.expandedSections,
      companyName: companyName,
      onToggleCollapse: () => ref.read(sidebarProvider.notifier).toggleCollapsed(),
      onToggleSection: (id) => ref.read(sidebarProvider.notifier).toggleSection(id),
      onEditProfile: () => context.go(AppRoutes.editProfile),
      onSwitchCompany: () async {
        await ref.read(authProvider.notifier).enterBusinessSelection();
        if (mounted) context.go(AppRoutes.businessList);
      },
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (mounted) context.go(AppRoutes.login);
      },
    );

    if (isCompact) {
      return Scaffold(
        drawer: Drawer(
          backgroundColor: SidebarTokens.background,
          child: SafeArea(child: sidebar),
        ),
        appBar: AppBar(
          title: const Text('Billing Baba'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: ColoredBox(
          color: AppColors.background,
          child: Column(
            children: [
              _ShellTopBar(onAddSale: () => context.push(AppRoutes.addSale)),
              Expanded(child: widget.child),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: SidebarTokens.animationDuration,
            curve: SidebarTokens.animationCurve,
            width: collapsed
                ? SidebarTokens.collapsedWidth
                : SidebarTokens.expandedWidth,
            child: sidebar,
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: Column(
                children: [
                  _ShellTopBar(onAddSale: () => context.push(AppRoutes.addSale)),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellTopBar extends StatelessWidget {
  const _ShellTopBar({required this.onAddSale});

  final VoidCallback onAddSale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Transactions',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TopBarButton(
                    label: 'Add Sale',
                    color: AppColors.error,
                    onPressed: onAddSale,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _TopBarButton(
                    label: 'Add Purchase',
                    color: AppColors.primary,
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _TopBarIconButton(icon: Icons.add, onPressed: () {}),
                  _TopBarIconButton(
                    icon: Icons.print_outlined,
                    onPressed: () {},
                  ),
                  _TopBarIconButton(icon: Icons.more_vert, onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        minimumSize: const Size(0, 36),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColors.textSecondary, size: 22),
      onPressed: onPressed,
      tooltip: '',
    );
  }
}
