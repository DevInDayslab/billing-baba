import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shows a rounded, scrollable mobile bottom sheet.
///
/// Use for quick actions, filters, payments, menus, and other transient UI.
Future<T?> showMobileBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  Widget? titleWidget,
  Widget? footer,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
  double maxHeightFraction = 0.92,
  double? heightFraction,
  bool scrollBody = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final sheet = MobileBottomSheet(
        title: title,
        titleWidget: titleWidget,
        footer: footer,
        maxHeightFraction: maxHeightFraction,
        heightFraction: heightFraction,
        scrollBody: scrollBody,
        child: builder(sheetContext),
      );

      if (!isDismissible) return sheet;

      // Scroll-controlled sheets fill the screen; transparent areas above the
      // panel do not hit the modal barrier, so we catch outside taps here.
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(sheetContext).pop(),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          sheet,
        ],
      );
    },
  );
}

/// Generic rounded bottom sheet shell — pass any [child] content.
class MobileBottomSheet extends StatelessWidget {
  const MobileBottomSheet({
    required this.child,
    super.key,
    this.title,
    this.titleWidget,
    this.footer,
    this.maxHeightFraction = 0.92,
    this.heightFraction,
    this.scrollBody = true,
  });

  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final Widget? footer;
  final double maxHeightFraction;

  /// When set, locks sheet height so content scrolls inside instead of growing.
  final double? heightFraction;

  /// When false, [child] is placed directly in the body (for internal scroll layouts).
  final bool scrollBody;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final fixedHeight = heightFraction == null
        ? null
        : screenHeight * heightFraction!;
    final maxHeight = screenHeight * maxHeightFraction;
    final resolvedTitle =
        titleWidget ??
        (title == null
            ? null
            : Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ));

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: AppColors.surface,
          elevation: 12,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: fixedHeight == null
                ? ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: _SheetBody(
                      title: resolvedTitle,
                      footer: footer,
                      child: child,
                      expand: false,
                      scrollBody: scrollBody,
                    ),
                  )
                : SizedBox(
                    height: fixedHeight,
                    child: _SheetBody(
                      title: resolvedTitle,
                      footer: footer,
                      child: child,
                      expand: true,
                      scrollBody: scrollBody,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.child,
    required this.expand,
    this.title,
    this.footer,
    this.scrollBody = true,
  });

  final Widget child;
  final Widget? title;
  final Widget? footer;
  final bool expand;
  final bool scrollBody;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        const _DragHandle(),
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: title,
            ),
          ),
        Flexible(
          fit: expand ? FlexFit.tight : FlexFit.loose,
          child: scrollBody
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: child,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: child,
                ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: footer,
          ),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
