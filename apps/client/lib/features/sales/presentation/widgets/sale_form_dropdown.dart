import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _fieldBorder = Color(0xFFCCCCCC);
const _errorBorder = Color(0xFFD32F2F);
const _menuHoverColor = Color(0xFFF5F5F5);

/// Full-width outlined dropdown using the same overlay pattern as sale_filter_dropdown.
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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';

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
      _searchQuery = '';
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
              offset: const Offset(0, 40),
              child: PhysicalModel(
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: triggerWidth,
                    maxWidth: triggerWidth,
                    maxHeight: 280,
                  ),
                  child: SingleChildScrollView(
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
                          _SaleFormDropdownItem(
                            label: option,
                            isSelected: option == widget.value,
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
    final displayText = widget.value.isEmpty ? widget.hintText : widget.value;
    final isPlaceholder = widget.value.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
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
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPlaceholder
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
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
          ),
        ),
        if (widget.hasError && widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              widget.errorText!,
              style: const TextStyle(fontSize: 11, color: _errorBorder),
            ),
          ),
      ],
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
