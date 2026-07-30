import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_transaction_table_layout.dart'
    show PurchaseTransactionTableCell;
import 'package:flutter/material.dart';

/// A header cell that can be resized by dragging its right edge.
///
/// Usage: wrap any [PurchaseTransactionTableCell] label with this widget
/// instead of using a fixed width directly.
class ResizableTableHeaderCell extends StatefulWidget {
  const ResizableTableHeaderCell({
    required this.initialWidth,
    required this.child,
    this.minWidth = 60.0,
    this.maxWidth = 400.0,
    super.key,
  });

  final double initialWidth;
  final Widget child;
  final double minWidth;
  final double maxWidth;

  @override
  State<ResizableTableHeaderCell> createState() =>
      _ResizableTableHeaderCellState();
}

class _ResizableTableHeaderCellState extends State<ResizableTableHeaderCell> {
  late double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Stack(
        children: [
          // The actual cell content fills the full width
          Positioned.fill(child: widget.child),

          // Drag handle on the right edge
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 8,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _width = (_width + details.delta.dx).clamp(
                      widget.minWidth,
                      widget.maxWidth,
                    );
                  });
                },
                child: Center(
                  child: Container(
                    width: 2,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
