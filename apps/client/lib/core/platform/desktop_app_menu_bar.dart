import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/platform/desktop_menu_actions.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/customer_support_strip.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Desktop application menu — native [PlatformMenuBar] on macOS, Material
/// [MenuBar] on Windows/Linux (Flutter has no in-engine Windows HMENU plugin).
class DesktopAppMenuBar extends ConsumerStatefulWidget {
  const DesktopAppMenuBar({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DesktopAppMenuBar> createState() => _DesktopAppMenuBarState();
}

class _DesktopAppMenuBarState extends ConsumerState<DesktopAppMenuBar> {
  DesktopVersionInfo _versions = DesktopVersionInfo.empty;

  /// Full-window overlay so MenuBar submenu portals are not clipped to the
  /// compact chrome strip (that made menus look like empty white gaps).
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  late final OverlayEntry _shellEntry;

  /// Compact style for MenuBar labels only (not dropdown items).
  static const _barButtonStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    ),
    minimumSize: WidgetStatePropertyAll(
      Size(0, DashboardSpacing.menuBarHeight),
    ),
    maximumSize: WidgetStatePropertyAll(
      Size(double.infinity, DashboardSpacing.menuBarHeight),
    ),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  /// Even row height + padding for dropdown [MenuItemButton]s.
  static const _menuItemStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    minimumSize: WidgetStatePropertyAll(Size(180, 32)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    alignment: Alignment.centerLeft,
  );

  static const _submenuPanelStyle = MenuStyle(
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
  );

  /// Thin group separator — default [Divider] height (16) made gaps uneven.
  static const _menuSeparator = Divider(height: 8, thickness: 1);

  @override
  void initState() {
    super.initState();
    _shellEntry = OverlayEntry(builder: _buildWindowsShell);
    unawaited(_loadVersions());
  }

  Future<void> _loadVersions() async {
    final info = await DesktopMenuActions.loadVersionInfo();
    if (!mounted) return;
    setState(() => _versions = info);
  }

  Widget _buildWindowsShell(BuildContext context) {
    final host = _DesktopMenuBarHost.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            height: DashboardSpacing.menuBarHeight,
            child: Theme(
              data: Theme.of(context).copyWith(
                menuButtonTheme: const MenuButtonThemeData(
                  style: _menuItemStyle,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: MenuBar(
                      style: const MenuStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        elevation: WidgetStatePropertyAll(0),
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 2),
                        ),
                        minimumSize: WidgetStatePropertyAll(
                          Size(0, DashboardSpacing.menuBarHeight),
                        ),
                        maximumSize: WidgetStatePropertyAll(
                          Size(double.infinity, DashboardSpacing.menuBarHeight),
                        ),
                      ),
                      children: _materialMenus(
                        canBusiness: host.canBusiness,
                        canLogout: host.canLogout,
                      ),
                    ),
                  ),
                  const CustomerSupportStrip(compact: true),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: host.appChild),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !AppPlatform.current.isDesktop) {
      return widget.child;
    }

    final auth = ref.watch(authProvider);
    final canBusiness = DesktopMenuActions.canUseBusinessActions(auth);
    final canLogout = DesktopMenuActions.canLogout(auth);

    if (AppPlatform.current.isMacOS) {
      return PlatformMenuBar(
        menus: _platformMenus(
          canBusiness: canBusiness,
          canLogout: canLogout,
        ),
        // Native menu cannot host custom widgets; keep support under it.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomerSupportStrip(),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // MenuBar requires an Overlay ancestor. MaterialApp.builder wraps the
    // Navigator, so provide a full-size Overlay here (not only the chrome strip).
    return _DesktopMenuBarHost(
      appChild: widget.child,
      canBusiness: canBusiness,
      canLogout: canLogout,
      versions: _versions,
      child: Overlay(
        key: _overlayKey,
        clipBehavior: Clip.none,
        initialEntries: [_shellEntry],
      ),
    );
  }

  List<PlatformMenuItem> _platformMenus({
    required bool canBusiness,
    required bool canLogout,
  }) {
    return [
      PlatformMenu(
        label: AppConfig.appName,
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Switch Business',
                onSelected: canBusiness
                    ? () => unawaited(DesktopMenuActions.switchBusiness(ref))
                    : null,
              ),
              PlatformMenuItem(
                label: 'Rename Business',
                onSelected: canBusiness
                    ? () => DesktopMenuActions.renameBusiness(ref)
                    : null,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Settings',
                onSelected: canBusiness
                    ? () => DesktopMenuActions.openSettings(ref)
                    : null,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Logout',
                onSelected: canLogout
                    ? () => unawaited(DesktopMenuActions.logout(ref))
                    : null,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Quit Billing Baba',
                onSelected: () => unawaited(DesktopMenuActions.quit()),
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: 'Help',
        menus: [
          PlatformMenuItem(
            label: 'Documentation',
            onSelected: () => unawaited(DesktopMenuActions.openDocumentation()),
          ),
          PlatformMenuItem(
            label: 'Contact Support',
            onSelected: () =>
                unawaited(DesktopMenuActions.openContactSupport()),
          ),
          PlatformMenuItem(
            label: 'Report an Issue',
            onSelected: () => unawaited(DesktopMenuActions.reportIssue()),
          ),
          PlatformMenuItem(
            label: 'Privacy Policy',
            onSelected: () => unawaited(DesktopMenuActions.openPrivacyPolicy()),
          ),
        ],
      ),
      PlatformMenu(
        label: 'Versions',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Application Version ${_versions.applicationVersion}',
              ),
              PlatformMenuItem(
                label: 'Build Version ${_versions.buildVersion}',
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'About Billing Baba',
                onSelected: () => DesktopMenuActions.openAbout(ref),
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: 'Edit',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Undo',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyZ,
                  meta: true,
                ),
                onSelected: () => _invokeEditIntent(
                  const UndoTextIntent(SelectionChangedCause.toolbar),
                ),
              ),
              PlatformMenuItem(
                label: 'Redo',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyZ,
                  meta: true,
                  shift: true,
                ),
                onSelected: () => _invokeEditIntent(
                  const RedoTextIntent(SelectionChangedCause.toolbar),
                ),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Cut',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyX,
                  meta: true,
                ),
                onSelected: () => _invokeEditIntent(
                  const CopySelectionTextIntent.cut(
                    SelectionChangedCause.toolbar,
                  ),
                ),
              ),
              PlatformMenuItem(
                label: 'Copy',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyC,
                  meta: true,
                ),
                onSelected: () => _invokeEditIntent(
                  CopySelectionTextIntent.copy,
                ),
              ),
              PlatformMenuItem(
                label: 'Paste',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyV,
                  meta: true,
                ),
                onSelected: () => _invokeEditIntent(
                  const PasteTextIntent(SelectionChangedCause.toolbar),
                ),
              ),
              PlatformMenuItem(
                label: 'Select All',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyA,
                  meta: true,
                ),
                onSelected: () => _invokeEditIntent(
                  const SelectAllTextIntent(SelectionChangedCause.toolbar),
                ),
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: 'Reload',
        menus: [
          PlatformMenuItem(
            label: 'Reload app',
            onSelected: () => unawaited(DesktopMenuActions.reload(ref)),
          ),
        ],
      ),
    ];
  }

  static void _invokeEditIntent(Intent intent) {
    final primary = FocusManager.instance.primaryFocus?.context;
    if (primary != null) {
      Actions.maybeInvoke(primary, intent);
    }
  }

  SubmenuButton _submenu({
    required Widget label,
    required List<Widget> menuChildren,
  }) {
    return SubmenuButton(
      style: _barButtonStyle,
      menuStyle: _submenuPanelStyle,
      menuChildren: menuChildren,
      child: label,
    );
  }

  List<Widget> _materialMenus({
    required bool canBusiness,
    required bool canLogout,
  }) {
    return [
      _submenu(
        label: const Text(AppConfig.appName),
        menuChildren: [
          MenuItemButton(
            onPressed: canBusiness
                ? () => unawaited(DesktopMenuActions.switchBusiness(ref))
                : null,
            child: const Text('Switch Business'),
          ),
          MenuItemButton(
            onPressed: canBusiness
                ? () => DesktopMenuActions.renameBusiness(ref)
                : null,
            child: const Text('Rename Business'),
          ),
          _menuSeparator,
          MenuItemButton(
            onPressed: canBusiness
                ? () => DesktopMenuActions.openSettings(ref)
                : null,
            child: const Text('Settings'),
          ),
          _menuSeparator,
          MenuItemButton(
            onPressed: canLogout
                ? () => unawaited(DesktopMenuActions.logout(ref))
                : null,
            child: const Text('Logout'),
          ),
          _menuSeparator,
          MenuItemButton(
            onPressed: () => unawaited(DesktopMenuActions.quit()),
            child: const Text('Quit Billing Baba'),
          ),
        ],
      ),
      _submenu(
        label: const Text('Help'),
        menuChildren: [
          MenuItemButton(
            onPressed: () => unawaited(DesktopMenuActions.openDocumentation()),
            child: const Text('Documentation'),
          ),
          MenuItemButton(
            onPressed: () => unawaited(DesktopMenuActions.openContactSupport()),
            child: const Text('Contact Support'),
          ),
          MenuItemButton(
            onPressed: () => unawaited(DesktopMenuActions.reportIssue()),
            child: const Text('Report an Issue'),
          ),
          MenuItemButton(
            onPressed: () => unawaited(DesktopMenuActions.openPrivacyPolicy()),
            child: const Text('Privacy Policy'),
          ),
        ],
      ),
      _submenu(
        label: const Text('Versions'),
        menuChildren: [
          MenuItemButton(
            child: Text(
              'Application Version ${_versions.applicationVersion}',
            ),
          ),
          MenuItemButton(
            child: Text('Build Version ${_versions.buildVersion}'),
          ),
          _menuSeparator,
          MenuItemButton(
            onPressed: () => DesktopMenuActions.openAbout(ref),
            child: const Text('About Billing Baba'),
          ),
        ],
      ),
      _submenu(
        label: const Text('Edit'),
        menuChildren: [
          MenuItemButton(
            onPressed: () => _DesktopAppMenuBarState._invokeEditIntent(
              const UndoTextIntent(SelectionChangedCause.toolbar),
            ),
            child: const Text('Undo'),
          ),
          MenuItemButton(
            onPressed: () => _DesktopAppMenuBarState._invokeEditIntent(
              const RedoTextIntent(SelectionChangedCause.toolbar),
            ),
            child: const Text('Redo'),
          ),
          _menuSeparator,
          MenuItemButton(
            onPressed: () => _DesktopAppMenuBarState._invokeEditIntent(
              const CopySelectionTextIntent.cut(SelectionChangedCause.toolbar),
            ),
            child: const Text('Cut'),
          ),
          MenuItemButton(
            onPressed: () => _DesktopAppMenuBarState._invokeEditIntent(
              CopySelectionTextIntent.copy,
            ),
            child: const Text('Copy'),
          ),
          MenuItemButton(
            onPressed: () => _DesktopAppMenuBarState._invokeEditIntent(
              const PasteTextIntent(SelectionChangedCause.toolbar),
            ),
            child: const Text('Paste'),
          ),
          MenuItemButton(
            onPressed: () => _DesktopAppMenuBarState._invokeEditIntent(
              const SelectAllTextIntent(SelectionChangedCause.toolbar),
            ),
            child: const Text('Select All'),
          ),
        ],
      ),
      _submenu(
        label: const Text('Reload'),
        menuChildren: [
          MenuItemButton(
            onPressed: () => unawaited(DesktopMenuActions.reload(ref)),
            child: const Text('Reload'),
          ),
        ],
      ),
    ];
  }
}

/// Pushes latest app child + auth gates into the full-window [OverlayEntry].
class _DesktopMenuBarHost extends InheritedWidget {
  const _DesktopMenuBarHost({
    required this.appChild,
    required this.canBusiness,
    required this.canLogout,
    required this.versions,
    required super.child,
  });

  final Widget appChild;
  final bool canBusiness;
  final bool canLogout;
  final DesktopVersionInfo versions;

  static _DesktopMenuBarHost of(BuildContext context) {
    final host = context
        .dependOnInheritedWidgetOfExactType<_DesktopMenuBarHost>();
    assert(host != null, '_DesktopMenuBarHost not found');
    return host!;
  }

  @override
  bool updateShouldNotify(_DesktopMenuBarHost oldWidget) {
    return appChild != oldWidget.appChild ||
        canBusiness != oldWidget.canBusiness ||
        canLogout != oldWidget.canLogout ||
        versions != oldWidget.versions;
  }
}
