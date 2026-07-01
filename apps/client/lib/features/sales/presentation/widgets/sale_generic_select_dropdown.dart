import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

enum SaleDropdownHighlight { neutral, red, blue }

/// Reusable overlay dropdown with CompositedTransformTarget/Follower pattern.
class SaleGenericSelectDropdown extends StatefulWidget {
  const SaleGenericSelectDropdown({
    required this.value,
    required this.options,
    required this.onSelected,
    this.hintText = 'Select',
    this.highlight = SaleDropdownHighlight.neutral,
    this.maxMenuHeight = 250,
    this.minMenuWidth,
    this.hasError = false,
    this.compact = false,
    super.key,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String hintText;
  final SaleDropdownHighlight highlight;
  final double maxMenuHeight;
  final double? minMenuWidth;
  final bool hasError;
  final bool compact;

  @override
  State<SaleGenericSelectDropdown> createState() =>
      SaleGenericSelectDropdownState();
}

class SaleGenericSelectDropdownState extends State<SaleGenericSelectDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void closeMenu() => _removeOverlay();

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectOption(String option) {
    _removeOverlay();
    widget.onSelected(option);
  }

  Color get _highlightColor => switch (widget.highlight) {
    SaleDropdownHighlight.red => const Color(0xFFD32F2F),
    SaleDropdownHighlight.blue => AppColors.primary,
    SaleDropdownHighlight.neutral => const Color(0xFFEEEEEE),
  };

  Color get _highlightTextColor => switch (widget.highlight) {
    SaleDropdownHighlight.red => const Color(0xFFD32F2F),
    SaleDropdownHighlight.blue => AppColors.primary,
    SaleDropdownHighlight.neutral => AppColors.textPrimary,
  };

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final triggerWidth = renderBox?.size.width ?? 200;

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
              offset: Offset(0, widget.compact ? 34 : 40),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                color: AppColors.surface,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: widget.minMenuWidth ?? triggerWidth,
                    maxWidth: widget.minMenuWidth ?? triggerWidth,
                    maxHeight: widget.maxMenuHeight,
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (final option in widget.options)
                        _DropdownMenuItem(
                          label: option,
                          isSelected: option == widget.value,
                          highlightColor: _highlightColor,
                          textColor: _highlightTextColor,
                          showCheckmark:
                              widget.highlight != SaleDropdownHighlight.neutral,
                          onTap: () => _selectOption(option),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.value.isEmpty ? widget.hintText : widget.value;
    final isPlaceholder = widget.value.isEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: SaleFieldTrigger(
        onTap: _toggleMenu,
        hasError: widget.hasError,
        compact: widget.compact,
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: widget.compact ? 13 : 14,
                  color: isPlaceholder
                      ? Colors.grey.shade400
                      : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: widget.compact ? 16 : 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownMenuItem extends StatelessWidget {
  const _DropdownMenuItem({
    required this.label,
    required this.isSelected,
    required this.highlightColor,
    required this.textColor,
    required this.showCheckmark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color highlightColor;
  final Color textColor;
  final bool showCheckmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        hoverColor: const Color(0xFFF5F5F5),
        onTap: onTap,
        child: Container(
          color: isSelected ? highlightColor.withValues(alpha: 0.08) : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? textColor : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected && showCheckmark)
                Icon(Icons.check, size: 16, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}
