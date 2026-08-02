import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/platform/desktop_menu_actions.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    unawaited(_loadVersions());
  }

  Future<void> _loadVersions() async {
    final info = await DesktopMenuActions.loadVersionInfo();
    if (!mounted) return;
    setState(() => _versions = info);
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
        child: widget.child,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          // MenuBar requires an Overlay ancestor. MaterialApp.builder wraps the
          // Navigator, so the menu sits above the navigator overlay — provide one
          // locally and allow submenu popups to paint outside the bar height.
          child: SizedBox(
            height: kMinInteractiveDimension,
            child: Overlay(
              clipBehavior: Clip.none,
              initialEntries: [
                OverlayEntry(
                  builder: (context) => MenuBar(
                    style: const MenuStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      elevation: WidgetStatePropertyAll(0),
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                    children: _materialMenus(
                      canBusiness: canBusiness,
                      canLogout: canLogout,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: widget.child),
      ],
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

  List<Widget> _materialMenus({
    required bool canBusiness,
    required bool canLogout,
  }) {
    return [
      SubmenuButton(
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
          const Divider(),
          MenuItemButton(
            onPressed: canBusiness
                ? () => DesktopMenuActions.openSettings(ref)
                : null,
            child: const Text('Settings'),
          ),
          const Divider(),
          MenuItemButton(
            onPressed: canLogout
                ? () => unawaited(DesktopMenuActions.logout(ref))
                : null,
            child: const Text('Logout'),
          ),
          const Divider(),
          MenuItemButton(
            onPressed: () => unawaited(DesktopMenuActions.quit()),
            child: const Text('Quit Billing Baba'),
          ),
        ],
        child: const Text(AppConfig.appName),
      ),
      SubmenuButton(
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
        child: const Text('Help'),
      ),
      SubmenuButton(
        menuChildren: [
          MenuItemButton(
            child: Text(
              'Application Version ${_versions.applicationVersion}',
            ),
          ),
          MenuItemButton(
            child: Text('Build Version ${_versions.buildVersion}'),
          ),

          const Divider(),
          MenuItemButton(
            onPressed: () => DesktopMenuActions.openAbout(ref),
            child: const Text('About Billing Baba'),
          ),
        ],
        child: const Text('Versions'),
      ),
      SubmenuButton(
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
          const Divider(),
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
        child: const Text('Edit'),
      ),
      SubmenuButton(
        menuChildren: [
          MenuItemButton(
            onPressed: () => unawaited(DesktopMenuActions.reload(ref)),
            child: const Text('Reload'),
          ),
        ],
        child: const Text('Reload'),
      ),
    ];
  }
}
