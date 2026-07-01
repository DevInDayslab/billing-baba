import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
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
    final session = ref.watch(authProvider).session;
    final companyName = _activeCompanyName(session);

    return _SidebarProfileFooter(
      collapsed: _isCollapsed,
      companyName: companyName,
      onEditProfile: () => context.go(AppRoutes.editProfile),
      onSwitchCompany: () => context.go(AppRoutes.businessList),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (mounted) context.go(AppRoutes.login);
      },
    );
  }

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

class _SidebarProfileFooter extends StatefulWidget {
  const _SidebarProfileFooter({
    required this.collapsed,
    required this.companyName,
    required this.onEditProfile,
    required this.onSwitchCompany,
    required this.onLogout,
  });

  final bool collapsed;
  final String companyName;
  final VoidCallback onEditProfile;
  final VoidCallback onSwitchCompany;
  final Future<void> Function() onLogout;

  @override
  State<_SidebarProfileFooter> createState() => _SidebarProfileFooterState();
}

class _SidebarProfileFooterState extends State<_SidebarProfileFooter> {
  static const _sidebarColor = Color(0xFF1C2333);
  static const _sidebarText = Color(0xFFB0BEC5);
  static const _sidebarTextActive = Color(0xFFFFFFFF);

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
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.bottomLeft,
            offset: const Offset(AppSpacing.sm, -AppSpacing.xs),
            child: _ProfileMenuCard(
              companyName: widget.companyName,
              onEditProfile: () {
                _removeMenu();
                widget.onEditProfile();
              },
              onSwitchCompany: () {
                _removeMenu();
                widget.onSwitchCompany();
              },
              onLogout: () async {
                _removeMenu();
                await widget.onLogout();
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

  String get _initial {
    final trimmed = widget.companyName.trim();
    if (trimmed.isEmpty) return 'B';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: _sidebarColor,
        child: InkWell(
          onTap: _toggleMenu,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? AppSpacing.sm : AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF2A3447))),
            ),
            child: widget.collapsed
                ? Center(
                    child: _CompanyAvatar(initial: _initial, radius: 16),
                  )
                : Row(
                    children: [
                      _CompanyAvatar(initial: _initial),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.companyName,
                          style: const TextStyle(
                            color: _sidebarTextActive,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _menuOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.chevron_right,
                          color: _sidebarText,
                          size: 20,
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

class _CompanyAvatar extends StatelessWidget {
  const _CompanyAvatar({required this.initial, this.radius = 18});

  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.78,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.companyName,
    required this.onEditProfile,
    required this.onSwitchCompany,
    required this.onLogout,
  });

  final String companyName;
  final VoidCallback onEditProfile;
  final VoidCallback onSwitchCompany;
  final Future<void> Function() onLogout;

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
            _ProfileMenuItem(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: onEditProfile,
            ),
            _ProfileMenuItem(
              icon: Icons.autorenew,
              label: 'Switch Company',
              onTap: onSwitchCompany,
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            _ProfileMenuItem(
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

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
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
              style: TextStyle(
                color: itemColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
