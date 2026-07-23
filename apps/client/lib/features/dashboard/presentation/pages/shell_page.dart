import 'dart:async';

import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/image/image_startup_warmup.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_avatar.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_opening_overlay.dart';
import 'package:billing_baba/features/collaboration/application/navigation_permission_registry.dart';
import 'package:billing_baba/features/collaboration/application/permission_service.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_session_bootstrap_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/models/collaboration_sub_route.dart';
import 'package:billing_baba/features/dashboard/application/quick_create_executor.dart';
import 'package:billing_baba/features/dashboard/models/quick_create_action.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/app_top_bar.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/customer_support_strip.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/quick_create_menu.dart';
import 'package:billing_baba/features/dashboard/providers/quick_create_menu_provider.dart';
import 'package:billing_baba/features/dashboard/providers/shell_sidebar_provider.dart';
import 'package:billing_baba/features/parties/models/party_sub_route.dart';
import 'package:billing_baba/features/parties/providers/parties_selection_providers.dart';
import 'package:billing_baba/features/pos/providers/pos_session_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_sub_route.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
import 'package:billing_baba/features/search/application/search_route_observer.dart';
import 'package:billing_baba/features/search/application/search_shortcuts_handler.dart';
import 'package:billing_baba/features/search/presentation/search_dialog.dart';
import 'package:billing_baba/features/search/providers/search_dialog_provider.dart';
import 'package:billing_baba/features/utilities/models/utilities_sub_route.dart';
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
  static const _sidebarCompactLayoutMaxWidth = 140.0;
  static const _overlayBreakpoint = 800.0;

  /// Sidebar content toggles immediately on collapse, but [AnimatedContainer]
  /// width animates over 200ms — use compact layout until there is room.
  static bool _useCompactSidebarLayout(bool collapsed, double width) {
    return collapsed || width < _sidebarCompactLayoutMaxWidth;
  }

  static const _sidebarColor = Color(0xFF1C2333);
  static const _sidebarText = Color(0xFFB0BEC5);
  static const _sidebarTextActive = Color(0xFFFFFFFF);

  bool _isSaleExpanded = false;
  bool _isPurchaseExpanded = false;
  bool _expandInitialized = false;
  bool _isPartiesExpanded = false;
  bool _partiesExpandInitialized = false;
  bool _isUtilitiesExpanded = false;
  bool _utilitiesExpandInitialized = false;
  bool _isCollaborationExpanded = false;
  bool _collaborationExpandInitialized = false;
  bool _isDeveloperExpanded = false;
  bool _developerExpandInitialized = false;
  bool? _wasOverlaySidebar;
  bool _useOverlaySidebar = false;
  String? _lastRecordedSearchRoute;
  final _shellShortcutFocusNode = FocusNode(debugLabel: 'shellShortcuts');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerSearchDialog();
      _ensureShellShortcutFocus();
      final businessId = ref.read(sidebarBusinessProvider).id;
      if (businessId!.isNotEmpty) {
        unawaited(
          ref.read(imageStartupWarmupProvider).run(businessId: businessId),
        );
      }
    });
  }

  @override
  void dispose() {
    ref.read(searchDialogProvider.notifier).unregister();
    _shellShortcutFocusNode.dispose();
    super.dispose();
  }

  void _ensureShellShortcutFocus() {
    if (!mounted || shouldSuppressSearchShortcuts()) return;
    if (!_shellShortcutFocusNode.hasFocus) {
      _shellShortcutFocusNode.requestFocus();
    }
  }

  void _registerSearchDialog() {
    ref
        .read(searchDialogProvider.notifier)
        .register(
          open: (context) => showSearchDialog(context, ref),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_expandInitialized) {
      _expandInitialized = true;
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith(AppRoutes.sale) ||
          location.startsWith(AppRoutes.crm)) {
        _isSaleExpanded = true;
      }
      if (location.startsWith(AppRoutes.purchase)) {
        _isPurchaseExpanded = true;
      }
    }
    if (!_partiesExpandInitialized) {
      _partiesExpandInitialized = true;
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith(AppRoutes.parties)) {
        _isPartiesExpanded = true;
      }
    }
    if (!_utilitiesExpandInitialized) {
      _utilitiesExpandInitialized = true;
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith(AppRoutes.utilities)) {
        _isUtilitiesExpanded = true;
      }
    }
    if (!_collaborationExpandInitialized) {
      _collaborationExpandInitialized = true;
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith(AppRoutes.collaboration)) {
        _isCollaborationExpanded = true;
      }
    }
    if (!_developerExpandInitialized) {
      _developerExpandInitialized = true;
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith(AppRoutes.developer)) {
        _isDeveloperExpanded = true;
      }
    }
  }

  static final List<_NavSubItem> _partiesSubItems = PartySubRoutes.items
      .map((item) => _NavSubItem(route: item.route, label: item.label))
      .toList();

  static final List<_NavSubItem> _saleSubItems = SaleSubRoutes.items
      .where(
        (item) =>
            !ShellSidebarVisibility.hiddenSaleSubRoutes.contains(item.route),
      )
      .map((item) => _NavSubItem(route: item.route, label: item.label))
      .toList();

  static final List<_NavSubItem> _purchaseSubItems = PurchaseSubRoutes.items
      .map((item) => _NavSubItem(route: item.route, label: item.label))
      .toList();

  static final List<_NavSubItem> _utilitiesSubItems = UtilitiesSubRoutes.items
      .map((item) => _NavSubItem(route: item.route, label: item.label))
      .toList();

  static final List<_NavSubItem> _collaborationSubItems = CollaborationSubRoutes
      .items
      .map((item) => _NavSubItem(route: item.route, label: item.label))
      .toList();

  static final List<_NavSubItem> _developerSubItems = [
    const _NavSubItem(
      route: AppRoutes.developerComponents,
      label: 'Components',
    ),
    const _NavSubItem(
      route: AppRoutes.developerComponentsTableFilters,
      label: 'Table Filters',
    ),
    const _NavSubItem(
      route: AppRoutes.developerDiagnostics,
      label: 'Diagnostics',
    ),
  ];

  List<_NavItem> get _allNavItems => [
    const _NavItem(
      route: AppRoutes.home,
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    _NavItem(
      route: AppRoutes.parties,
      icon: Icons.people_outlined,
      label: 'Parties',
      isExpandable: true,
      subItems: _partiesSubItems,
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
      routePrefix: AppRoutes.sale,
      subItems: _saleSubItems,
    ),
    if (!ShellSidebarVisibility.hidePos)
      const _NavItem(
        route: AppRoutes.pos,
        icon: Icons.point_of_sale_outlined,
        label: 'POS',
      ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Purchase & Expense',
      isExpandable: true,
      routePrefix: AppRoutes.purchase,
      subItems: _purchaseSubItems,
    ),
    const _NavItem(
      route: AppRoutes.reports,
      icon: Icons.bar_chart_outlined,
      label: 'Reports',
    ),
    if (!ShellSidebarVisibility.hideCollaboration)
      _NavItem(
        icon: Icons.sync_outlined,
        label: 'Sync & Share',
        isExpandable: true,
        routePrefix: AppRoutes.collaboration,
        subItems: _collaborationSubItems,
      ),
    if (!ShellSidebarVisibility.hideUtilities)
      _NavItem(
        icon: Icons.build_outlined,
        label: 'Utilities',
        isExpandable: true,
        routePrefix: AppRoutes.utilities,
        subItems: _utilitiesSubItems,
      ),
    if (!ShellSidebarVisibility.hideDeveloper)
      _NavItem(
        icon: Icons.code_outlined,
        label: 'Developer',
        isExpandable: true,
        routePrefix: AppRoutes.developer,
        subItems: _developerSubItems,
      ),
    if (!ShellSidebarVisibility.hideSettings)
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

  List<_NavItem> _visibleNavItems(PermissionService permissions) {
    return _allNavItems
        .map((item) => _filterNavItem(item, permissions))
        .whereType<_NavItem>()
        .toList();
  }

  _NavItem? _filterNavItem(_NavItem item, PermissionService permissions) {
    if (item.routePrefix == AppRoutes.purchase) {
      if (!NavigationPermissionRegistry.isPurchaseNavVisible(permissions)) {
        return null;
      }
    } else {
      final route = item.route ?? item.routePrefix;
      if (route != null &&
          !NavigationPermissionRegistry.isVisible(route, permissions)) {
        return null;
      }
    }

    if (!item.isExpandable) return item;

    final subItems = item.subItems
        .where(
          (sub) =>
              NavigationPermissionRegistry.isVisible(sub.route, permissions),
        )
        .toList();
    if (subItems.isEmpty) return null;

    return _NavItem(
      icon: item.icon,
      label: item.label,
      route: item.route,
      routePrefix: item.routePrefix,
      isExpandable: item.isExpandable,
      subItems: subItems,
    );
  }

  void _navigateTo(String route) {
    ref
        .read(shellSidebarProvider.notifier)
        .closeOnNavigation(
          overlayLayout: _useOverlaySidebar,
        );
    setState(() {
      _isSaleExpanded = false;
      _isPurchaseExpanded = false;
      _isPartiesExpanded = false;
      _isUtilitiesExpanded = false;
      _isCollaborationExpanded = false;
      _isDeveloperExpanded = false;
    });
    if (route == AppRoutes.partyDetails) {
      ref.read(selectedPartyIdProvider.notifier).selected = null;
    }
    context.go(route);
  }

  void _expandSidebarIfCollapsed() {
    if (ref.read(shellSidebarProvider).isCollapsed) {
      ref.read(shellSidebarProvider.notifier).expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    if (_lastRecordedSearchRoute != currentLocation) {
      _lastRecordedSearchRoute = currentLocation;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          recordSearchRouteVisit(ref, currentLocation);
          _ensureShellShortcutFocus();
        }
      });
    }
    ref.watch(companySessionBootstrapProvider);
    final permissions = ref.watch(permissionServiceProvider);
    final sidebarState = ref.watch(shellSidebarProvider);
    final isCollapsed = sidebarState.isCollapsed;
    final isDrawerOpen = sidebarState.isDrawerOpen;
    final isOpeningBusiness = ref.watch(businessSessionLoadingProvider) != null;

    final shell = LayoutBuilder(
      builder: (context, constraints) {
        final useOverlaySidebar = constraints.maxWidth < _overlayBreakpoint;
        _useOverlaySidebar = useOverlaySidebar;

        if (_wasOverlaySidebar == true && !useOverlaySidebar && isDrawerOpen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(shellSidebarProvider.notifier).closeDrawer();
            }
          });
        }
        _wasOverlaySidebar = useOverlaySidebar;

        final showTopBar =
            currentLocation != AppRoutes.pos ||
            !ref.watch(posSessionProvider).isTerminalOpen;
        final mainContent = _ShellShortcutScope(
          quickCreateEnabled: showTopBar,
          shortcutFocusNode: _shellShortcutFocusNode,
          child: ColoredBox(
            color: AppColors.background,
            child: Column(
              children: [
                if (showTopBar) ...[
                  const CustomerSupportStrip(),
                  AppTopBar(showMenuButton: useOverlaySidebar),
                ],
                Expanded(child: widget.child),
              ],
            ),
          ),
        );

        if (useOverlaySidebar) {
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                mainContent,
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !isDrawerOpen,
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(shellSidebarProvider.notifier).closeDrawer(),
                      child: AnimatedOpacity(
                        opacity: isDrawerOpen ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const ColoredBox(color: Color(0x80000000)),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: isDrawerOpen ? 0 : -_sidebarExpandedWidth,
                  top: 0,
                  bottom: 0,
                  width: _sidebarExpandedWidth,
                  child: Material(
                    elevation: isDrawerOpen ? 8 : 0,
                    color: _sidebarColor,
                    child: _buildSidebarPanel(
                      currentLocation: currentLocation,
                      collapsed: false,
                      showCloseButton: true,
                      permissions: permissions,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: isCollapsed
                    ? _sidebarCollapsedWidth
                    : _sidebarExpandedWidth,
                color: _sidebarColor,
                child: GestureDetector(
                  onTap: isCollapsed
                      ? () => ref.read(shellSidebarProvider.notifier).expand()
                      : null,
                  behavior: HitTestBehavior.translucent,
                  child: _buildSidebarPanel(
                    currentLocation: currentLocation,
                    collapsed: isCollapsed,
                    permissions: permissions,
                  ),
                ),
              ),
              Expanded(child: mainContent),
            ],
          ),
        );
      },
    );

    if (!isOpeningBusiness) return shell;

    return Stack(
      fit: StackFit.expand,
      children: [
        shell,
        const BusinessOpeningOverlay(),
      ],
    );
  }

  Widget _buildSidebarPanel({
    required String currentLocation,
    required bool collapsed,
    required PermissionService permissions,
    bool showCloseButton = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactLayout = _useCompactSidebarLayout(
          collapsed,
          constraints.maxWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSidebarHeader(
              collapsed: compactLayout,
              showCloseButton: showCloseButton,
            ),
            Expanded(
              child: _buildNavList(
                currentLocation,
                collapsed: compactLayout,
                permissions: permissions,
              ),
            ),
            _buildSidebarFooter(collapsed: compactLayout),
          ],
        );
      },
    );
  }

  Widget _buildSidebarHeader({
    required bool collapsed,
    bool showCloseButton = false,
  }) {
    final sidebarNotifier = ref.read(shellSidebarProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: collapsed
          ? InkWell(
              onTap: sidebarNotifier.expand,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Icon(
                  Icons.last_page,
                  color: _sidebarText,
                  size: 20,
                ),
              ),
            )
          : Row(
              children: [
                if (showCloseButton)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: _sidebarText,
                      size: 20,
                    ),
                    onPressed: sidebarNotifier.closeDrawer,
                    tooltip: 'Close menu',
                  ),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () =>
                        ref.read(searchDialogProvider.notifier).open(context),
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
                if (!showCloseButton)
                  IconButton(
                    icon: const Icon(
                      Icons.first_page,
                      color: _sidebarText,
                      size: 20,
                    ),
                    onPressed: sidebarNotifier.toggleCollapsed,
                    tooltip: 'Collapse sidebar',
                  ),
              ],
            ),
    );
  }

  Widget _buildNavList(
    String currentLocation, {
    required bool collapsed,
    required PermissionService permissions,
  }) {
    final navItems = _visibleNavItems(permissions);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in navItems)
            _buildNavItem(item, currentLocation, collapsed: collapsed),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    _NavItem item,
    String currentLocation, {
    required bool collapsed,
  }) {
    if (item.isExpandable) {
      final isSale = item.routePrefix == AppRoutes.sale;
      final isPurchase = item.routePrefix == AppRoutes.purchase;
      final isParties = item.route == AppRoutes.parties;
      final isUtilities = item.routePrefix == AppRoutes.utilities;
      final isCollaboration = item.routePrefix == AppRoutes.collaboration;
      final isDeveloper = item.routePrefix == AppRoutes.developer;
      final routePrefix = item.routePrefix ?? item.route!;

      final isParentActive = isSale
          ? currentLocation.startsWith(AppRoutes.sale) ||
                currentLocation.startsWith(AppRoutes.crm)
          : isPurchase
          ? currentLocation.startsWith(AppRoutes.purchase)
          : isParties
          ? currentLocation.startsWith(AppRoutes.parties)
          : isUtilities
          ? currentLocation.startsWith(AppRoutes.utilities)
          : isCollaboration
          ? currentLocation.startsWith(AppRoutes.collaboration)
          : isDeveloper && currentLocation.startsWith(AppRoutes.developer);

      final isExpanded = isSale
          ? _isSaleExpanded
          : isPurchase
          ? _isPurchaseExpanded
          : isParties
          ? _isPartiesExpanded
          : isUtilities
          ? _isUtilitiesExpanded
          : isCollaboration
          ? _isCollaborationExpanded
          : isDeveloper && _isDeveloperExpanded;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarExpandableNavTile(
            item: item,
            collapsed: collapsed,
            isActive: isParentActive,
            isExpanded: isExpanded,
            onToggle: () => setState(() {
              if (isSale) {
                _isSaleExpanded = !_isSaleExpanded;
              } else if (isPurchase) {
                _isPurchaseExpanded = !_isPurchaseExpanded;
              } else if (isParties) {
                _isPartiesExpanded = !_isPartiesExpanded;
              } else if (isUtilities) {
                _isUtilitiesExpanded = !_isUtilitiesExpanded;
              } else if (isCollaboration) {
                _isCollaborationExpanded = !_isCollaborationExpanded;
              } else if (isDeveloper) {
                _isDeveloperExpanded = !_isDeveloperExpanded;
              }
            }),
            onCollapsedTap: () {
              _expandSidebarIfCollapsed();
              setState(() {
                if (isSale) {
                  _isSaleExpanded = true;
                } else if (isPurchase) {
                  _isPurchaseExpanded = true;
                } else if (isParties) {
                  _isPartiesExpanded = true;
                } else if (isUtilities) {
                  _isUtilitiesExpanded = true;
                } else if (isCollaboration) {
                  _isCollaborationExpanded = true;
                } else if (isDeveloper) {
                  _isDeveloperExpanded = true;
                }
              });
            },
          ),
          if (isExpanded && !collapsed)
            ...item.subItems.map((sub) {
              final isSubActive = _isSubItemActive(
                routePrefix: routePrefix,
                subRoute: sub.route,
                currentLocation: currentLocation,
              );
              return _SidebarNavSubTile(
                label: sub.label,
                isActive: isSubActive,
                onTap: () => _navigateTo(sub.route),
              );
            }),
        ],
      );
    }

    final isActive =
        item.route != null &&
        (currentLocation == item.route ||
            (item.route == AppRoutes.reports &&
                currentLocation.startsWith(AppRoutes.reports)));

    return _SidebarNavTile(
      item: item,
      collapsed: collapsed,
      isActive: isActive,
      onTap: item.route != null ? () => _navigateTo(item.route!) : null,
    );
  }

  bool _isSubItemActive({
    required String routePrefix,
    required String subRoute,
    required String currentLocation,
  }) {
    if (currentLocation == subRoute) return true;

    if (routePrefix == AppRoutes.sale) {
      if (subRoute == AppRoutes.saleInvoices &&
          (currentLocation == AppRoutes.addSale ||
              currentLocation.startsWith('${AppRoutes.editSale}/') ||
              currentLocation.startsWith('${AppRoutes.viewSale}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.saleReturnCreditNote &&
          currentLocation == AppRoutes.addCreditNote) {
        return true;
      }
    }

    if (routePrefix == AppRoutes.purchase) {
      if (subRoute == AppRoutes.purchaseBills &&
          currentLocation == AppRoutes.addPurchase) {
        return true;
      }
      if (subRoute == AppRoutes.purchaseExpenses &&
          currentLocation == AppRoutes.addExpense) {
        return true;
      }
      if (subRoute == AppRoutes.purchaseOrder &&
          currentLocation == AppRoutes.addPurchaseOrder) {
        return true;
      }
      if (subRoute == AppRoutes.purchaseReturnDebitNote &&
          currentLocation == AppRoutes.addDebitNote) {
        return true;
      }
      if (subRoute == AppRoutes.purchaseFa &&
          currentLocation == AppRoutes.addPurchaseFa) {
        return true;
      }
    }

    return false;
  }

  Widget _buildSidebarFooter({required bool collapsed}) {
    final sidebarBusiness = ref.watch(sidebarBusinessProvider);

    return _SidebarProfileFooter(
      collapsed: collapsed,
      companyName: sidebarBusiness.name,
      avatarSeed: sidebarBusiness.seed,
      logoUrl: sidebarBusiness.logoUrl,
      onExpand: _expandSidebarIfCollapsed,
      onEditProfile: () => _navigateTo(AppRoutes.editProfile),
      onSwitchCompany: () async {
        await ref.read(authProvider.notifier).enterBusinessSelection();
        if (mounted) _navigateTo(AppRoutes.businessList);
      },
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (mounted) _navigateTo(AppRoutes.login);
      },
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    this.route,
    this.routePrefix,
    this.isExpandable = false,
    this.subItems = const [],
  });

  final IconData icon;
  final String label;
  final String? route;
  final String? routePrefix;
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
    this.onCollapsedTap,
  });

  final _NavItem item;
  final bool collapsed;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback? onCollapsedTap;

  static const _sidebarActiveBg = Color(0xFF2A3447);
  static const _sidebarText = Color(0xFFB0BEC5);
  static const _sidebarTextActive = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: collapsed ? onCollapsedTap : onToggle,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: isActive ? _sidebarActiveBg : Colors.transparent,
            borderRadius: AppRadius.smBorder,
            border: isActive && !collapsed
                ? Border(left: BorderSide(color: accentColor, width: 3))
                : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 4 : AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: collapsed
              ? Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      item.icon,
                      color: isActive ? _sidebarTextActive : _sidebarText,
                      size: 20,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isActive ? _sidebarTextActive : _sidebarText,
                      size: 22,
                    ),
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
  static const _sidebarText = Color(0xFFCFD8DC);
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
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
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
            border: isActive && !collapsed
                ? Border(left: BorderSide(color: accentColor, width: 3))
                : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 4 : AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: collapsed
              ? Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      item.icon,
                      color: isActive ? _sidebarTextActive : _sidebarText,
                      size: 20,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isActive ? _sidebarTextActive : _sidebarText,
                      size: 22,
                    ),
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
                ),
        ),
      ),
    );
  }
}

class _SidebarProfileFooter extends StatefulWidget {
  const _SidebarProfileFooter({
    required this.collapsed,
    required this.companyName,
    required this.avatarSeed,
    required this.onExpand,
    required this.onEditProfile,
    required this.onSwitchCompany,
    required this.onLogout,
    this.logoUrl,
  });

  final bool collapsed;
  final String companyName;
  final String avatarSeed;
  final String? logoUrl;
  final VoidCallback onExpand;
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

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: _sidebarColor,
        child: InkWell(
          onTap: widget.collapsed ? widget.onExpand : _toggleMenu,
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
                    child: BusinessAvatar(
                      name: widget.companyName,
                      seed: widget.avatarSeed,
                      logoUrl: widget.logoUrl,
                      diameter: 32,
                    ),
                  )
                : Row(
                    children: [
                      BusinessAvatar(
                        name: widget.companyName,
                        seed: widget.avatarSeed,
                        logoUrl: widget.logoUrl,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: const TextStyle(
                                color: _sidebarTextActive,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Current Company',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                color: _sidebarText,
                                fontSize: 11,
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

class _ShellShortcutScope extends ConsumerWidget {
  const _ShellShortcutScope({
    required this.quickCreateEnabled,
    required this.shortcutFocusNode,
    required this.child,
  });

  final bool quickCreateEnabled;
  final FocusNode shortcutFocusNode;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: {
        ...buildQuickCreateShortcuts(),
        ...buildSearchShortcuts(),
      },
      child: Actions(
        actions: {
          ToggleQuickCreateIntent: CallbackAction<ToggleQuickCreateIntent>(
            onInvoke: (_) {
              if (!quickCreateEnabled || shouldSuppressQuickCreateShortcuts()) {
                return null;
              }
              ref.read(quickCreateMenuProvider).toggle();
              return null;
            },
          ),
          DismissQuickCreateIntent: CallbackAction<DismissQuickCreateIntent>(
            onInvoke: (_) {
              if (ref.read(quickCreateMenuProvider).isOpen) {
                ref.read(quickCreateMenuProvider).close();
              }
              return null;
            },
          ),
          ExecuteQuickCreateIntent: CallbackAction<ExecuteQuickCreateIntent>(
            onInvoke: (intent) {
              if (!quickCreateEnabled || shouldSuppressQuickCreateShortcuts()) {
                return null;
              }
              final action = QuickCreateActions.byId(intent.actionId);
              if (action == null) return null;
              if (ref.read(quickCreateMenuProvider).isOpen) {
                ref.read(quickCreateMenuProvider).close();
              }
              executeQuickCreate(context, ref, action);
              return null;
            },
          ),
          OpenSearchDialogIntent: CallbackAction<OpenSearchDialogIntent>(
            onInvoke: (_) {
              if (shouldSuppressSearchShortcuts()) return null;
              ref.read(searchDialogProvider.notifier).open(context);
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: shortcutFocusNode,
          autofocus: true,
          canRequestFocus: true,
          child: child,
        ),
      ),
    );
  }
}
