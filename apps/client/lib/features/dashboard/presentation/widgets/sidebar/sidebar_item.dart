import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/models/sidebar_menu.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_tokens.dart';
import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    required this.item,
    required this.collapsed,
    required this.isActive,
    required this.onTap,
    this.isChild = false,
    super.key,
  });

  final SidebarMenuItem item;
  final bool collapsed;
  final bool isActive;
  final VoidCallback? onTap;
  final bool isChild;

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SidebarTokens.animationDuration,
          curve: SidebarTokens.animationCurve,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: isActive ? SidebarTokens.activeBackground : Colors.transparent,
            borderRadius: AppRadius.smBorder,
            border: isActive
                ? Border(left: BorderSide(color: accentColor, width: 3))
                : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? AppSpacing.sm : (isChild ? 28 : AppSpacing.md),
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: isActive ? SidebarTokens.textActive : SidebarTokens.text,
                size: isChild ? 18 : 20,
              ),
              if (!collapsed) ...[
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color:
                          isActive ? SidebarTokens.textActive : SidebarTokens.text,
                      fontSize: isChild ? 12 : 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.badge != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
