import 'dart:async';

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:billing_baba/features/business/utils/switch_company_debug_log.dart';
import 'package:billing_baba/features/collaboration/application/navigation_permission_registry.dart';
import 'package:billing_baba/features/collaboration/application/permission_service.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/models/collaboration_sub_route.dart';
import 'package:billing_baba/features/crm/models/crm_sub_route.dart';
import 'package:billing_baba/features/dashboard/application/quick_create_executor.dart';
import 'package:billing_baba/features/dashboard/application/quick_create_menu_provider.dart';
import 'package:billing_baba/features/dashboard/application/shell_sidebar_provider.dart';
import 'package:billing_baba/features/dashboard/models/quick_create_action.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/app_top_bar.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/quick_create_menu.dart';
import 'package:billing_baba/features/parties/parties_navigation.dart';
import 'package:billing_baba/features/pos/application/pos_session_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_sub_route.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
import 'package:billing_baba/features/search/application/search_dialog_provider.dart';
import 'package:billing_baba/features/search/application/search_route_observer.dart';
import 'package:billing_baba/features/search/application/search_shortcuts_handler.dart';
import 'package:billing_baba/features/tasks/application/task_completion_undo_redo_provider.dart';
import 'package:billing_baba/features/tasks/presentation/task_undo_redo_snackbar.dart';
import 'package:billing_baba/features/tasks/presentation/task_undo_redo_shortcuts.dart';
import 'package:billing_baba/features/search/presentation/desktop/search_dialog.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/shared/widgets/desktop_bidirectional_scroll.dart';
import 'package:billing_baba/features/utilities/models/utilities_sub_route.dart';
import 'package:billing_baba/shared/image/image_startup_warmup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Visual tokens for the desktop sidebar chrome.
abstract final class _SidebarTokens {
  static const background = Color(0xFF1C2333);

  /// Pearl white — sidebar nav labels (Home, Parties, …).
  static const text = Color(0xFFFDFCFA);
  static const textActive = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF94A3B8);
  static const searchField = Color(0xFF141B27);
  static const hover = Color(0x0FFFFFFF);
  static const divider = Color(0xFF2A3447);

  static const home = Color(0xFF818CF8);
  static const parties = Color(0xFF34D399);
  static const crm = Color(0xFF38BDF8);
  static const items = Color(0xFFA78BFA);
  static const sale = Color(0xFFF472B6);
  static const pos = Color(0xFFFB923C);
  static const purchase = Color(0xFF2DD4BF);
  static const reports = Color(0xFF3B82F6);
  static const sync = Color(0xFFA78BFA);
  static const utilities = Color(0xFFFBBF24);
  static const developer = Color(0xFFC4B5FD);
  static const settings = Color(0xFF94A3B8);
  static const plans = Color(0xFFF472B6);
  static const saleScreen = Color(0xFF60A5FA);

  static const activeGradient = LinearGradient(
    colors: [Color(0xFF6338E0), Color(0xFF5B4FCF)],
  );

  static const activeGlow = [
    BoxShadow(
      color: Color(0x406338E0),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

String _searchShortcutBadge() {
  return AppPlatform.current.isMacOS ? '⌘F' : 'Ctrl+F';
}

/// Expanded desktop sidebar width — fits longest nav labels (e.g. Purchase & Expense).
const _desktopSidebarExpandedWidth = 256.0;

/// Desktop app shell with collapsible sidebar and top action bar.
class DesktopShell extends ConsumerStatefulWidget {
  const DesktopShell({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends ConsumerState<DesktopShell> {
  static const _sidebarExpandedWidth = _desktopSidebarExpandedWidth;
  static const _sidebarCollapsedWidth = 60.0;
  static const _sidebarCompactLayoutMaxWidth = 140.0;
  static const _overlayBreakpoint = 800.0;

  /// Sidebar content toggles immediately on collapse, but [AnimatedContainer]
  /// width animates over 200ms — use compact layout until there is room.
  static bool _useCompactSidebarLayout(bool collapsed, double width) {
    return collapsed || width < _sidebarCompactLayoutMaxWidth;
  }

  static const Color _sidebarColor = _SidebarTokens.background;
  static const Color _sidebarText = _SidebarTokens.text;

  bool _isSaleExpanded = false;
  bool _isPurchaseExpanded = false;
  bool _expandInitialized = false;
  bool _isCrmExpanded = false;
  bool _crmExpandInitialized = false;
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
  SearchDialogNotifier? _searchDialogNotifier;

  @override
  void initState() {
    super.initState();
    _searchDialogNotifier = ref.read(searchDialogProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerSearchDialog();
      _ensureShellShortcutFocus();
      final businessId = ref.read(sidebarBusinessProvider).id;
      if (businessId != null && businessId.isNotEmpty) {
        unawaited(
          ref.read(imageStartupWarmupProvider).run(businessId: businessId),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchDialogNotifier?.unregister();
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
    var isOpen = false;
    ref
        .read(searchDialogProvider.notifier)
        .register(
          open: (context) {
            if (isOpen) return;
            isOpen = true;
            showSearchDialog(context, ref).whenComplete(() => isOpen = false);
          },
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_expandInitialized) {
      _expandInitialized = true;
      final location = GoRouterState.of(context).uri.path;
      if (_isSaleGroupLocation(location)) {
        _isSaleExpanded = true;
      }
      if (location.startsWith(AppRoutes.purchase)) {
        _isPurchaseExpanded = true;
      }
    }
    if (!_crmExpandInitialized) {
      _crmExpandInitialized = true;
      final location = GoRouterState.of(context).uri.path;
      if (location.startsWith(AppRoutes.crm)) {
        _isCrmExpanded = true;
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

  static bool _isSettingsLocation(String location) {
    return location.startsWith(AppRoutes.settings) ||
        location == AppRoutes.itemsSettings;
  }

  static final List<_NavSubItem> _crmSubItems = CrmSubRoutes.items
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
      icon: LucideIcons.house,
      iconColor: _SidebarTokens.home,
      label: 'Home',
    ),
    const _NavItem(
      route: AppRoutes.partyDetails,
      icon: LucideIcons.users,
      iconColor: _SidebarTokens.parties,
      label: 'Parties',
    ),
    _NavItem(
      icon: LucideIcons.heartHandshake,
      iconColor: _SidebarTokens.crm,
      label: 'CRM',
      isExpandable: true,
      routePrefix: AppRoutes.crm,
      subItems: _crmSubItems,
    ),
    const _NavItem(
      route: AppRoutes.items,
      icon: LucideIcons.package,
      iconColor: _SidebarTokens.items,
      label: 'Items',
    ),
    _NavItem(
      icon: LucideIcons.receipt,
      iconColor: _SidebarTokens.sale,
      label: 'Sale',
      isExpandable: true,
      routePrefix: AppRoutes.sale,
      subItems: _saleSubItems,
    ),
    if (!ShellSidebarVisibility.hidePos)
      const _NavItem(
        route: AppRoutes.pos,
        icon: Icons.point_of_sale_outlined,
        iconColor: _SidebarTokens.pos,
        label: 'POS',
      ),
    _NavItem(
      icon: LucideIcons.shoppingCart,
      iconColor: _SidebarTokens.purchase,
      label: 'Purchase & Expense',
      isExpandable: true,
      routePrefix: AppRoutes.purchase,
      subItems: _purchaseSubItems,
    ),
    const _NavItem(
      route: AppRoutes.reports,
      icon: LucideIcons.chartColumn,
      iconColor: _SidebarTokens.reports,
      label: 'Reports',
    ),
    if (!ShellSidebarVisibility.hideCollaboration)
      _NavItem(
        icon: LucideIcons.refreshCw,
        iconColor: _SidebarTokens.sync,
        label: 'Sync & Share',
        isExpandable: true,
        routePrefix: AppRoutes.collaboration,
        subItems: _collaborationSubItems,
      ),
    if (!ShellSidebarVisibility.hideUtilities)
      _NavItem(
        icon: LucideIcons.wrench,
        iconColor: _SidebarTokens.utilities,
        label: 'Utilities',
        isExpandable: true,
        routePrefix: AppRoutes.utilities,
        subItems: _utilitiesSubItems,
      ),
    if (!ShellSidebarVisibility.hideDeveloper)
      _NavItem(
        icon: LucideIcons.code,
        iconColor: _SidebarTokens.developer,
        label: 'Developer',
        isExpandable: true,
        routePrefix: AppRoutes.developer,
        subItems: _developerSubItems,
      ),
    if (!ShellSidebarVisibility.hideSettings)
      const _NavItem(
        route: AppRoutes.settingsGeneral,
        icon: LucideIcons.settings,
        iconColor: _SidebarTokens.settings,
        label: 'Settings',
      ),
    const _NavItem(
      route: AppRoutes.plansPricing,
      icon: LucideIcons.award,
      iconColor: _SidebarTokens.plans,
      label: 'Plans & Pricing',
    ),
    const _NavItem(
      route: AppRoutes.saleScreen,
      icon: LucideIcons.layoutGrid,
      iconColor: _SidebarTokens.saleScreen,
      label: 'Sale Screen',
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

    var subItems = item.subItems
        .where(
          (sub) =>
              NavigationPermissionRegistry.isVisible(sub.route, permissions),
        )
        .toList();
    final general = ref.watch(generalSettingsProvider).value;
    if (general != null &&
        (item.routePrefix == AppRoutes.sale ||
            item.routePrefix == AppRoutes.purchase)) {
      subItems = subItems
          .where((sub) => general.isNavRouteVisible(sub.route))
          .toList();
    }
    if (subItems.isEmpty) return null;

    return _NavItem(
      icon: item.icon,
      iconColor: item.iconColor,
      label: item.label,
      route: item.route,
      routePrefix: item.routePrefix,
      isExpandable: item.isExpandable,
      subItems: subItems,
    );
  }

  /// `/sale/...` documents only. `/sale-screen` must not open the Sale group.
  bool _isSaleGroupLocation(String location) {
    return location == AppRoutes.sale ||
        location.startsWith('${AppRoutes.sale}/');
  }

  void _navigateTo(String route) {
    final overlayLayout = _useOverlaySidebar;
    final sidebarNotifier = ref.read(shellSidebarProvider.notifier);

    if (route == AppRoutes.partyDetails) {
      PartiesNavigation.prepareSidebarEntry(ref);
    }

    setState(() {
      _isSaleExpanded = _isSaleGroupLocation(route);
      _isPurchaseExpanded = route.startsWith(AppRoutes.purchase);
      _isCrmExpanded = route.startsWith(AppRoutes.crm);
      _isUtilitiesExpanded = route.startsWith(AppRoutes.utilities);
      _isCollaborationExpanded = route.startsWith(AppRoutes.collaboration);
      _isDeveloperExpanded = route.startsWith(AppRoutes.developer);
    });
    context.go(route);
    _scheduleSidebarCloseAfterNavigation(
      sidebarNotifier: sidebarNotifier,
      overlayLayout: overlayLayout,
    );
  }

  /// Closes the overlay drawer after navigation so provider listeners on the
  /// shell subtree are not notified while the tap handler is still unwinding.
  /// Persistent desktop sidebars are left as-is (manual collapse only).
  void _scheduleSidebarCloseAfterNavigation({
    required ShellSidebar sidebarNotifier,
    required bool overlayLayout,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sidebarNotifier.closeOnNavigation(overlayLayout: overlayLayout);
    });
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
    // Bootstrap is owned by [createAppRouter] (ref.watch there). Watching it
    // again here is redundant and pulled session/auth listen churn into shell
    // rebuilds during company open.
    final permissions = ref.watch(permissionServiceProvider);

    if (AppRoutes.isSaleInvoiceFormRoute(currentLocation)) {
      return Scaffold(
        body: _ShellShortcutScope(
          quickCreateEnabled: false,
          shortcutFocusNode: _shellShortcutFocusNode,
          child: ColoredBox(
            color: AppColors.background,
            child: widget.child,
          ),
        ),
      );
    }

    return _ShellSidebarStateScope(
      builder: (isCollapsed, isDrawerOpen, sidebarNotifier) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final useOverlaySidebar = constraints.maxWidth < _overlayBreakpoint;
            _useOverlaySidebar = useOverlaySidebar;

            if (_wasOverlaySidebar == true &&
                !useOverlaySidebar &&
                isDrawerOpen) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                sidebarNotifier.closeDrawer();
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
                    if (showTopBar)
                      AppTopBar(showMenuButton: useOverlaySidebar),
                    Expanded(child: _ScaledShellContent(child: widget.child)),
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
                          onTap: sidebarNotifier.closeDrawer,
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
                          sidebarNotifier: sidebarNotifier,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              body: _PersistentSidebarLayout(
                sidebarExpandedWidth: _sidebarExpandedWidth,
                sidebarCollapsedWidth: _sidebarCollapsedWidth,
                isCollapsed: isCollapsed,
                sidebarColor: _sidebarColor,
                onToggle: sidebarNotifier.toggleCollapsed,
                onSidebarTap: isCollapsed ? sidebarNotifier.expand : null,
                sidebar: _buildSidebarPanel(
                  currentLocation: currentLocation,
                  collapsed: isCollapsed,
                  permissions: permissions,
                  sidebarNotifier: sidebarNotifier,
                ),
                mainContent: mainContent,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSidebarPanel({
    required String currentLocation,
    required bool collapsed,
    required PermissionService permissions,
    required ShellSidebar sidebarNotifier,
    bool showCloseButton = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactLayout = _useCompactSidebarLayout(
          collapsed,
          constraints.maxWidth,
        );

        return _SidebarHoverRegion(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSidebarHeader(
                collapsed: compactLayout,
                showCloseButton: showCloseButton,
                sidebarNotifier: sidebarNotifier,
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
          ),
        );
      },
    );
  }

  Widget _buildSidebarHeader({
    required bool collapsed,
    required ShellSidebar sidebarNotifier,
    bool showCloseButton = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: collapsed
          ? InkWell(
              onTap: () =>
                  ref.read(searchDialogProvider.notifier).open(context),
              borderRadius: AppRadius.mdBorder,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Icon(
                  LucideIcons.search,
                  color: _sidebarText,
                  size: AppIconSize.md,
                ),
              ),
            )
          : Row(
              children: [
                if (showCloseButton)
                  IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      color: _sidebarText,
                      size: AppIconSize.md,
                    ),
                    onPressed: sidebarNotifier.closeDrawer,
                    tooltip: 'Close menu',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                Expanded(
                  child: Material(
                    color: _SidebarTokens.searchField,
                    borderRadius: AppRadius.searchBorder,
                    child: InkWell(
                      onTap: () =>
                          ref.read(searchDialogProvider.notifier).open(context),
                      borderRadius: AppRadius.searchBorder,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.search,
                              color: _SidebarTokens.textMuted,
                              size: AppIconSize.sm,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Expanded(
                              child: Text(
                                'Search',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _SidebarTokens.textMuted,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _searchShortcutBadge(),
                                style: const TextStyle(
                                  color: _SidebarTokens.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
    return _SidebarNavScroll(
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
      final isCrm = item.routePrefix == AppRoutes.crm;
      final isUtilities = item.routePrefix == AppRoutes.utilities;
      final isCollaboration = item.routePrefix == AppRoutes.collaboration;
      final isDeveloper = item.routePrefix == AppRoutes.developer;
      final routePrefix = item.routePrefix ?? item.route!;

      final isParentActive = isSale
          ? _isSaleGroupLocation(currentLocation)
          : isPurchase
          ? currentLocation.startsWith(AppRoutes.purchase)
          : isCrm
          ? currentLocation.startsWith(AppRoutes.crm)
          : isUtilities
          ? currentLocation.startsWith(AppRoutes.utilities)
          : isCollaboration
          ? currentLocation.startsWith(AppRoutes.collaboration)
          : isDeveloper
          ? currentLocation.startsWith(AppRoutes.developer)
          : false;

      final isExpanded = isSale
          ? _isSaleExpanded
          : isPurchase
          ? _isPurchaseExpanded
          : isCrm
          ? _isCrmExpanded
          : isUtilities
          ? _isUtilitiesExpanded
          : isCollaboration
          ? _isCollaborationExpanded
          : isDeveloper
          ? _isDeveloperExpanded
          : false;

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
              } else if (isCrm) {
                _isCrmExpanded = !_isCrmExpanded;
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
                } else if (isCrm) {
                  _isCrmExpanded = true;
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
            (item.route == AppRoutes.partyDetails &&
                currentLocation.startsWith(AppRoutes.parties)) ||
            (item.route == AppRoutes.reports &&
                currentLocation.startsWith(AppRoutes.reports)) ||
            (item.route == AppRoutes.settingsGeneral &&
                _isSettingsLocation(currentLocation)));

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
              currentLocation.startsWith('${AppRoutes.viewSale}/') ||
              currentLocation.startsWith('${AppRoutes.duplicateSale}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.saleEstimateQuotation &&
          (currentLocation == AppRoutes.addEstimate ||
              currentLocation.startsWith('${AppRoutes.editEstimate}/') ||
              currentLocation.startsWith('${AppRoutes.duplicateEstimate}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.saleProformaInvoice &&
          (currentLocation == AppRoutes.addProforma ||
              currentLocation.startsWith('${AppRoutes.editProforma}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.saleOrder &&
          (currentLocation == AppRoutes.addSaleOrder ||
              currentLocation.startsWith('${AppRoutes.editSaleOrder}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.saleDeliveryChallan &&
          (currentLocation == AppRoutes.addDeliveryChallan ||
              currentLocation.startsWith('${AppRoutes.editDeliveryChallan}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.saleReturnCreditNote &&
          (currentLocation == AppRoutes.addCreditNote ||
              currentLocation.startsWith('${AppRoutes.editCreditNote}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.saleFa &&
          (currentLocation == AppRoutes.addSaleFa ||
              currentLocation.startsWith('${AppRoutes.editSaleFa}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.saleJobWorkOut &&
          (currentLocation == AppRoutes.addJobWork ||
              currentLocation.startsWith('${AppRoutes.editJobWork}/'))) {
        return true;
      }
      if (subRoute == AppRoutes.otherIncome &&
          (currentLocation == AppRoutes.addOtherIncome ||
              currentLocation.startsWith('${AppRoutes.editOtherIncome}/'))) {
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
        SwitchCompanyDebugLog.action('ShellPage.onSwitchCompany');
        await switchToBusinessSelection(
          ref,
          navigateToBusinessList: () async {
            if (mounted) {
              SwitchCompanyDebugLog.nav('ShellPage _navigateTo(businessList)');
              _navigateTo(AppRoutes.businessList);
            }
          },
        );
      },
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (mounted) _navigateTo(AppRoutes.login);
      },
    );
  }
}

/// Tracks pointer hover anywhere on the sidebar panel (nav scrollbar visibility).
class _SidebarHoverScope extends InheritedWidget {
  const _SidebarHoverScope({
    required this.isHovered,
    required super.child,
  });

  final bool isHovered;

  static bool isHoveredOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_SidebarHoverScope>()
            ?.isHovered ??
        false;
  }

  @override
  bool updateShouldNotify(_SidebarHoverScope oldWidget) {
    return isHovered != oldWidget.isHovered;
  }
}

class _SidebarHoverRegion extends StatefulWidget {
  const _SidebarHoverRegion({required this.child});

  final Widget child;

  @override
  State<_SidebarHoverRegion> createState() => _SidebarHoverRegionState();
}

class _SidebarHoverRegionState extends State<_SidebarHoverRegion> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: _SidebarHoverScope(
        isHovered: _isHovered,
        child: widget.child,
      ),
    );
  }
}

class _SidebarNavScroll extends StatefulWidget {
  const _SidebarNavScroll({required this.child});

  final Widget child;

  @override
  State<_SidebarNavScroll> createState() => _SidebarNavScrollState();
}

/// Suppresses the platform scrollbar on the sidebar nav; we paint our own on hover.
class _SidebarNavScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _SidebarNavScrollState extends State<_SidebarNavScroll> {
  static const _thicknessHovered = 10.0;

  /// Ignore sub-pixel layout noise that would show a scrollbar with nothing to scroll.
  static const _scrollExtentEpsilon = 1.0;

  late final ScrollController _scrollController = ScrollController();
  var _hasOverflow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncOverflowState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverflowState());
  }

  @override
  void didUpdateWidget(covariant _SidebarNavScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverflowState());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncOverflowState);
    _scrollController.dispose();
    super.dispose();
  }

  void _syncOverflowState() {
    if (!mounted || !_scrollController.hasClients) return;
    final hasOverflow =
        _scrollController.position.maxScrollExtent > _scrollExtentEpsilon;
    if (hasOverflow == _hasOverflow) return;
    setState(() => _hasOverflow = hasOverflow);
  }

  @override
  Widget build(BuildContext context) {
    final hovered = _SidebarHoverScope.isHoveredOf(context);
    final showScrollbar = hovered && _hasOverflow;

    final scrollView = NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _syncOverflowState();
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        physics: _hasOverflow
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: widget.child,
      ),
    );

    return ScrollConfiguration(
      behavior: _SidebarNavScrollBehavior(),
      child: showScrollbar
          ? ScrollbarTheme(
              data: ScrollbarThemeData(
                thickness: WidgetStateProperty.all(_thicknessHovered),
                radius: const Radius.circular(6),
                thumbColor: WidgetStateProperty.all(const Color(0x8FFFFFFF)),
                trackColor: WidgetStateProperty.all(const Color(0x14FFFFFF)),
                thumbVisibility: WidgetStateProperty.all(true),
                trackVisibility: WidgetStateProperty.all(true),
                interactive: true,
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: scrollView,
              ),
            )
          : scrollView,
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.route,
    this.routePrefix,
    this.isExpandable = false,
    this.subItems = const [],
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? route;
  final String? routePrefix;
  final bool isExpandable;
  final List<_NavSubItem> subItems;
}

class _NavSubItem {
  const _NavSubItem({
    required this.route,
    required this.label,
  });

  final String route;
  final String label;
}

class _SidebarTileSurface extends StatelessWidget {
  const _SidebarTileSurface({
    required this.isActive,
    required this.child,
    this.onTap,
    this.horizontalPadding,
    this.verticalPadding,
  });

  final bool isActive;
  final Widget child;
  final VoidCallback? onTap;
  final double? horizontalPadding;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          boxShadow: isActive ? _SidebarTokens.activeGlow : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.mdBorder,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdBorder,
            hoverColor: isActive ? Colors.transparent : _SidebarTokens.hover,
            splashColor: isActive
                ? Colors.white.withValues(alpha: 0.08)
                : _SidebarTokens.hover,
            highlightColor: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: isActive ? _SidebarTokens.activeGradient : null,
                borderRadius: AppRadius.mdBorder,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding ?? AppSpacing.md,
                  vertical: verticalPadding ?? AppSpacing.sm + 2,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? _SidebarTokens.textActive : item.iconColor;
    final labelColor = isActive
        ? _SidebarTokens.textActive
        : _SidebarTokens.text;

    return _SidebarTileSurface(
      isActive: isActive,
      onTap: collapsed ? onCollapsedTap : onToggle,
      horizontalPadding: collapsed ? 4 : AppSpacing.md,
      child: collapsed
          ? Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  item.icon,
                  color: iconColor,
                  size: AppIconSize.md,
                ),
              ),
            )
          : Row(
              children: [
                Icon(
                  item.icon,
                  color: iconColor,
                  size: AppIconSize.md,
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    LucideIcons.chevronDown,
                    color: isActive
                        ? _SidebarTokens.textActive
                        : _SidebarTokens.text,
                    size: AppIconSize.md,
                  ),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return _SidebarTileSurface(
      isActive: isActive,
      onTap: onTap,
      verticalPadding: AppSpacing.sm,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? _SidebarTokens.textActive
                : _SidebarTokens.text,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
          overflow: TextOverflow.ellipsis,
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

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? _SidebarTokens.textActive : item.iconColor;
    final labelColor = isActive
        ? _SidebarTokens.textActive
        : _SidebarTokens.text;

    return _SidebarTileSurface(
      isActive: isActive,
      onTap: onTap,
      horizontalPadding: collapsed ? 4 : AppSpacing.md,
      child: collapsed
          ? Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  item.icon,
                  color: iconColor,
                  size: AppIconSize.md,
                ),
              ),
            )
          : Row(
              children: [
                Icon(
                  item.icon,
                  color: iconColor,
                  size: AppIconSize.md,
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
  static const Color _sidebarColor = _SidebarTokens.background;
  static const Color _sidebarText = _SidebarTokens.text;
  static const Color _sidebarTextActive = _SidebarTokens.textActive;

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
              border: Border(top: BorderSide(color: _SidebarTokens.divider)),
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
                          LucideIcons.chevronDown,
                          color: _sidebarText,
                          size: AppIconSize.md,
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
        width: _desktopSidebarExpandedWidth,
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

/// Persistent desktop row: sidebar + content, with a hover-revealed edge tab
/// painted above the content area so it stays clickable on the border.
class _PersistentSidebarLayout extends StatefulWidget {
  const _PersistentSidebarLayout({
    required this.sidebarExpandedWidth,
    required this.sidebarCollapsedWidth,
    required this.isCollapsed,
    required this.sidebarColor,
    required this.onToggle,
    required this.onSidebarTap,
    required this.sidebar,
    required this.mainContent,
  });

  final double sidebarExpandedWidth;
  final double sidebarCollapsedWidth;
  final bool isCollapsed;
  final Color sidebarColor;
  final VoidCallback onToggle;
  final VoidCallback? onSidebarTap;
  final Widget sidebar;
  final Widget mainContent;

  @override
  State<_PersistentSidebarLayout> createState() =>
      _PersistentSidebarLayoutState();
}

class _PersistentSidebarLayoutState extends State<_PersistentSidebarLayout> {
  static const _animationDuration = Duration(milliseconds: 200);
  static const _handleTop = 34.0;
  static const _handleProtrude = 12.0;

  bool _sidebarHovered = false;
  bool _handleHovered = false;

  bool get _handleVisible => _sidebarHovered || _handleHovered;

  double get _sidebarWidth => widget.isCollapsed
      ? widget.sidebarCollapsedWidth
      : widget.sidebarExpandedWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: _animationDuration,
              curve: Curves.easeInOut,
              width: _sidebarWidth,
              color: widget.sidebarColor,
              child: MouseRegion(
                onEnter: (_) => setState(() => _sidebarHovered = true),
                onExit: (_) => setState(() => _sidebarHovered = false),
                child: GestureDetector(
                  onTap: widget.onSidebarTap,
                  behavior: HitTestBehavior.translucent,
                  child: widget.sidebar,
                ),
              ),
            ),
            Expanded(child: widget.mainContent),
          ],
        ),
        AnimatedPositioned(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          left: _sidebarWidth - _handleProtrude,
          top: _handleTop,
          child: MouseRegion(
            onEnter: (_) => setState(() => _handleHovered = true),
            onExit: (_) => setState(() => _handleHovered = false),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IgnorePointer(
                ignoring: !_handleVisible,
                child: AnimatedOpacity(
                  opacity: _handleVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Tooltip(
                    message: widget.isCollapsed
                        ? 'Expand sidebar'
                        : 'Collapse sidebar',
                    child: Material(
                      color: _SidebarTokens.background,
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        onTap: widget.onToggle,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 22,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _SidebarTokens.divider),
                          ),
                          child: Icon(
                            widget.isCollapsed
                                ? LucideIcons.chevronRight
                                : LucideIcons.chevronLeft,
                            size: 16,
                            color: _SidebarTokens.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShellSidebarStateScope extends ConsumerWidget {
  const _ShellSidebarStateScope({
    required this.builder,
  });

  final Widget Function(
    bool isCollapsed,
    bool isDrawerOpen,
    ShellSidebar sidebarNotifier,
  )
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarState = ref.watch(shellSidebarProvider);
    final sidebarNotifier = ref.read(shellSidebarProvider.notifier);
    return builder(
      sidebarState.isCollapsed,
      sidebarState.isDrawerOpen,
      sidebarNotifier,
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
        ...buildTaskCompletionUndoRedoShortcuts(),
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
              ref.read(searchDialogProvider.notifier).open(context);
              return null;
            },
          ),
          TaskCompletionUndoIntent: CallbackAction<TaskCompletionUndoIntent>(
            onInvoke: (_) {
              if (shouldSuppressTaskCompletionUndoRedoShortcuts()) {
                return null;
              }
              if (!ref.read(taskCompletionUndoRedoProvider).canUndo) {
                return null;
              }
              performTaskCompletionUndo(context: context, ref: ref);
              return null;
            },
          ),
          TaskCompletionRedoIntent: CallbackAction<TaskCompletionRedoIntent>(
            onInvoke: (_) {
              if (shouldSuppressTaskCompletionUndoRedoShortcuts()) {
                return null;
              }
              if (!ref.read(taskCompletionUndoRedoProvider).canRedo) {
                return null;
              }
              performTaskCompletionRedo(context: context, ref: ref);
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

class _ScaledShellContent extends ConsumerWidget {
  const _ScaledShellContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(desktopUiScaleProvider);
    if (scale == 1.0) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewW = constraints.maxWidth;
        final viewH = constraints.maxHeight;
        if (viewW <= 0 ||
            viewH <= 0 ||
            !viewW.isFinite ||
            !viewH.isFinite) {
          return child;
        }

        final logicalW = viewW / scale;
        final logicalH = viewH / scale;

        return DesktopBidirectionalScroll(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            filterQuality: FilterQuality.medium,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: logicalW,
                maxWidth: logicalW,
                minHeight: logicalH,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
