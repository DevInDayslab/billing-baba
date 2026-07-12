import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _popoverBorder = Color(0xFFE0E0E0);
const _clearButtonBg = Color(0xFFEEEEEE);
const _popoverWidth = 220.0;

/// A column filter that matches when the field equals the selected value.
/// [value] null means no filter (show all).
class SelectColumnFilter {
  const SelectColumnFilter({required this.value});

  final String? value;

  bool matches(String fieldValue) {
    final selected = value?.trim();
    if (selected == null || selected.isEmpty) return true;
    return fieldValue.trim().toLowerCase() == selected.toLowerCase();
  }
}

/// Column header select filter — popover with searchable option list.
class SaleColumnSelectFilterTrigger extends StatefulWidget {
  const SaleColumnSelectFilterTrigger({
    required this.label,
    required this.options,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.iconOnly = false,
    super.key,
  });

  final String label;
  final List<String> options;
  final SelectColumnFilter? initialFilter;
  final ValueChanged<SelectColumnFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final bool iconOnly;

  @override
  State<SaleColumnSelectFilterTrigger> createState() =>
      _SaleColumnSelectFilterTriggerState();
}

class _SaleColumnSelectFilterTriggerState
    extends State<SaleColumnSelectFilterTrigger> {
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
              child: _SaleColumnSelectFilterPopover(
                options: widget.options,
                initialFilter: widget.initialFilter,
                onApply: (filter) {
                  _removeOverlay();
                  widget.onApply(filter);
                },
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
    final isActive =
        widget.initialFilter?.value != null &&
        widget.initialFilter!.value!.trim().isNotEmpty;

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

class _SaleColumnSelectFilterPopover extends StatefulWidget {
  const _SaleColumnSelectFilterPopover({
    required this.options,
    required this.initialFilter,
    required this.onApply,
  });

  final List<String> options;
  final SelectColumnFilter? initialFilter;
  final ValueChanged<SelectColumnFilter?> onApply;

  @override
  State<_SaleColumnSelectFilterPopover> createState() =>
      _SaleColumnSelectFilterPopoverState();
}

class _SaleColumnSelectFilterPopoverState
    extends State<_SaleColumnSelectFilterPopover> {
  late String? _selected;
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.initialFilter?.value;
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredOptions {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where((option) => option.toLowerCase().contains(query))
        .toList();
  }

  void _apply() {
    final value = _selected?.trim();
    if (value == null || value.isEmpty) {
      widget.onApply(null);
      return;
    }
    widget.onApply(SelectColumnFilter(value: value));
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
              TextField(
                controller: _searchController,
                autofocus: true,
                cursorColor: AppColors.primary,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                  ),
                  isDense: true,
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
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _OptionTile(
                      label: 'All',
                      isSelected: _selected == null,
                      onTap: () => setState(() => _selected = null),
                    ),
                    for (final option in _filteredOptions)
                      _OptionTile(
                        label: option,
                        isSelected: _selected == option,
                        onTap: () => setState(() => _selected = option),
                      ),
                    if (_filteredOptions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          'No matches',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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

class _OptionTile extends StatelessWidget {
  const _OptionTile({
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
