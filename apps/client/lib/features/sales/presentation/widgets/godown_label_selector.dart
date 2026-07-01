import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:flutter/material.dart';

/// Plain-text godown label — no bordered box, per Vyapar reference.
class GodownLabelSelector extends StatefulWidget {
  const GodownLabelSelector({
    required this.value,
    required this.onSelected,
    super.key,
  });

  final String value;
  final ValueChanged<String> onSelected;

  @override
  State<GodownLabelSelector> createState() => GodownLabelSelectorState();
}

class GodownLabelSelectorState extends State<GodownLabelSelector> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

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

  void _select(String value) {
    _removeOverlay();
    widget.onSelected(value);
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
              offset: const Offset(0, 24),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: AppRadius.smBorder,
                clipBehavior: Clip.antiAlias,
                color: AppColors.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 160),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final option in SaleDropdownOptions.godowns)
                        InkWell(
                          onTap: () => _select(option),
                          hoverColor: const Color(0xFFF5F5F5),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: option == widget.value
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: option == widget.value
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
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

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Godown: ',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            Text(
              widget.value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
