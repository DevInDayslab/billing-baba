import 'package:flutter/material.dart';

/// Resolves filter popover placement relative to the trigger icon.
abstract final class FilterPopoverPositioner {
  static const screenPadding = 8.0;
  static const verticalGap = 4.0;

  static ({
    Alignment targetAnchor,
    Alignment followerAnchor,
    Offset offset,
  })
  resolveFollower({
    required Rect triggerRect,
    required Size popoverSize,
    required Size viewportSize,
  }) {
    final overflowsRight =
        triggerRect.left + popoverSize.width >
        viewportSize.width - screenPadding;
    final canAlignRight =
        triggerRect.right - popoverSize.width >= screenPadding;
    final useRightAnchor = overflowsRight && canAlignRight;

    final belowTop = triggerRect.bottom + verticalGap;
    final fitsBelow =
        belowTop + popoverSize.height <= viewportSize.height - screenPadding;
    final aboveTop = triggerRect.top - verticalGap - popoverSize.height;
    final fitsAbove = aboveTop >= screenPadding;
    final showBelow = fitsBelow || !fitsAbove;

    final Alignment targetAnchor;
    final Alignment followerAnchor;
    final Offset baseOffset;

    if (showBelow) {
      if (useRightAnchor) {
        targetAnchor = Alignment.bottomRight;
        followerAnchor = Alignment.topRight;
      } else {
        targetAnchor = Alignment.bottomLeft;
        followerAnchor = Alignment.topLeft;
      }
      baseOffset = const Offset(0, verticalGap);
    } else {
      if (useRightAnchor) {
        targetAnchor = Alignment.topRight;
        followerAnchor = Alignment.bottomRight;
      } else {
        targetAnchor = Alignment.topLeft;
        followerAnchor = Alignment.bottomLeft;
      }
      baseOffset = const Offset(0, -verticalGap);
    }

    final left = useRightAnchor
        ? triggerRect.right - popoverSize.width
        : triggerRect.left;
    final top = showBelow ? belowTop : aboveTop;

    var dx = 0.0;
    var dy = 0.0;

    final overflowRight =
        left + popoverSize.width - (viewportSize.width - screenPadding);
    if (overflowRight > 0) dx -= overflowRight;

    final overflowLeft = screenPadding - (left + dx);
    if (overflowLeft > 0) dx += overflowLeft;

    final overflowBottom =
        top + popoverSize.height - (viewportSize.height - screenPadding);
    if (overflowBottom > 0) dy -= overflowBottom;

    final overflowTop = screenPadding - (top + dy);
    if (overflowTop > 0) dy += overflowTop;

    return (
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: baseOffset + Offset(dx, dy),
    );
  }
}
