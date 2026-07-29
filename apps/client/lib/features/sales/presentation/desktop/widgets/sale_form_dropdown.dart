import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';

const _fieldBorder = Color(0xFFCCCCCC);
const _errorBorder = Color(0xFFD32F2F);
const _menuHoverColor = Color(0xFFF5F5F5);

/// Full-width outlined dropdown using [MenuAnchor] for smooth interactions.
class SaleFormDropdown extends StatefulWidget {
  const SaleFormDropdown({
    required this.value,
    required this.options,
    required this.onSelected,
    this.hintText = 'Select',
    this.showSearchField = false,
    this.hasError = false,
    this.errorText,
    super.key,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String hintText;
  final bool showSearchField;
  final bool hasError;
  final String? errorText;

  @override
  State<SaleFormDropdown> createState() => SaleFormDropdownState();
}

class SaleFormDropdownState extends State<SaleFormDropdown> {
  final MenuController _menuController = MenuController();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
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
        _searchQuery = '';
        _showSearchOverlay();
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
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
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
                Positioned(
                  left: offset.dx,
                  top: offset.dy + size.height + 4,
                  width: size.width,
                  child: Material(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    color: AppColors.surface,
                    borderRadius: AppRadius.mdBorder,
                    clipBehavior: Clip.antiAlias,
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
                                prefixIcon: const Icon(Icons.search, size: 18),
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
                                  _SaleFormDropdownItem(
                                    label: option,
                                    isSelected: option == widget.value,
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
    final displayText = widget.value.isEmpty ? widget.hintText : widget.value;
    final isPlaceholder = widget.value.isEmpty;

    final trigger = GestureDetector(
      onTap: _toggleMenu,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.hasError ? _errorBorder : _fieldBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppEllipsisText(
                displayText,
                style: TextStyle(
                  fontSize: 13,
                  color: isPlaceholder
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );

    if (widget.showSearchField) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          trigger,
          if (widget.hasError && widget.errorText != null)
            _ErrorText(text: widget.errorText!),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final triggerWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 200.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuAnchor(
              controller: _menuController,
              alignmentOffset: const Offset(0, 4),
              style: MenuStyle(
                backgroundColor: const WidgetStatePropertyAll(
                  AppColors.surface,
                ),
                elevation: const WidgetStatePropertyAll(4),
                shadowColor: const WidgetStatePropertyAll(Colors.black26),
                surfaceTintColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
                ),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                minimumSize: WidgetStatePropertyAll(Size(triggerWidth, 0)),
                maximumSize: const WidgetStatePropertyAll(
                  Size(double.infinity, 280),
                ),
              ),
              menuChildren: [
                for (final option in widget.options)
                  _FormMenuItem(
                    label: option,
                    isSelected: option == widget.value,
                    onSelected: () => _selectOption(option),
                  ),
              ],
              builder: (context, controller, child) => trigger,
            ),
            if (widget.hasError && widget.errorText != null)
              _ErrorText(text: widget.errorText!),
          ],
        );
      },
    );
  }
}

class _FormMenuItem extends StatelessWidget {
  const _FormMenuItem({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: onSelected,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
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
        children: [
          SizedBox(
            width: 20,
            child: isSelected
                ? Center(
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: _errorBorder),
      ),
    );
  }
}

class _SaleFormDropdownItem extends StatelessWidget {
  const _SaleFormDropdownItem({
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
      type: MaterialType.transparency,
      child: InkWell(
        hoverColor: _menuHoverColor,
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
