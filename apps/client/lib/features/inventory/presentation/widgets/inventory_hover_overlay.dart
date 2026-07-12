import 'package:flutter/material.dart';

class InventoryHoverOverlay extends StatefulWidget {
  const InventoryHoverOverlay({
    required this.child,
    required this.overlayBuilder,
    super.key,
  });

  final Widget child;
  final Widget Function(BuildContext context) overlayBuilder;

  @override
  State<InventoryHoverOverlay> createState() => _InventoryHoverOverlayState();
}

class _InventoryHoverOverlayState extends State<InventoryHoverOverlay> {
  OverlayEntry? _entry;
  final LayerLink _link = LayerLink();

  void _showOverlay() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 200,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: Offset(renderBox.size.width + 8, 0),
            child: Material(
              color: Colors.transparent,
              child: widget.overlayBuilder(context),
            ),
          ),
        );
      },
    );
    overlay.insert(_entry!);
  }

  void _hideOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _showOverlay(),
        onExit: (_) => _hideOverlay(),
        child: widget.child,
      ),
    );
  }
}
