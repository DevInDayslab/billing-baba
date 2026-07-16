import 'dart:async';

import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_item_detail_panel.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_left_panel.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared Products/Services workspace: hover preview, selection, split layout.
class InventoryItemWorkspace extends ConsumerStatefulWidget {
  const InventoryItemWorkspace({
    required this.items,
    required this.itemsAsync,
    required this.selectedId,
    required this.searchQuery,
    required this.backendSearchQuery,
    required this.detailMode,
    required this.searchHint,
    required this.addButtonLabel,
    required this.emptyMessage,
    required this.placeholderMessage,
    required this.primaryColumnLabel,
    required this.secondaryColumnLabel,
    required this.trailingValueBuilder,
    required this.trailingColorBuilder,
    required this.onLocalSearchChanged,
    required this.onBackendSearchChanged,
    required this.onSelectedIdChanged,
    required this.onSelectionChangedSideEffects,
    required this.onRefresh,
    required this.onAddPressed,
    required this.onMenuSelected,
    this.leadingIcon = Icons.inventory_2_outlined,
    this.showListFilters = true,
    super.key,
  });

  final List<InventoryItem> items;
  final AsyncValue<List<InventoryItem>> itemsAsync;
  final String? selectedId;
  final String searchQuery;
  final String backendSearchQuery;
  final InventoryDetailHeaderMode detailMode;
  final String searchHint;
  final String addButtonLabel;
  final String emptyMessage;
  final String placeholderMessage;
  final String primaryColumnLabel;
  final String secondaryColumnLabel;
  final String Function(InventoryItem item) trailingValueBuilder;
  final Color? Function(InventoryItem item) trailingColorBuilder;
  final ValueChanged<String> onLocalSearchChanged;
  final ValueChanged<String> onBackendSearchChanged;
  final ValueChanged<String> onSelectedIdChanged;
  final void Function(String previousId, String nextId)
  onSelectionChangedSideEffects;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddPressed;
  final void Function(String value, InventoryItem item) onMenuSelected;
  final IconData leadingIcon;
  final bool showListFilters;

  @override
  ConsumerState<InventoryItemWorkspace> createState() =>
      _InventoryItemWorkspaceState();
}

class _InventoryItemWorkspaceState
    extends ConsumerState<InventoryItemWorkspace> {
  static const _hoverPreviewDelay = Duration(milliseconds: 120);

  final FocusNode _listFocusNode = FocusNode();
  int _focusedIndex = 0;
  int _searchResetToken = 0;
  String? _previewId;
  Timer? _hoverTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _listFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    widget.onLocalSearchChanged(query);
    setState(() => _focusedIndex = 0);
  }

  void _onSearchDebounced(String query) {
    final trimmed = query.trim();
    widget.onBackendSearchChanged(trimmed);
    unawaited(widget.onRefresh());
  }

  void _clearSearch() {
    widget.onLocalSearchChanged('');
    widget.onBackendSearchChanged('');
    unawaited(widget.onRefresh());
    setState(() {
      _focusedIndex = 0;
      _searchResetToken++;
    });
  }

  void _schedulePreview(String id) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(_hoverPreviewDelay, () {
      if (!mounted || _previewId == id) return;
      setState(() => _previewId = id);
    });
  }

  void _setPreviewImmediate(String id) {
    _hoverTimer?.cancel();
    if (_previewId == id) return;
    setState(() => _previewId = id);
  }

  void _moveFocus(int delta) {
    final items = widget.items;
    if (items.isEmpty) return;
    setState(() {
      _focusedIndex = (_focusedIndex + delta).clamp(0, items.length - 1);
    });
    final item = items[_focusedIndex];
    _setPreviewImmediate(item.id);
    widget.onSelectedIdChanged(item.id);
  }

  void _selectFocused() {
    final items = widget.items;
    if (items.isEmpty) return;
    final item = items[_focusedIndex.clamp(0, items.length - 1)];
    _selectItem(item.id);
    _listFocusNode.requestFocus();
  }

  void _selectItem(String id) {
    final previous = widget.selectedId;
    if (previous != id) {
      widget.onSelectionChangedSideEffects(previous ?? '', id);
    }
    _setPreviewImmediate(id);
    widget.onSelectedIdChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final selectedId = widget.selectedId;
    final detailId = _previewId ?? selectedId;

    if (selectedId != null && items.isNotEmpty) {
      final selectedIndex = items.indexWhere((item) => item.id == selectedId);
      if (selectedIndex >= 0 && selectedIndex != _focusedIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _focusedIndex = selectedIndex);
        });
      }
    }

    final detailItem = detailId == null
        ? null
        : items.where((item) => item.id == detailId).firstOrNull;

    return InventorySplitLayout(
      listPanel: Focus(
        focusNode: _listFocusNode,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowDown:
              _moveFocus(1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowUp:
              _moveFocus(-1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.enter:
              _selectFocused();
              return KeyEventResult.handled;
            default:
              return KeyEventResult.ignored;
          }
        },
        child: InventoryLeftPanel(
          items: items,
          itemsAsync: widget.itemsAsync,
          selectedId: selectedId,
          focusedIndex: _focusedIndex,
          searchQuery: widget.searchQuery,
          searchFieldKey: ValueKey(_searchResetToken),
          searchHint: widget.searchHint,
          addButtonLabel: widget.addButtonLabel,
          emptyMessage: widget.emptyMessage,
          primaryColumnLabel: widget.primaryColumnLabel,
          secondaryColumnLabel: widget.secondaryColumnLabel,
          trailingValueBuilder: widget.trailingValueBuilder,
          trailingColorBuilder: widget.trailingColorBuilder,
          leadingIcon: widget.leadingIcon,
          showListFilters: widget.showListFilters,
          onSearchChanged: _onSearchChanged,
          onSearchDebounced: _onSearchDebounced,
          onSearchEscape: _clearSearch,
          onArrowDown: () => _moveFocus(1),
          onArrowUp: () => _moveFocus(-1),
          onEnter: _selectFocused,
          onRefresh: widget.onRefresh,
          onItemHover: _schedulePreview,
          onItemSelected: _selectItem,
          onAddPressed: widget.onAddPressed,
          onMenuSelected: widget.onMenuSelected,
        ),
      ),
      detailPanel: detailId == null || detailItem == null
          ? InventoryDetailPlaceholder(message: widget.placeholderMessage)
          : InventoryItemDetailPanel(
              itemId: detailId,
              fallbackItem: detailItem,
              mode: widget.detailMode,
            ),
    );
  }
}
