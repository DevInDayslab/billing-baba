import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/models/sidebar_menu.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_item.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_tokens.dart';
import 'package:flutter/material.dart';

class SidebarSection extends StatelessWidget {
  const SidebarSection({
    required this.item,
    required this.collapsed,
    required this.isExpanded,
    required this.isActive,
    required this.onToggle,
    required this.childBuilder,
    super.key,
  });

  final SidebarMenuItem item;
  final bool collapsed;
  final bool isExpanded;
  final bool isActive;
  final VoidCallback onToggle;
  final List<Widget> Function() childBuilder;

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: collapsed ? null : onToggle,
            child: AnimatedContainer(
              duration: SidebarTokens.animationDuration,
              curve: SidebarTokens.animationCurve,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color:
                    isActive ? SidebarTokens.activeBackground : Colors.transparent,
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
                    color:
                        isActive ? SidebarTokens.textActive : SidebarTokens.text,
                    size: 20,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: isActive
                              ? SidebarTokens.textActive
                              : SidebarTokens.text,
                          fontSize: 13,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: SidebarTokens.animationDuration,
                      curve: SidebarTokens.animationCurve,
                      child: Icon(
                        Icons.chevron_right,
                        color: isActive
                            ? SidebarTokens.textActive
                            : SidebarTokens.text,
                        size: 18,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: SidebarTokens.animationDuration,
          curve: SidebarTokens.animationCurve,
          alignment: Alignment.topCenter,
          child: (!collapsed && isExpanded)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: childBuilder(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Leaf item inside an expanded section.
class SidebarSubItem extends SidebarItem {
  const SidebarSubItem({required super.item, required super.collapsed, required super.isActive, required super.onTap, super.key,
  }) : super(isChild: true);
}
