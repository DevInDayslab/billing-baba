import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_profile_menu.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_tokens.dart';
import 'package:flutter/material.dart';

class SidebarFooter extends StatefulWidget {
  const SidebarFooter({
    required this.collapsed,
    required this.companyName,
    required this.onEditProfile,
    required this.onSwitchCompany,
    required this.onLogout,
    super.key,
  });

  final bool collapsed;
  final String companyName;
  final VoidCallback onEditProfile;
  final VoidCallback onSwitchCompany;
  final Future<void> Function() onLogout;

  @override
  State<SidebarFooter> createState() => _SidebarFooterState();
}

class _SidebarFooterState extends State<SidebarFooter> {
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
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            offset: const Offset(0, -8),
            showWhenUnlinked: false,
            child: SidebarProfileMenu(
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
        color: SidebarTokens.background,
        child: InkWell(
          onTap: _toggleMenu,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? AppSpacing.sm : AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SidebarTokens.border)),
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
                            color: SidebarTokens.textActive,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _menuOpen ? 0.5 : 0,
                        duration: SidebarTokens.animationDuration,
                        curve: SidebarTokens.animationCurve,
                        child: const Icon(
                          Icons.keyboard_arrow_up,
                          color: SidebarTokens.text,
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
      backgroundColor: Theme.of(context).colorScheme.primary,
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
