import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _popoverBorder = Color(0xFFE0E0E0);
const _clearButtonBg = Color(0xFFEEEEEE);
const _fieldHeight = 36.0;
const _popoverWidth = 260.0;

enum TextColumnOperator {
  equalTo('Equal To'),
  notEqualTo('Not Equal To'),
  contains('Contains'),
  notContains('Does Not Contain'),
  startsWith('Starts With'),
  endsWith('Ends With');

  const TextColumnOperator(this.label);

  final String label;
}

class TextColumnFilter {
  const TextColumnFilter({
    required this.operator,
    required this.value,
  });

  final TextColumnOperator operator;
  final String value;

  bool matches(String fieldValue) {
    final query = value.trim();
    if (query.isEmpty) return true;

    final target = fieldValue.trim().toLowerCase();
    final needle = query.toLowerCase();

    return switch (operator) {
      TextColumnOperator.equalTo => target == needle,
      TextColumnOperator.notEqualTo => target != needle,
      TextColumnOperator.contains => target.contains(needle),
      TextColumnOperator.notContains => !target.contains(needle),
      TextColumnOperator.startsWith => target.startsWith(needle),
      TextColumnOperator.endsWith => target.endsWith(needle),
    };
  }
}

/// Column header text filter — popover with operator dropdown, text field, Clear/Apply.
class SaleColumnTextFilterTrigger extends StatefulWidget {
  const SaleColumnTextFilterTrigger({
    required this.label,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.hintText = 'Enter value',
    this.iconOnly = false,
    super.key,
  });

  final String label;
  final TextColumnFilter? initialFilter;
  final ValueChanged<TextColumnFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final String hintText;
  final bool iconOnly;

  @override
  State<SaleColumnTextFilterTrigger> createState() =>
      _SaleColumnTextFilterTriggerState();
}

class _SaleColumnTextFilterTriggerState
    extends State<SaleColumnTextFilterTrigger> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  static const _defaultHeaderStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _togglePopover() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showPopover();
  }

  void _showPopover() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

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
              child: _SaleColumnTextFilterPopover(
                initialFilter: widget.initialFilter,
                hintText: widget.hintText,
                onApply: (filter) {
                  _removeOverlay();
                  widget.onApply(filter);
                },
                onClose: _removeOverlay,
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
    final isActive = widget.initialFilter != null &&
        widget.initialFilter!.value.trim().isNotEmpty;

    if (widget.iconOnly) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: InkWell(
          key: _triggerKey,
          onTap: _togglePopover,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.filter_list,
              size: 14,
              color: isActive ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Align(
          alignment: widget.alignment,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: widget.headerStyle ?? _defaultHeaderStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 2),
              InkWell(
                key: _triggerKey,
                onTap: _togglePopover,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.filter_list,
                    size: 14,
                    color: isActive
                        ? AppColors.error
                        : AppColors.textSecondary,
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

class _SaleColumnTextFilterPopover extends StatefulWidget {
  const _SaleColumnTextFilterPopover({
    required this.initialFilter,
    required this.hintText,
    required this.onApply,
    required this.onClose,
  });

  final TextColumnFilter? initialFilter;
  final String hintText;
  final ValueChanged<TextColumnFilter?> onApply;
  final VoidCallback onClose;

  @override
  State<_SaleColumnTextFilterPopover> createState() =>
      _SaleColumnTextFilterPopoverState();
}

class _SaleColumnTextFilterPopoverState
    extends State<_SaleColumnTextFilterPopover> {
  late TextColumnOperator _operator;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _operator = widget.initialFilter?.operator ?? TextColumnOperator.contains;
    _valueController = TextEditingController(
      text: widget.initialFilter?.value ?? '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _apply() {
    final value = _valueController.text.trim();
    if (value.isEmpty) {
      widget.onApply(null);
      return;
    }
    widget.onApply(TextColumnFilter(operator: _operator, value: value));
  }

  void _clear() {
    widget.onApply(null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: SizedBox(
        width: _popoverWidth,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _FilterDropdownField<TextColumnOperator>(
                value: _operator,
                items: TextColumnOperator.values,
                labelBuilder: (value) => value.label,
                onChanged: (value) {
                  setState(() => _operator = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Enter Value',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: _fieldHeight,
                child: TextField(
                  controller: _valueController,
                  autofocus: true,
                  cursorColor: AppColors.primary,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smBorder,
                      borderSide: const BorderSide(color: _popoverBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smBorder,
                      borderSide: const BorderSide(color: _popoverBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smBorder,
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onSubmitted: (_) => _apply(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilterActionButton(
                      label: 'Clear',
                      backgroundColor: _clearButtonBg,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: _clear,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterActionButton(
                      label: 'Apply',
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      onPressed: _apply,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDropdownField<T> extends StatefulWidget {
  const _FilterDropdownField({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  State<_FilterDropdownField<T>> createState() => _FilterDropdownFieldState<T>();
}

class _FilterDropdownFieldState<T> extends State<_FilterDropdownField<T>> {
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
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.smBorder,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: _popoverWidth - (AppSpacing.md * 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in widget.items)
                        _CategoryDropdownItem(
                          label: widget.labelBuilder(item),
                          isSelected: item == widget.value,
                          onTap: () => _selectItem(item),
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
          height: _fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: _popoverBorder),
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

class _CategoryDropdownItem extends StatelessWidget {
  const _CategoryDropdownItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _hoverColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: _hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
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
      ),
    );
  }
}

class _FilterActionButton extends StatelessWidget {
  const _FilterActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
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
