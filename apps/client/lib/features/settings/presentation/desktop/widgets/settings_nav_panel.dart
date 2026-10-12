import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/settings/models/settings_sub_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _navBackground = Color(0xFFF8F9FB);
const _sectionHeaderColor = Color(0xFF00695C);
const _activeBlue = Color(0xFF1976D2);
const _activeBackground = Color(0xFFE8F1FB);
const _borderColor = Color(0xFFE0E0E0);

class SettingsNavPanel extends StatelessWidget {
  const SettingsNavPanel({
    required this.selectedRoute,
    required this.onRouteSelected,
    super.key,
  });

  final String selectedRoute;
  final ValueChanged<String> onRouteSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _navBackground,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          const _SectionHeader(label: 'Settings'),
          for (final item in SettingsSubRoutes.items)
            _NavItemTile(
              label: _displayLabel(item.label),
              isSelected: _isRouteSelected(item.route, selectedRoute),
              showProBadge: item.showProBadge,
              onTap: () => onRouteSelected(item.route),
            ),
        ],
      ),
    );
  }

  static bool _isRouteSelected(String itemRoute, String currentRoute) {
    if (currentRoute == itemRoute) return true;
    if (itemRoute == AppRoutes.settingsPreferences &&
        currentRoute.startsWith('${AppRoutes.settingsPreferences}?')) {
      return true;
    }
    return false;
  }

  static String _displayLabel(String label) {
    return label
        .split(' ')
        .map((word) {
          if (word == '&' || word.isEmpty) return word;
          final lower = word.toLowerCase();
          return lower[0].toUpperCase() + lower.substring(1);
        })
        .join(' ');
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _sectionHeaderColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showProBadge = false,
  });

  final String label;
  final bool isSelected;
  final bool showProBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _activeBackground : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? _activeBlue : Colors.transparent,
                width: 3,
              ),
              bottom: const BorderSide(color: _borderColor, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? _activeBlue : const Color(0xFF424242),
                    height: 1.35,
                  ),
                ),
              ),
              if (showProBadge) ...[
                const SizedBox(width: 6),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.crown,
                    size: 10,
                    color: Colors.white,
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
