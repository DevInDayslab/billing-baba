import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_list_image_warmup.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_list_thumbnail.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_toolbar_add_item_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _toolbarControlHeight = 36.0;
const _maxSearchSuggestions = 8;

/// Products/Services left panel — search (expandable), add, overflow menu.
class InventoryListPanelToolbar extends ConsumerStatefulWidget {
  const InventoryListPanelToolbar({
    required this.searchHint,
    required this.addButtonLabel,
    required this.onSearchChanged,
    required this.onSearchDebounced,
    required this.onAddPressed,
    required this.onImportItems,
    this.initialSearchQuery = '',
    this.onSearchEscape,
    this.onArrowDown,
    this.onArrowUp,
    this.onEnter,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.textStyle,
    this.toolbarMenuItems = const [],
    this.searchResetToken = 0,
    this.searchMatches = const [],
    this.onSearchMatchSelected,
    super.key,
  });

  final String searchHint;
  final String addButtonLabel;
  final String initialSearchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchDebounced;
  final VoidCallback onAddPressed;
  final VoidCallback onImportItems;
  final VoidCallback? onSearchEscape;
  final VoidCallback? onArrowDown;
  final VoidCallback? onArrowUp;
  final VoidCallback? onEnter;
  final Duration debounceDuration;
  final TextStyle? textStyle;
  final List<SalesActionMenuItem> toolbarMenuItems;
  final int searchResetToken;
  final List<InventoryItem> searchMatches;
  final ValueChanged<InventoryItem>? onSearchMatchSelected;

  @override
  ConsumerState<InventoryListPanelToolbar> createState() =>
      _InventoryListPanelToolbarState();
}

class _InventoryListPanelToolbarState extends ConsumerState<InventoryListPanelToolbar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final LayerLink _searchLayerLink = LayerLink();
  OverlayEntry? _suggestionsOverlay;
  Timer? _debounce;
  /// Inline search field visible (not collapsed to icon-only).
  late bool _searchFieldExpanded;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSearchQuery);
    _searchFieldExpanded = widget.initialSearchQuery.isNotEmpty;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onControllerChanged);
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
      _syncSearchFieldExpanded();
    }
    if (widget.searchMatches != oldWidget.searchMatches) {
      _suggestionsOverlay?.markNeedsBuild();
    }
  }

  void _resetSearchField() {
    _controller.text = widget.initialSearchQuery;
    _focusNode.unfocus();
    _removeSuggestionsOverlay();
    _syncSearchFieldExpanded();
  }

  @override
  void dispose() {
    _removeSuggestionsOverlay();
    _debounce?.cancel();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  bool get _hasActiveQuery =>
      _controller.text.isNotEmpty || widget.initialSearchQuery.isNotEmpty;

  bool get _keepSearchFieldVisible =>
      _searchFieldExpanded || _hasActiveQuery || _focusNode.hasFocus;

  void _onControllerChanged() {
    if (_controller.text.isNotEmpty && !_searchFieldExpanded) {
      setState(() => _searchFieldExpanded = true);
    }
  }

  void _syncSearchFieldExpanded() {
    final expanded = _hasActiveQuery || _focusNode.hasFocus;
    if (expanded != _searchFieldExpanded) {
      setState(() => _searchFieldExpanded = expanded);
    }
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      if (!_searchFieldExpanded) {
        setState(() => _searchFieldExpanded = true);
      }
      _syncSuggestionsOverlay();
    } else {
      _removeSuggestionsOverlay();
      if (!_hasActiveQuery && _searchFieldExpanded) {
        setState(() => _searchFieldExpanded = false);
      }
    }
  }

  List<InventoryItem> _visibleSuggestions() {
    if (_controller.text.trim().isEmpty) return const [];
    return widget.searchMatches.take(_maxSearchSuggestions).toList();
  }

  bool _shouldShowSuggestions() =>
      _focusNode.hasFocus && _visibleSuggestions().isNotEmpty;

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  void _syncSuggestionsOverlay() {
    if (!_shouldShowSuggestions()) {
      _removeSuggestionsOverlay();
      return;
    }

    for (final item in _visibleSuggestions()) {
      ref.read(inventoryListImageWarmupProvider).warmItem(item);
    }

    if (_suggestionsOverlay != null) {
      _suggestionsOverlay!.markNeedsBuild();
      return;
    }

    _suggestionsOverlay = OverlayEntry(
      builder: (context) => _SearchSuggestionsOverlay(
        layerLink: _searchLayerLink,
        query: _controller.text,
        suggestions: _visibleSuggestions(),
        onSelected: (item) {
          widget.onSearchMatchSelected?.call(item);
          _removeSuggestionsOverlay();
          _collapseSearch();
        },
        onDismiss: _removeSuggestionsOverlay,
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_suggestionsOverlay!);
  }

  void _collapseSearch() {
    if (_hasActiveQuery) {
      _focusNode.unfocus();
      if (!_searchFieldExpanded) {
        setState(() => _searchFieldExpanded = true);
      }
      return;
    }
    _focusNode.unfocus();
    if (_searchFieldExpanded) {
      setState(() => _searchFieldExpanded = false);
    }
  }

  void _expandSearch() {
    setState(() => _searchFieldExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _handleChanged(String value) {
    widget.onSearchChanged(value);
    _syncSuggestionsOverlay();
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
        _focusNode.unfocus();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        widget.onArrowUp?.call();
        _focusNode.unfocus();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
        widget.onEnter?.call();
        _focusNode.unfocus();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  Widget? _buildSuffixIcon() {
    if (_controller.text.isNotEmpty) {
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
    return CompositedTransformTarget(
      link: _searchLayerLink,
      child: SizedBox(
        height: _toolbarControlHeight,
        child: Focus(
          onKeyEvent: _handleKey,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _handleChanged,
            onTap: () {
              if (!_searchFieldExpanded) {
                setState(() => _searchFieldExpanded = true);
              }
              _syncSuggestionsOverlay();
            },
            showCursor: true,
            cursorColor: AppColors.textPrimary,
            cursorWidth: 2,
            cursorHeight: 18,
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

  Widget _buildAddButton({required bool iconOnly}) {
    return InventoryToolbarAddItemButton(
      label: widget.addButtonLabel,
      iconOnly: iconOnly,
      onAddPressed: widget.onAddPressed,
      onImportItems: widget.onImportItems,
    );
  }

  bool _useIconOnlyAddButton(double maxWidth) {
    final hasMenu = widget.toolbarMenuItems.isNotEmpty;
    final menuWidth = hasMenu ? inventoryListRowMenuWidth : 0.0;
    const labeledAddMinWidth = 88.0;
    const dropdownWidth = inventoryDropdownWidth + 1;
    const gap = 4.0;
    final required = _toolbarControlHeight +
        labeledAddMinWidth +
        dropdownWidth +
        menuWidth +
        gap;
    return maxWidth < required;
  }

  Widget _buildCollapsedToolbar(double maxWidth) {
    final iconOnlyAdd = _useIconOnlyAddButton(maxWidth);
    final hasMenu = widget.toolbarMenuItems.isNotEmpty;

    return Row(
      children: [
        _buildCollapsedSearchTrigger(),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: _buildAddButton(iconOnly: iconOnlyAdd),
                  ),
                ),
                if (hasMenu) ...[
                  const SizedBox(width: 2),
                  SalesActionMenuButton(
                    items: widget.toolbarMenuItems,
                    iconButtonConstraints: const BoxConstraints(
                      minWidth: inventoryListRowMenuWidth,
                      minHeight: inventoryListRowMenuWidth,
                      maxWidth: inventoryListRowMenuWidth,
                      maxHeight: inventoryListRowMenuWidth,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Full-width search only — Add Item and overflow menu return when collapsed.
  Widget _buildExpandedToolbar() => _buildSearchField();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 280.0;

        return SizedBox(
          height: _toolbarControlHeight,
          width: fullWidth,
          child: _keepSearchFieldVisible
              ? _buildExpandedToolbar()
              : _buildCollapsedToolbar(fullWidth),
        );
      },
    );
  }
}

class _SearchSuggestionsOverlay extends StatelessWidget {
  const _SearchSuggestionsOverlay({
    required this.layerLink,
    required this.query,
    required this.suggestions,
    required this.onSelected,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final String query;
  final List<InventoryItem> suggestions;
  final ValueChanged<InventoryItem> onSelected;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            elevation: 4,
            shadowColor: Colors.black26,
            borderRadius: AppRadius.mdBorder,
            clipBehavior: Clip.antiAlias,
            color: AppColors.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return InkWell(
                    onTap: () => onSelected(item),
                    hoverColor: const Color(0xFFF5F5F5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          InventoryItemListThumbnail(item: item),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: InventoryHighlightedText(
                              text: item.name,
                              query: query,
                              style: InventoryStyles.listPanelCompactCellStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
