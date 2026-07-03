import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _menuHoverColor = Color(0xFFF5F5F5);
const _itemVerticalPadding = 12.0;
const _leadingWidth = 20.0;
const _dotSize = 7.0;

/// Generic filter dropdown — uses [MenuAnchor] by default, searchable overlay when needed.
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
  final MenuController _menuController = MenuController();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void openMenu() {
    if (widget.showSearchField) {
      if (_overlayEntry != null) return;
      _searchQuery = '';
      _showSearchOverlay();
      return;
    }
    if (!_menuController.isOpen) {
      _menuController.open();
    }
  }

  void closeMenu() {
    if (widget.showSearchField) {
      _removeOverlay();
      return;
    }
    if (_menuController.isOpen) {
      _menuController.close();
    }
  }

  void _toggleMenu() {
    if (widget.showSearchField) {
      if (_overlayEntry != null) {
        _removeOverlay();
      } else {
        openMenu();
      }
      return;
    }
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectOption(String option) {
    closeMenu();
    widget.onSelected(option);
  }

  List<String> _filteredOptions(String query) {
    if (query.isEmpty) return widget.options;
    final normalized = query.toLowerCase();
    return widget.options
        .where((option) => option.toLowerCase().contains(normalized))
        .toList();
  }

  void _showSearchOverlay() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final menuWidth = renderBox.size.width < 180 ? 180.0 : renderBox.size.width;
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return StatefulBuilder(
          builder: (context, setOverlayState) {
            final filteredOptions = _filteredOptions(_searchQuery);

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
                    borderRadius: AppRadius.mdBorder,
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: menuWidth,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 18,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 13),
                                onChanged: (value) {
                                  setOverlayState(() => _searchQuery = value);
                                },
                              ),
                            ),
                            Flexible(
                              child: ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                children: [
                                  for (final option in filteredOptions)
                                    _SaleFilterDropdownItem(
                                      label: option,
                                      isSelected: option == widget.selected,
                                      onTap: () => _selectOption(option),
                                    ),
                                ],
                              ),
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
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showSearchField) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          key: _triggerKey,
          onTap: _toggleMenu,
          behavior: HitTestBehavior.opaque,
          child: widget.label.isEmpty
              ? const SizedBox.shrink()
              : _FilterChipTrigger(label: widget.label),
        ),
      );
    }

    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        elevation: const WidgetStatePropertyAll(4),
        shadowColor: const WidgetStatePropertyAll(Colors.black26),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size(180, 0)),
      ),
      menuChildren: [
        for (final option in widget.options)
          _FilterMenuItem(
            label: option,
            isSelected: option == widget.selected,
            onSelected: () => _selectOption(option),
          ),
      ],
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: _toggleMenu,
          behavior: HitTestBehavior.opaque,
          child: widget.label.isEmpty
              ? const SizedBox.shrink()
              : _FilterChipTrigger(label: widget.label),
        );
      },
    );
  }
}

class _FilterMenuItem extends StatelessWidget {
  const _FilterMenuItem({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  static const _labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: onSelected,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: _itemVerticalPadding,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return _menuHoverColor;
          }
          return null;
        }),
        splashFactory: NoSplash.splashFactory,
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
