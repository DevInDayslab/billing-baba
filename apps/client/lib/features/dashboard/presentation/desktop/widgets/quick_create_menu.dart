import 'dart:math' as math;

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/application/quick_create_executor.dart';
import 'package:billing_baba/features/dashboard/application/quick_create_menu_provider.dart';
import 'package:billing_baba/features/dashboard/models/quick_create_action.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/shared/widgets/keyboard_shortcut_badge.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popover_positioner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _popoverWidth = 920.0;
const _popoverMinHeight = 380.0;
const _footerColor = Color(0xFFFFF9C4);
const _triggerColor = Color(0xFFF0F0F0);
const _itemHoverColor = Color(0xFFE3F2FD);
const _itemLabelColor = Color(0xFF1565C0);

/// + button that opens the 3-column quick-create popover.
class QuickCreateMenuButton extends ConsumerStatefulWidget {
  const QuickCreateMenuButton({super.key});

  @override
  ConsumerState<QuickCreateMenuButton> createState() =>
      _QuickCreateMenuButtonState();
}

class _QuickCreateMenuButtonState extends ConsumerState<QuickCreateMenuButton> {
  final _layerLink = LayerLink();
  final GlobalKey<State<StatefulWidget>> _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  QuickCreateMenuController? _menuController;
  var _isOpen = false;
  var _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _registerController());
  }

  @override
  void dispose() {
    _menuController?.unregister();
    _removeOverlay();
    super.dispose();
  }

  void _registerController() {
    _menuController = ref.read(quickCreateMenuProvider);
    _menuController!.register(
          toggle: _toggleMenu,
          close: _closeMenu,
          isOpen: () => _isOpen,
        );
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    if (_isOpen) return;
    _focusedIndex = 0;
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _QuickCreatePopover(
        layerLink: _layerLink,
        triggerKey: _triggerKey,
        focusedIndex: _focusedIndex,
        onAction: _onActionSelected,
        onDismiss: _closeMenu,
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeMenu() {
    _removeOverlay();
    if (_isOpen) {
      setState(() => _isOpen = false);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onActionSelected(QuickCreateAction action) {
    _closeMenu();
    executeQuickCreate(context, ref, action);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: _triggerKey,
      link: _layerLink,
      child: Tooltip(
        message: 'Quick create',
        child: InkWell(
          onTap: _toggleMenu,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Ink(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _triggerColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: DashboardColors.border),
            ),
            child: const Icon(
              Icons.add,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickCreatePopover extends StatelessWidget {
  const _QuickCreatePopover({
    required this.layerLink,
    required this.triggerKey,
    required this.focusedIndex,
    required this.onAction,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final GlobalKey triggerKey;
  final int focusedIndex;
  final ValueChanged<QuickCreateAction> onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final popoverWidth = math.min(
      _popoverWidth,
      viewport.width - FilterPopoverPositioner.screenPadding * 2,
    );
    final triggerBox =
        triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerRect = triggerBox == null
        ? null
        : triggerBox.localToGlobal(Offset.zero) & triggerBox.size;

    final placement = triggerRect == null
        ? (
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, FilterPopoverPositioner.verticalGap),
          )
        : FilterPopoverPositioner.resolveFollower(
            triggerRect: triggerRect,
            popoverSize: Size(popoverWidth, _popoverMinHeight),
            viewportSize: viewport,
          );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
            child: const ColoredBox(color: Color(0x1A000000)),
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          targetAnchor: placement.targetAnchor,
          followerAnchor: placement.followerAnchor,
          offset: placement.offset,
          showWhenUnlinked: false,
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            color: AppColors.surface,
            borderRadius: AppRadius.mdBorder,
            child: Container(
              width: popoverWidth,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(color: DashboardColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.md,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _QuickCreateColumn(
                              title: 'SALE',
                              actions: QuickCreateActions.forCategory(
                                QuickCreateCategory.sale,
                              ),
                              flatActions: QuickCreateActions.available,
                              focusedIndex: focusedIndex,
                              onAction: onAction,
                            ),
                          ),
                          const _ColumnDivider(),
                          Expanded(
                            child: _QuickCreateColumn(
                              title: 'PURCHASE',
                              actions: QuickCreateActions.forCategory(
                                QuickCreateCategory.purchase,
                              ),
                              flatActions: QuickCreateActions.available,
                              focusedIndex: focusedIndex,
                              onAction: onAction,
                            ),
                          ),
                          const _ColumnDivider(),
                          Expanded(
                            child: _QuickCreateColumn(
                              title: 'OTHERS',
                              actions: QuickCreateActions.forCategory(
                                QuickCreateCategory.others,
                              ),
                              flatActions: QuickCreateActions.available,
                              focusedIndex: focusedIndex,
                              onAction: onAction,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _QuickCreateFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColumnDivider extends StatelessWidget {
  const _ColumnDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: DashboardColors.divider,
      ),
    );
  }
}

class _QuickCreateColumn extends StatelessWidget {
  const _QuickCreateColumn({
    required this.title,
    required this.actions,
    required this.flatActions,
    required this.focusedIndex,
    required this.onAction,
  });

  final String title;
  final List<QuickCreateAction> actions;
  final List<QuickCreateAction> flatActions;
  final int focusedIndex;
  final ValueChanged<QuickCreateAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final action in actions)
          _QuickCreateMenuItem(
            action: action,
            isFocused: flatActions.indexOf(action) == focusedIndex,
            onTap: () => onAction(action),
          ),
      ],
    );
  }
}

class _QuickCreateMenuItem extends StatefulWidget {
  const _QuickCreateMenuItem({
    required this.action,
    required this.isFocused,
    required this.onTap,
  });

  final QuickCreateAction action;
  final bool isFocused;
  final VoidCallback onTap;

  @override
  State<_QuickCreateMenuItem> createState() => _QuickCreateMenuItemState();
}

class _QuickCreateMenuItemState extends State<_QuickCreateMenuItem> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.isFocused || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: highlighted ? _itemHoverColor : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(4),
          hoverColor: _itemHoverColor,
          splashColor: _itemHoverColor,
          highlightColor: _itemHoverColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.play_arrow,
                    size: 15,
                    color: _itemLabelColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.action.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _itemLabelColor,
                          height: 1.25,
                        ),
                      ),
                      if (widget.action.subtitle != null)
                        Text(
                          widget.action.subtitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.25,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.action.shortcutKey != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: KeyboardShortcutBadge.forActivator(
                      SingleActivator(
                        widget.action.shortcutKey!,
                        alt: true,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickCreateFooter extends StatelessWidget {
  const _QuickCreateFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _footerColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Text(
            'Shortcut to open this menu :',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          KeyboardShortcutBadge.platformOpenMenu(),
        ],
      ),
    );
  }
}

/// Keyboard shortcut intents for the shell-level quick-create scope.
class ToggleQuickCreateIntent extends Intent {
  const ToggleQuickCreateIntent();
}

class DismissQuickCreateIntent extends Intent {
  const DismissQuickCreateIntent();
}

class ExecuteQuickCreateIntent extends Intent {
  const ExecuteQuickCreateIntent(this.actionId);

  final String actionId;
}

/// Builds shortcut map for the shell — open menu + per-item Alt shortcuts.
Map<ShortcutActivator, Intent> buildQuickCreateShortcuts() {
  final shortcuts = <ShortcutActivator, Intent>{
    if (AppPlatform.current.isMacOS)
      const SingleActivator(
        LogicalKeyboardKey.enter,
        meta: true,
      ): const ToggleQuickCreateIntent()
    else
      const SingleActivator(
        LogicalKeyboardKey.enter,
        control: true,
      ): const ToggleQuickCreateIntent(),
    const SingleActivator(LogicalKeyboardKey.escape):
        const DismissQuickCreateIntent(),
  };

  for (final action in QuickCreateActions.available) {
    final key = action.shortcutKey;
    if (key == null) continue;
    shortcuts[SingleActivator(key, alt: true)] = ExecuteQuickCreateIntent(
      action.id,
    );
  }

  return shortcuts;
}

/// Returns true when global quick-create shortcuts should be suppressed.
bool shouldSuppressQuickCreateShortcuts() {
  final focus = FocusManager.instance.primaryFocus;
  if (focus == null) return false;

  final context = focus.context;
  if (context == null) return false;

  return context.widget is EditableText ||
      context.findAncestorStateOfType<EditableTextState>() != null;
}
