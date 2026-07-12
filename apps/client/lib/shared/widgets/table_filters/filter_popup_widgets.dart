import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_theme.dart';
import 'package:flutter/material.dart';

/// Elevated surface with shared filter popover border and shadow.
class FilterElevatedSurface extends StatelessWidget {
  const FilterElevatedSurface({
    required this.child,
    required this.borderRadius,
    this.width,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: TableFilterTheme.popoverElevation,
      shadowColor: TableFilterTheme.popoverShadowColor,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: const BorderSide(color: TableFilterTheme.popoverBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: width != null ? SizedBox(width: width, child: child) : child,
    );
  }
}

/// Popover container — same elevation, radius, and padding as Sales column filters.
class FilterPopoverShell extends StatelessWidget {
  const FilterPopoverShell({
    required this.child,
    this.width = TableFilterTheme.popoverWidth,
    super.key,
  });

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return FilterElevatedSurface(
      borderRadius: AppRadius.mdBorder,
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

/// Clear / Apply actions shared by every filter popover.
class FilterActionButtons extends StatelessWidget {
  const FilterActionButtons({
    required this.onClear,
    required this.onApply,
    this.applyEnabled = true,
    super.key,
  });

  final VoidCallback onClear;
  final VoidCallback onApply;
  final bool applyEnabled;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterActionButton(
            label: 'Clear',
            backgroundColor: TableFilterTheme.clearButtonBg,
            foregroundColor: AppColors.textPrimary,
            onPressed: onClear,
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterActionButton(
            label: 'Apply',
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            onPressed: applyEnabled ? onApply : () {},
          ),
        ],
      ),
    );
  }
}

@Deprecated('Use FilterActionButtons')
class FilterPopoverActions extends FilterActionButtons {
  const FilterPopoverActions({
    required super.onClear,
    required super.onApply,
    super.applyEnabled,
    super.key,
  });
}

class FilterActionButton extends StatelessWidget {
  const FilterActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}

class FilterSectionLabel extends StatelessWidget {
  const FilterSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TableFilterTheme.sectionLabelStyle);
  }
}

/// Dropdown for operators and single-select values.
class FilterOperatorDropdown<T> extends StatefulWidget {
  const FilterOperatorDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.width = TableFilterTheme.popoverWidth - (AppSpacing.md * 2),
    super.key,
  });

  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;
  final double width;

  @override
  State<FilterOperatorDropdown<T>> createState() =>
      _FilterOperatorDropdownState<T>();
}

@Deprecated('Use FilterOperatorDropdown')
class FilterDropdownField<T> extends FilterOperatorDropdown<T> {
  const FilterDropdownField({
    required super.value,
    required super.items,
    required super.labelBuilder,
    required super.onChanged,
    super.width,
    super.key,
  });
}

class _FilterOperatorDropdownState<T> extends State<FilterOperatorDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry == null) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() {});
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showOverlay();
  }

  void _selectItem(T item) {
    _removeOverlay();
    widget.onChanged(item);
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              offset: const Offset(0, 4),
              child: FilterElevatedSurface(
                borderRadius: AppRadius.smBorder,
                width: widget.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final item in widget.items)
                      FilterDropdownItem(
                        label: widget.labelBuilder(item),
                        isSelected: item == widget.value,
                        onTap: () => _selectItem(item),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: AppRadius.smBorder,
        child: Container(
          height: TableFilterTheme.fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: TableFilterTheme.popoverBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.labelBuilder(widget.value),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _overlayEntry != null
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alias for [FilterOperatorDropdown] when used as a value picker.
typedef FilterDropdownInput<T> = FilterOperatorDropdown<T>;

class FilterDropdownItem extends StatelessWidget {
  const FilterDropdownItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? TableFilterTheme.optionSelectedColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: TableFilterTheme.optionHoverColor,
        splashColor: TableFilterTheme.optionHoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FilterRadioTile extends StatelessWidget {
  const FilterRadioTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: TableFilterTheme.hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.textPrimary,
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

class FilterCheckboxTile extends StatelessWidget {
  const FilterCheckboxTile({
    required this.label,
    required this.isSelected,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onChanged,
        hoverColor: TableFilterTheme.hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 6,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onChanged(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
