import 'dart:async';
import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/permissions/permission_gate.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _toolbarControlHeight = 36.0;
const _expandDuration = Duration(milliseconds: 280);

/// Products/Services left panel — search (expandable), add, overflow menu.
class InventoryListPanelToolbar extends StatefulWidget {
  const InventoryListPanelToolbar({
    required this.searchHint,
    required this.addButtonLabel,
    required this.onSearchChanged,
    required this.onSearchDebounced,
    required this.onAddPressed,
    this.initialSearchQuery = '',
    this.onSearchEscape,
    this.onArrowDown,
    this.onArrowUp,
    this.onEnter,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.textStyle,
    this.toolbarMenuItems = const [],
    this.searchResetToken = 0,
    super.key,
  });

  final String searchHint;
  final String addButtonLabel;
  final String initialSearchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchDebounced;
  final VoidCallback onAddPressed;
  final VoidCallback? onSearchEscape;
  final VoidCallback? onArrowDown;
  final VoidCallback? onArrowUp;
  final VoidCallback? onEnter;
  final Duration debounceDuration;
  final TextStyle? textStyle;
  final List<SalesActionMenuItem> toolbarMenuItems;
  final int searchResetToken;

  @override
  State<InventoryListPanelToolbar> createState() =>
      _InventoryListPanelToolbarState();
}

class _InventoryListPanelToolbarState extends State<InventoryListPanelToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;
  var _hasText = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: _expandDuration,
    );
    _controller = TextEditingController(text: widget.initialSearchQuery);
    _hasText = widget.initialSearchQuery.isNotEmpty;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_syncHasText);
  }

  @override
  void didUpdateWidget(InventoryListPanelToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchResetToken != oldWidget.searchResetToken) {
      _resetSearchField();
      return;
    }
    if (widget.initialSearchQuery != oldWidget.initialSearchQuery &&
        widget.initialSearchQuery != _controller.text) {
      _controller.text = widget.initialSearchQuery;
      _hasText = widget.initialSearchQuery.isNotEmpty;
      if (widget.initialSearchQuery.isEmpty) {
        _collapseSearch(animate: false);
      }
    }
  }

  void _resetSearchField() {
    _controller.text = widget.initialSearchQuery;
    _hasText = widget.initialSearchQuery.isNotEmpty;
    _focusNode.unfocus();
    _expandController.value = 0;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _expandController.dispose();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller
      ..removeListener(_syncHasText)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (!_focusNode.hasFocus && _expandController.value > 0) {
      _expandController.reverse();
    }
  }

  void _collapseSearch({bool animate = true}) {
    if (_expandController.value == 0) {
      _focusNode.unfocus();
      return;
    }
    if (animate) {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      } else {
        _expandController.reverse();
      }
    } else {
      _focusNode.unfocus();
      _expandController.value = 0;
    }
  }

  double _expandProgress() {
    final t = _expandController.value;
    final reversing = _expandController.status == AnimationStatus.reverse;
    final curve = reversing ? Curves.easeInCubic : Curves.easeOutCubic;
    return curve.transform(t);
  }

  void _syncHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText == _hasText) return;
    setState(() => _hasText = hasText);
  }

  void _expandSearch() {
    _expandController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _handleChanged(String value) {
    widget.onSearchChanged(value);
    _debounce?.cancel();
    if (widget.debounceDuration == Duration.zero) {
      widget.onSearchDebounced(value);
      return;
    }
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearchDebounced(value);
    });
  }

  void _clearSearch() {
    if (_controller.text.isEmpty) return;
    _controller.clear();
    _handleChanged('');
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        if (_controller.text.isNotEmpty) {
          _clearSearch();
        } else {
          widget.onSearchEscape?.call();
          _collapseSearch();
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        widget.onArrowDown?.call();
        _collapseSearch();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        widget.onArrowUp?.call();
        _collapseSearch();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
        widget.onEnter?.call();
        _collapseSearch();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  Widget? _buildSuffixIcon() {
    if (_hasText) {
      return IconButton(
        onPressed: _clearSearch,
        icon: const Icon(Icons.close, size: 18),
        color: Colors.grey.shade600,
        tooltip: 'Clear search',
      );
    }
    return Icon(Icons.search, size: 18, color: Colors.grey.shade500);
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: _toolbarControlHeight,
      child: Focus(
        onKeyEvent: _handleKey,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _handleChanged,
          style: widget.textStyle ?? saleFieldTextStyle.copyWith(fontSize: 12),
          decoration:
              buildSaleFieldDecoration(
                hint: widget.searchHint,
                suffixIcon: _buildSuffixIcon(),
              ).copyWith(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
        ),
      ),
    );
  }

  Widget _buildCollapsedSearchTrigger() {
    return IconButton(
      onPressed: _expandSearch,
      icon: const Icon(Icons.search, size: 20),
      color: AppColors.textSecondary,
      tooltip: 'Search',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: _toolbarControlHeight,
        minHeight: _toolbarControlHeight,
      ),
    );
  }

  Widget _buildAddButton() {
    return PermissionGate(
      module: PermissionModule.item,
      action: PermissionAction.create,
      child: FilledButton(
        onPressed: widget.onAddPressed,
        style: FilledButton.styleFrom(
          backgroundColor: inventoryPrimaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, _toolbarControlHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 18),
            const SizedBox(width: 6),
            Text(
              widget.addButtonLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedToolbar() {
    return Row(
      children: [
        _buildCollapsedSearchTrigger(),
        const Spacer(),
        _buildAddButton(),
        SalesActionMenuButton(
          items: widget.toolbarMenuItems,
          iconButtonConstraints: const BoxConstraints(
            minWidth: _toolbarControlHeight,
            minHeight: _toolbarControlHeight,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandController,
      builder: (context, _) {
        final expand = _expandProgress();
        final collapsedFade = 1 - expand;

        return LayoutBuilder(
          builder: (context, constraints) {
            final fullWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 280.0;

            return SizedBox(
              height: _toolbarControlHeight,
              width: fullWidth,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  if (collapsedFade > 0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: collapsedFade.clamp(0, 1),
                        child: IgnorePointer(
                          ignoring: expand > 0.05,
                          child: _buildCollapsedToolbar(),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: math.max(expand, 0.001),
                        child: Opacity(
                          opacity: expand.clamp(0, 1),
                          child: IgnorePointer(
                            ignoring: expand < 0.95,
                            child: _buildSearchField(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
