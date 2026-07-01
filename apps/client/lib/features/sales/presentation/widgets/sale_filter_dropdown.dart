import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _menuHoverColor = Color(0xFFF5F5F5);
const _itemVerticalPadding = 12.0;
const _leadingWidth = 20.0;
const _dotSize = 7.0;

/// Generic overlay dropdown with InkWell hover — same pattern as page switcher.
class SaleFilterDropdown extends StatefulWidget {
  const SaleFilterDropdown({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.showSearchField = false,
    super.key,
  });

  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool showSearchField;

  @override
  State<SaleFilterDropdown> createState() => SaleFilterDropdownState();
}

/// Exposed so parent widgets can programmatically open the dropdown menu.
class SaleFilterDropdownState extends State<SaleFilterDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void openMenu() {
    if (_overlayEntry != null) return;
    _searchQuery = '';
    _showOverlay();
  }

  void closeMenu() {
    _removeOverlay();
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      openMenu();
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

  List<String> get _filteredOptions {
    if (!widget.showSearchField || _searchQuery.isEmpty) {
      return widget.options;
    }
    final query = _searchQuery.toLowerCase();
    return widget.options
        .where((option) => option.toLowerCase().contains(query))
        .toList();
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
              offset: const Offset(0, 36),
              child: PhysicalModel(
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                child: IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 180),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.showSearchField)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.sm,
                              AppSpacing.sm,
                              AppSpacing.sm,
                              AppSpacing.xs,
                            ),
                            child: TextField(
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.sm,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.smBorder,
                                ),
                                prefixIcon: const Icon(Icons.search, size: 18),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                              style: const TextStyle(fontSize: 13),
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                                _overlayEntry?.markNeedsBuild();
                              },
                            ),
                          ),
                        for (final option in _filteredOptions)
                          _SaleFilterDropdownItem(
                            label: option,
                            isSelected: option == widget.selected,
                            onTap: () => _selectOption(option),
                          ),
                      ],
                    ),
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        behavior: HitTestBehavior.opaque,
        child: widget.label.isEmpty
            ? const SizedBox.shrink()
            : _FilterChipTrigger(label: widget.label),
      ),
    );
  }
}

/// Tappable filter chip used as dropdown trigger or standalone opener.
class SaleFilterChip extends StatelessWidget {
  const SaleFilterChip({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _FilterChipTrigger(label: label),
    );
  }
}

class _FilterChipTrigger extends StatelessWidget {
  const _FilterChipTrigger({required this.label});

  final String label;

  static const _cardBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _SaleFilterDropdownItem extends StatelessWidget {
  const _SaleFilterDropdownItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        hoverColor: _menuHoverColor,
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: _itemVerticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _leadingWidth,
                child: isSelected
                    ? Center(
                        child: Container(
                          width: _dotSize,
                          height: _dotSize,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              Text(label, style: _labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}
