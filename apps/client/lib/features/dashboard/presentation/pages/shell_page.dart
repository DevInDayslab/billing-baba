import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main app shell with collapsible sidebar and top action bar.
class ShellPage extends StatefulWidget {
  const ShellPage({required this.child, super.key});

  final Widget child;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  static const _sidebarExpandedWidth = 220.0;
  static const _sidebarCollapsedWidth = 60.0;
  static const _sidebarColor = Color(0xFF1C2333);
  static const _sidebarText = Color(0xFFB0BEC5);
  static const _sidebarTextActive = Color(0xFFFFFFFF);

  bool _isCollapsed = false;

  static const _navItems = [
    _NavItem(route: AppRoutes.home, icon: Icons.home_outlined, label: 'Home'),
    _NavItem(
      route: AppRoutes.parties,
      icon: Icons.people_outlined,
      label: 'Parties',
    ),
    _NavItem(
      route: AppRoutes.items,
      icon: Icons.inventory_2_outlined,
      label: 'Items',
    ),
    _NavItem(
      route: AppRoutes.sale,
      icon: Icons.receipt_outlined,
      label: 'Sale',
    ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Purchase & Expense',
    ),
    _NavItem(
      route: AppRoutes.reports,
      icon: Icons.bar_chart_outlined,
      label: 'Reports',
    ),
    _NavItem(
      route: AppRoutes.settings,
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _isCollapsed ? _sidebarCollapsedWidth : _sidebarExpandedWidth,
            color: _sidebarColor,
            child: Column(
              children: [
                _buildSidebarHeader(),
                Expanded(child: _buildNavList(currentLocation)),
                _buildSidebarFooter(),
              ],
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
      child: _isCollapsed
          ? Center(
              child: IconButton(
                icon: const Icon(Icons.last_page, color: _sidebarText, size: 20),
                onPressed: () => setState(() => _isCollapsed = false),
                tooltip: 'Expand sidebar',
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: _sidebarText, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: _sidebarText, size: 20),
                      filled: true,
                      fillColor: const Color(0xFF141B27),
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(color: _sidebarTextActive, fontSize: 13),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.first_page, color: _sidebarText, size: 20),
                  onPressed: () => setState(() => _isCollapsed = true),
                  tooltip: 'Collapse sidebar',
                ),
              ],
            ),
    );
  }

  Widget _buildNavList(String currentLocation) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      itemCount: _navItems.length,
      itemBuilder: (context, index) {
        final item = _navItems[index];
        final isActive = item.route != null && currentLocation == item.route;

        return _SidebarNavTile(
          item: item,
          collapsed: _isCollapsed,
          isActive: isActive,
          onTap: item.route != null ? () => context.go(item.route!) : null,
        );
      },
    );
  }

  Widget _buildSidebarFooter() {
    return InkWell(
      onTap: () => context.go(AppRoutes.editProfile),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _isCollapsed ? AppSpacing.sm : AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2A3447))),
        ),
        child: Row(
          children: [
            if (!_isCollapsed) ...[
              Expanded(
                child: Text(
                  'My Business',
                  style: const TextStyle(
                    color: _sidebarTextActive,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, color: _sidebarText, size: 20),
            ] else
              const Icon(Icons.store_outlined, color: _sidebarText, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.surface,
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
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TopBarButton(
                  label: 'Add Sale',
                  color: AppColors.error,
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.sm),
                _TopBarButton(
                  label: 'Add Purchase',
                  color: AppColors.primary,
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.sm),
                _TopBarIconButton(icon: Icons.add, onPressed: () {}),
                _TopBarIconButton(icon: Icons.print_outlined, onPressed: () {}),
                _TopBarIconButton(icon: Icons.more_vert, onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    this.route,
  });

  final IconData icon;
  final String label;
  final String? route;
}

class _SidebarNavTile extends StatelessWidget {
  const _SidebarNavTile({
    required this.item,
    required this.collapsed,
    required this.isActive,
    this.onTap,
  });

  final _NavItem item;
  final bool collapsed;
  final bool isActive;
  final VoidCallback? onTap;

  static const _sidebarActiveBg = Color(0xFF2A3447);
  static const _sidebarText = Color(0xFFB0BEC5);
  static const _sidebarTextActive = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: isActive ? _sidebarActiveBg : Colors.transparent,
            borderRadius: AppRadius.smBorder,
            border: isActive
                ? Border(left: BorderSide(color: accentColor, width: 3))
                : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: isActive ? _sidebarTextActive : _sidebarText,
                size: 22,
              ),
              if (!collapsed) ...[
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? _sidebarTextActive : _sidebarText,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
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
