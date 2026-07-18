import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/search/application/search_command_executor.dart';
import 'package:billing_baba/features/search/application/search_repository.dart';
import 'package:billing_baba/features/search/domain/search_item.dart';
import 'package:billing_baba/features/search/presentation/widgets/search_empty_state.dart';
import 'package:billing_baba/features/search/presentation/widgets/search_result_row.dart';
import 'package:billing_baba/features/search/presentation/widgets/search_section_header.dart';
import 'package:billing_baba/features/search/providers/search_controller.dart';
import 'package:billing_baba/shared/widgets/keyboard_shortcut_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dialogWidth = 560.0;
const _maxResultsHeight = 400.0;

/// Shows the Search Anything command palette modal.
Future<void> showSearchDialog(BuildContext context, WidgetRef ref) {
  ref.read(searchControllerProvider.notifier).reset();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss search',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (dialogContext, _, _) {
      return Center(
        child: Material(
          elevation: 8,
          borderRadius: AppRadius.mdBorder,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: _dialogWidth,
            child: _SearchDialogBody(
              onClose: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        ),
      );
    },
  );
}

class _SearchDialogBody extends ConsumerStatefulWidget {
  const _SearchDialogBody({required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<_SearchDialogBody> createState() => _SearchDialogBodyState();
}

class _SearchDialogBodyState extends ConsumerState<_SearchDialogBody> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchControllerProvider.notifier).setQuery(value);
  }

  Future<void> _selectItem(SearchItem item) async {
    await executeSearchItem(context, ref, item);
    if (mounted) widget.onClose();
  }

  bool get _hasQuery =>
      ref.read(searchControllerProvider).query.trim().isNotEmpty;

  List<SearchItem> _flatItemsForSections(List<SearchResultSection> sections) {
    return ref.read(searchRepositoryProvider).flattenSections(sections);
  }

  List<SearchItem> _currentFlatItems() {
    if (_hasQuery) {
      return _flatItemsForSections(ref.read(searchResultsProvider));
    }

    final emptyAsync = ref.read(searchEmptySectionsProvider);
    return emptyAsync.maybeWhen(
      data: _flatItemsForSections,
      orElse: () => _flatItemsForSections(
        ref.read(searchRepositoryProvider).suggestedSections(),
      ),
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final flatItems = _currentFlatItems();
    final notifier = ref.read(searchControllerProvider.notifier);
    final highlightedIndex = ref
        .read(searchControllerProvider)
        .highlightedIndex;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.onClose();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        notifier.moveHighlight(1, flatItems.length);
        _scrollToHighlighted();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        notifier.moveHighlight(-1, flatItems.length);
        _scrollToHighlighted();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
        if (flatItems.isNotEmpty && highlightedIndex < flatItems.length) {
          unawaited(_selectItem(flatItems[highlightedIndex]));
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.tab:
        notifier.moveHighlight(
          HardwareKeyboard.instance.isShiftPressed ? -1 : 1,
          flatItems.length,
        );
        _scrollToHighlighted();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  void _scrollToHighlighted() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listScrollController.hasClients) return;
      final index = ref.read(searchControllerProvider).highlightedIndex;
      const rowHeight = 48.0;
      final offset = (index * rowHeight).clamp(
        0.0,
        _listScrollController.position.maxScrollExtent,
      );
      unawaited(
        _listScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  int _globalIndexFor(List<SearchResultSection> sections, SearchItem item) {
    return _flatItemsForSections(sections).indexOf(item);
  }

  Widget _buildResultsList(List<SearchResultSection> sections) {
    final highlightedIndex = ref
        .watch(searchControllerProvider)
        .highlightedIndex;

    if (sections.isEmpty) {
      return const SearchEmptyState();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _maxResultsHeight),
      child: ListView(
        controller: _listScrollController,
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        children: [
          for (final section in sections) ...[
            SearchSectionHeader(title: section.kind.label),
            for (final item in section.items)
              SearchResultRow(
                item: item,
                isHighlighted:
                    _globalIndexFor(sections, item) == highlightedIndex,
                onTap: () => unawaited(_selectItem(item)),
                onHover: () {
                  ref
                      .read(searchControllerProvider.notifier)
                      .setHighlightedIndex(
                        _globalIndexFor(sections, item),
                      );
                },
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchControllerProvider).query.trim();

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search pages and commands…',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          const Divider(height: 1),
          if (query.isNotEmpty)
            Builder(
              builder: (context) {
                final sections = ref.watch(searchResultsProvider);
                if (sections.isEmpty) {
                  return const SearchEmptyState();
                }
                return _buildResultsList(sections);
              },
            )
          else
            ref
                .watch(searchEmptySectionsProvider)
                .when(
                  loading: () => _buildResultsList(
                    ref.read(searchRepositoryProvider).suggestedSections(),
                  ),
                  error: (_, _) => const SearchEmptyState(),
                  data: _buildResultsList,
                ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Text(
                  'Shortcut to open search :',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                KeyboardShortcutBadge.platformOpenSearch(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
