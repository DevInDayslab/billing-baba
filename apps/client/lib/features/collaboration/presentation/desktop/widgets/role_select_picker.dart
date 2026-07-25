import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_overlay.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_widgets.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_theme.dart';
import 'package:flutter/material.dart';

const _rowHeight = 36.0;

/// Anchored role picker — popover opens beside the chevron, same as table filters.
class RoleSelectTrigger extends StatefulWidget {
  const RoleSelectTrigger({
    required this.selectedRole,
    required this.onChanged,
    this.enabled = true,
    this.dense = false,
    super.key,
  });

  final Role selectedRole;
  final ValueChanged<Role> onChanged;
  final bool enabled;
  final bool dense;

  @override
  State<RoleSelectTrigger> createState() => _RoleSelectTriggerState();
}

class _RoleSelectTriggerState extends State<RoleSelectTrigger> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  late final FilterOverlayAnchor _anchor = FilterOverlayAnchor(
    layerLink: _layerLink,
    triggerKey: _triggerKey,
  );

  @override
  void dispose() {
    _anchor.dispose();
    super.dispose();
  }

  void _togglePopover() {
    if (!widget.enabled) return;

    final roleCount = Role.values.length;
    final estimatedHeight = (roleCount * _rowHeight + AppSpacing.sm).clamp(
      180.0,
      300.0,
    );

    _anchor.toggle(
      context: context,
      estimatedSize: Size(
        TableFilterTheme.selectPopoverWidth,
        estimatedHeight,
      ),
      popover: _RoleSelectPopover(
        selectedRole: widget.selectedRole,
        onSelected: (role) {
          _anchor.removeOverlay();
          if (role != widget.selectedRole) {
            widget.onChanged(role);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: widget.dense ? 13 : 14,
      fontWeight: FontWeight.w500,
      color: widget.enabled ? AppColors.primary : AppColors.textSecondary,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            widget.selectedRole.displayLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
        CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            key: _triggerKey,
            onTap: widget.enabled ? _togglePopover : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: widget.dense ? 16 : 20,
                color: widget.enabled
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleSelectPopover extends StatelessWidget {
  const _RoleSelectPopover({
    required this.selectedRole,
    required this.onSelected,
  });

  final Role selectedRole;
  final ValueChanged<Role> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterElevatedSurface(
      borderRadius: AppRadius.mdBorder,
      width: TableFilterTheme.selectPopoverWidth,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          children: [
            for (final role in Role.values)
              _RoleSelectTile(
                label: role.displayLabel,
                isSelected: role == selectedRole,
                onTap: () => onSelected(role),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleSelectTile extends StatelessWidget {
  const _RoleSelectTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? TableFilterTheme.optionSelectedColor
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: TableFilterTheme.optionHoverColor,
        child: SizedBox(
          height: _rowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
