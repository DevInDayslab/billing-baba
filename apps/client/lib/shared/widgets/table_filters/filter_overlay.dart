import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/filter_icon.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popover_positioner.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';
import 'package:flutter/material.dart';

/// Shared overlay anchor for column filter triggers with screen-edge awareness.
class FilterOverlayAnchor {
  FilterOverlayAnchor({
    required this.layerLink,
    required this.triggerKey,
  });

  final LayerLink layerLink;
  final GlobalKey triggerKey;
  OverlayEntry? _overlayEntry;

  void dispose() {
    removeOverlay();
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void toggle({
    required BuildContext context,
    required Widget popover,
    Size? estimatedSize,
  }) {
    if (_overlayEntry != null) {
      removeOverlay();
      return;
    }
    show(
      context: context,
      popover: popover,
      estimatedSize: estimatedSize,
      onDismiss: removeOverlay,
    );
  }

  void show({
    required BuildContext context,
    required Widget popover,
    required VoidCallback onDismiss,
    Size? estimatedSize,
  }) {
    final renderBox =
        triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final size =
        estimatedSize ??
        const Size(
          TableFilterTheme.popoverWidth,
          TableFilterTheme.defaultPopoverHeight,
        );

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
              ),
            ),
            _AnchoredFilterPopover(
              layerLink: layerLink,
              triggerKey: triggerKey,
              estimatedSize: size,
              child: popover,
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }
}

class _AnchoredFilterPopover extends StatefulWidget {
  const _AnchoredFilterPopover({
    required this.layerLink,
    required this.triggerKey,
    required this.child,
    required this.estimatedSize,
  });

  final LayerLink layerLink;
  final GlobalKey triggerKey;
  final Widget child;
  final Size estimatedSize;

  @override
  State<_AnchoredFilterPopover> createState() => _AnchoredFilterPopoverState();
}

class _AnchoredFilterPopoverState extends State<_AnchoredFilterPopover> {
  final GlobalKey _popoverKey = GlobalKey();
  Alignment _targetAnchor = Alignment.bottomLeft;
  Alignment _followerAnchor = Alignment.topLeft;
  Offset _offset = const Offset(0, FilterPopoverPositioner.verticalGap);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_updatePlacement);
  }

  void _updatePlacement(_) {
    if (!mounted) return;

    final triggerBox =
        widget.triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (triggerBox == null || !triggerBox.hasSize) return;

    final popoverBox =
        _popoverKey.currentContext?.findRenderObject() as RenderBox?;
    final popoverSize = popoverBox?.hasSize == true
        ? popoverBox!.size
        : widget.estimatedSize;

    final triggerRect = triggerBox.localToGlobal(Offset.zero) & triggerBox.size;
    final viewportSize = MediaQuery.sizeOf(context);
    final placement = FilterPopoverPositioner.resolveFollower(
      triggerRect: triggerRect,
      popoverSize: popoverSize,
      viewportSize: viewportSize,
    );

    final nextOffset = placement.offset;
    if (_targetAnchor != placement.targetAnchor ||
        _followerAnchor != placement.followerAnchor ||
        _offset != nextOffset) {
      setState(() {
        _targetAnchor = placement.targetAnchor;
        _followerAnchor = placement.followerAnchor;
        _offset = nextOffset;
      });
    }

    if (popoverBox == null || !popoverBox.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback(_updatePlacement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: widget.layerLink,
      showWhenUnlinked: false,
      targetAnchor: _targetAnchor,
      followerAnchor: _followerAnchor,
      offset: _offset,
      child: KeyedSubtree(
        key: _popoverKey,
        child: widget.child,
      ),
    );
  }
}

/// Column header filter trigger — label + filter icon with active state.
///
/// The [LayerLink] is attached to the filter icon only so popovers anchor
/// to the icon, not the full header row.
class FilterColumnHeaderTrigger extends StatelessWidget {
  const FilterColumnHeaderTrigger({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.layerLink,
    required this.triggerKey,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.iconOnly = false,
    this.iconColor,
    super.key,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final LayerLink layerLink;
  final GlobalKey triggerKey;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final bool iconOnly;
  final Color? iconColor;

  Widget _buildIconButton() {
    return CompositedTransformTarget(
      link: layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          key: triggerKey,
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            width: 22,
            height: 22,
            child: Center(
              child: AppFilterIcon(
                color:
                    iconColor ??
                    (isActive ? AppColors.error : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return _buildIconButton();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Align(
        alignment: alignment,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: headerStyle ?? TableFilterTheme.defaultHeaderStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: alignment == Alignment.centerRight
                    ? TextAlign.right
                    : TextAlign.left,
              ),
            ),
            const SizedBox(width: 2),
            _buildIconButton(),
          ],
        ),
      ),
    );
  }
}

/// Estimated popover dimensions per filter type — used for initial placement.
abstract final class FilterPopoverSize {
  static Size forType(FilterType type) {
    final width = switch (type) {
      FilterType.number => TableFilterTheme.popoverWidth,
      FilterType.date => TableFilterTheme.datePopoverWidth,
      FilterType.singleSelect => TableFilterTheme.selectPopoverWidth,
      FilterType.multiSelect => TableFilterTheme.checkboxPopoverWidth,
      FilterType.rangeSlider => TableFilterTheme.amountPopoverWidth,
      _ => TableFilterTheme.popoverWidth,
    };
    final height = switch (type) {
      FilterType.date => TableFilterTheme.datePopoverHeight,
      FilterType.multiSelect => TableFilterTheme.multiSelectPopoverHeight,
      FilterType.rangeSlider => TableFilterTheme.rangeSliderPopoverHeight,
      FilterType.boolean => TableFilterTheme.booleanPopoverHeight,
      _ => TableFilterTheme.defaultPopoverHeight,
    };
    return Size(width, height);
  }
}
