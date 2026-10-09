import 'dart:async';

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Hover tooltip icon (desktop) with catalog sections.
class SettingsInfoHoverIcon extends StatefulWidget {
  const SettingsInfoHoverIcon({
    required this.heading,
    required this.sections,
    super.key,
  });

  final String heading;
  final List<SettingsInfoSection> sections;

  @override
  State<SettingsInfoHoverIcon> createState() => _SettingsInfoHoverIconState();
}

/// General settings info icon.
class SettingsInfoIconButton extends StatelessWidget {
  const SettingsInfoIconButton({
    required this.heading,
    required this.infoKey,
    super.key,
  });

  final String heading;
  final GeneralSettingsInfoKey infoKey;

  @override
  Widget build(BuildContext context) {
    return SettingsInfoHoverIcon(
      heading: heading,
      sections: GeneralSettingsInfoCatalog.sectionsFor(infoKey),
    );
  }
}

class _SettingsInfoHoverIconState extends State<SettingsInfoHoverIcon> {
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  ScrollPosition? _scrollPosition;

  var _overIcon = false;
  var _overTooltip = false;

  static const _tooltipWidth = 300.0;
  static const _tooltipBg = Color(0xFF4A4A4A);
  static const _edgePadding = 8.0;
  static const _gap = 6.0;

  @override
  void dispose() {
    _detachScrollListener();
    _hideTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _detachScrollListener() {
    _scrollPosition?.removeListener(_onAncestorScroll);
    _scrollPosition = null;
  }

  void _onAncestorScroll() {
    _overIcon = false;
    _overTooltip = false;
    _removeOverlay();
  }

  void _cancelHideTimer() => _hideTimer?.cancel();

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 120), () {
      if (!_overIcon && !_overTooltip) {
        _removeOverlay();
      }
    });
  }

  Rect? _anchorRect(OverlayState overlay) {
    final box = context.findRenderObject() as RenderBox?;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || overlayBox == null) return null;
    final topLeft = overlayBox.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    final anchor = _anchorRect(overlay);
    if (anchor == null) return;
    _detachScrollListener();
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onAncestorScroll);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return _AnchoredSettingsInfoTooltip(
          anchor: anchor,
          heading: widget.heading,
          sections: widget.sections,
          width: _tooltipWidth,
          backgroundColor: _tooltipBg,
          edgePadding: _edgePadding,
          gap: _gap,
          onPointerEnter: () {
            _overTooltip = true;
            _cancelHideTimer();
          },
          onPointerExit: () {
            _overTooltip = false;
            _scheduleHide();
          },
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _detachScrollListener();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onIconEnter(PointerEnterEvent _) {
    _overIcon = true;
    _cancelHideTimer();
    _showOverlay();
  }

  void _onIconExit(PointerExitEvent _) {
    _overIcon = false;
    _scheduleHide();
  }

  void _onIconTap() {
    if (!AppPlatform.current.isMobile) return;
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _overIcon = true;
    _showOverlay();
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 6), () {
      _overIcon = false;
      _overTooltip = false;
      _removeOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onIconEnter,
      onExit: _onIconExit,
      cursor: SystemMouseCursors.help,
      child: GestureDetector(
        onTap: _onIconTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.textSecondary.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

/// Positions tooltip above or below the anchor, clamped to the viewport.
class _AnchoredSettingsInfoTooltip extends StatefulWidget {
  const _AnchoredSettingsInfoTooltip({
    required this.anchor,
    required this.heading,
    required this.sections,
    required this.width,
    required this.backgroundColor,
    required this.edgePadding,
    required this.gap,
    required this.onPointerEnter,
    required this.onPointerExit,
  });

  final Rect anchor;
  final String heading;
  final List<SettingsInfoSection> sections;
  final double width;
  final Color backgroundColor;
  final double edgePadding;
  final double gap;
  final VoidCallback onPointerEnter;
  final VoidCallback onPointerExit;

  @override
  State<_AnchoredSettingsInfoTooltip> createState() =>
      _AnchoredSettingsInfoTooltipState();
}

class _AnchoredSettingsInfoTooltipState
    extends State<_AnchoredSettingsInfoTooltip> {
  final GlobalKey _measureKey = GlobalKey();
  _TooltipPlacement? _placement;
  double _measuredHeight = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _remeasure());
  }

  void _remeasure() {
    if (!mounted) return;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _remeasure());
      return;
    }

    final media = MediaQuery.of(context);
    final screen = media.size;
    final minTop = media.padding.top + 56;
    final maxBottom = screen.height - media.padding.bottom - 8;

    final tooltipH = box.size.height;
    final spaceAbove = widget.anchor.top - minTop;
    final spaceBelow = maxBottom - widget.anchor.bottom;

    final fitsAbove = spaceAbove >= tooltipH + widget.gap;
    final fitsBelow = spaceBelow >= tooltipH + widget.gap;

    _TooltipPlacement placement;
    if (fitsAbove) {
      placement = _TooltipPlacement.above;
    } else if (fitsBelow) {
      placement = _TooltipPlacement.below;
    } else if (spaceBelow >= spaceAbove) {
      placement = _TooltipPlacement.below;
    } else {
      placement = _TooltipPlacement.above;
    }

    final heightChanged = (tooltipH - _measuredHeight).abs() > 0.5;
    if (_placement != placement || heightChanged) {
      setState(() {
        _placement = placement;
        _measuredHeight = tooltipH;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final minTop = media.padding.top + 56;
    final maxBottom = media.size.height - media.padding.bottom - 8;

    final placement = _placement ??
        (widget.anchor.top < minTop + 100
            ? _TooltipPlacement.below
            : _TooltipPlacement.above);
    final showBelow = placement == _TooltipPlacement.below;

    var left = widget.anchor.center.dx - widget.width / 2;
    left = left.clamp(
      widget.edgePadding,
      screenW - widget.width - widget.edgePadding,
    );
    final arrowCenterX = (widget.anchor.center.dx - left).clamp(
      16.0,
      widget.width - 16.0,
    );

    final bubble = MouseRegion(
      onEnter: (_) => widget.onPointerEnter(),
      onExit: (_) => widget.onPointerExit(),
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        child: _SettingsInfoTooltipBubble(
          key: _measureKey,
          heading: widget.heading,
          sections: widget.sections,
          width: widget.width,
          backgroundColor: widget.backgroundColor,
          arrowPointsDown: !showBelow,
          arrowCenterX: arrowCenterX,
        ),
      ),
    );

    final tooltipH = _measuredHeight;

    double top;
    if (showBelow) {
      top = widget.anchor.bottom + widget.gap;
      top = top.clamp(minTop, maxBottom - tooltipH);
    } else {
      top = widget.anchor.top - tooltipH - widget.gap;
      top = top.clamp(minTop, widget.anchor.top - widget.gap);
      if (tooltipH > 0 && top + tooltipH > widget.anchor.top - widget.gap) {
        top = (widget.anchor.top - tooltipH - widget.gap).clamp(minTop, top);
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: left, top: top, child: bubble),
      ],
    );
  }
}

enum _TooltipPlacement { above, below }

class _SettingsInfoTooltipBubble extends StatelessWidget {
  const _SettingsInfoTooltipBubble({
    required this.heading,
    required this.sections,
    required this.width,
    required this.backgroundColor,
    required this.arrowPointsDown,
    required this.arrowCenterX,
    super.key,
  });

  final String heading;
  final List<SettingsInfoSection> sections;
  final double width;
  final Color backgroundColor;
  final bool arrowPointsDown;
  final double arrowCenterX;

  static const _maxTooltipHeight = 320.0;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: width,
      constraints: const BoxConstraints(maxHeight: _maxTooltipHeight),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              heading,
              style: AppTypography.inter(
                fontSize: AppTypography.bodyMediumSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              Text(
                sections[i].title,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySmallSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sections[i].body,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySmallSize,
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final arrow = SizedBox(
      width: width,
      height: 7,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: (arrowCenterX - 7).clamp(0, width - 14)),
          child: CustomPaint(
            size: const Size(14, 7),
            painter: _TooltipArrowPainter(
              color: backgroundColor,
              pointsDown: arrowPointsDown,
            ),
          ),
        ),
      ),
    );

    if (arrowPointsDown) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [body, arrow],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [arrow, body],
    );
  }
}

class _TooltipArrowPainter extends CustomPainter {
  _TooltipArrowPainter({required this.color, required this.pointsDown});

  final Color color;
  final bool pointsDown;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsDown) {
      path
        ..moveTo(size.width / 2, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0)
        ..close();
    } else {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TooltipArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointsDown != pointsDown;
}
