import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Vertical + horizontal scrolling for desktop layouts (zoom, wide tables, settings grids).
class DesktopBidirectionalScroll extends StatelessWidget {
  const DesktopBidirectionalScroll({
    required this.child,
    super.key,
    this.padding,
    this.primary = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          ...ScrollConfiguration.of(context).dragDevices,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: primary,
          padding: padding,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            thumbVisibility: true,
            notificationPredicate: (notification) => notification.depth == 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
