import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
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
  bool _isSaleExpanded = false;
  bool _saleExpandInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saleExpandInitialized) {
      _saleExpandInitialized = true;
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith(AppRoutes.sale)) {
        _isSaleExpanded = true;
      }
    }
  }

  static final List<_NavSubItem> _saleSubItems = SaleSubRoutes.items
      .map((item) => _NavSubItem(route: item.route, label: item.label))
      .toList();

  static final _navItems = [
    const _NavItem(route: AppRoutes.home, icon: Icons.home_outlined, label: 'Home'),
    const _NavItem(
      route: AppRoutes.parties,
      icon: Icons.people_outlined,
      label: 'Parties',
    ),
    const _NavItem(
      route: AppRoutes.items,
      icon: Icons.inventory_2_outlined,
      label: 'Items',
    ),
    // Only Sale uses expandable sub-items today; generalize if more parents are added.
    _NavItem(
      icon: Icons.receipt_outlined,
      label: 'Sale',
      isExpandable: true,
      subItems: _saleSubItems,
    ),
    const _NavItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Purchase & Expense',
    ),
    const _NavItem(
      route: AppRoutes.reports,
      icon: Icons.bar_chart_outlined,
      label: 'Reports',
    ),
    const _NavItem(
      route: AppRoutes.settings,
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
    const _NavItem(
      route: AppRoutes.plansPricing,
      icon: Icons.workspace_premium_outlined,
      label: 'Plans & Pricing',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _isCollapsed
                ? _sidebarCollapsedWidth
                : _sidebarExpandedWidth,
            color: _sidebarColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: _isCollapsed
          ? Center(
              child: IconButton(
                icon: const Icon(
                  Icons.last_page,
                  color: _sidebarText,
                  size: 20,
                ),
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
                      hintStyle: const TextStyle(
                        color: _sidebarText,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: _sidebarText,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF141B27),
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
                      color: _sidebarTextActive,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.first_page,
                    color: _sidebarText,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isCollapsed = true),
                  tooltip: 'Collapse sidebar',
                ),
              ],
            ),
    );
  }

  Widget _buildNavList(String currentLocation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in _navItems) _buildNavItem(item, currentLocation),
        ],
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, String currentLocation) {
    if (item.isExpandable) {
      final isParentActive = currentLocation.startsWith(AppRoutes.sale);

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarExpandableNavTile(
            item: item,
            collapsed: _isCollapsed,
            isActive: isParentActive,
            isExpanded: _isSaleExpanded,
            onToggle: () => setState(() => _isSaleExpanded = !_isSaleExpanded),
          ),
          if (_isSaleExpanded && !_isCollapsed)
            ...item.subItems.map((sub) {
              final isSubActive =
                  currentLocation == sub.route ||
                  (sub.route == AppRoutes.saleInvoices &&
                      (currentLocation == AppRoutes.addSale ||
                          currentLocation.startsWith('${AppRoutes.editSale}/'))) ||
                  (sub.route == AppRoutes.saleReturnCreditNote &&
                      currentLocation == AppRoutes.addCreditNote);
              return _SidebarNavSubTile(
                label: sub.label,
                isActive: isSubActive,
                onTap: () => context.go(sub.route),
              );
            }),
        ],
      );
    }

    final isActive = item.route != null && currentLocation == item.route;

    return _SidebarNavTile(
      item: item,
      collapsed: _isCollapsed,
      isActive: isActive,
      onTap: item.route != null ? () => context.go(item.route!) : null,
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
        child: _isCollapsed
            ? const Center(
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF2A3447),
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
              )
            : const Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF2A3447),
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'My Business',
                      style: TextStyle(
                        color: _sidebarTextActive,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: _sidebarText, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildTopBar() {
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
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TopBarButton(
                label: 'Add Sale',
                color: AppColors.error,
                onPressed: () => context.push(AppRoutes.addSale),
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
    this.isExpandable = false,
    this.subItems = const [],
  });

  final IconData icon;
  final String label;
  final String? route;
  final bool isExpandable;
  final List<_NavSubItem> subItems;
}

class _NavSubItem {
  const _NavSubItem({required this.route, required this.label});

  final String route;
  final String label;
}

class _SidebarExpandableNavTile extends StatelessWidget {
  const _SidebarExpandableNavTile({
    required this.item,
    required this.collapsed,
    required this.isActive,
    required this.isExpanded,
    required this.onToggle,
  });

  final _NavItem item;
  final bool collapsed;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onToggle;

  static const _sidebarActiveBg = Color(0xFF2A3447);
  static const _sidebarText = Color(0xFFB0BEC5);
  static const _sidebarTextActive = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: collapsed ? null : onToggle,
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
                      fontWeight: isActive
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    color: isActive ? _sidebarTextActive : _sidebarText,
                    size: 20,
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

class _SidebarNavSubTile extends StatelessWidget {
  const _SidebarNavSubTile({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md + 20,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? _sidebarTextActive : _sidebarText,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
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
                      fontWeight: isActive
                          ? FontWeight.w500
                          : FontWeight.normal,
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
