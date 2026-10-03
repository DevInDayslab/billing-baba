import 'dart:async';
import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:collection/collection.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/utils/gst_tax_rate_catalog.dart';
import 'package:billing_baba/features/inventory/utils/item_tax_rate_preference.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/gst_tax_rate_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// GST tax rate picker with inline search and colored rate badges.
class GstTaxRateSelectDropdown extends ConsumerStatefulWidget {
  const GstTaxRateSelectDropdown({
    required this.value,
    required this.onSelected,
    this.borderless = false,
    this.triggerHeight,
    this.maxMenuHeight = 300,
    super.key,
  });

  final String value;
  final ValueChanged<String> onSelected;
  final bool borderless;
  final double? triggerHeight;
  final double maxMenuHeight;

  @override
  ConsumerState<GstTaxRateSelectDropdown> createState() =>
      _GstTaxRateSelectDropdownState();
}

class _GstTaxRateSelectDropdownState
    extends ConsumerState<GstTaxRateSelectDropdown> {
  final GlobalKey _triggerKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  OverlayEntry? _overlayEntry;

  bool _isOpen = false;
  bool _triggerHovered = false;
  String? _pinnedDefaultRate;

  double _menuLeft = 0;
  double _menuTop = 0;
  double _menuWidth = 320;
  double _menuHeight = 300;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPinnedDefault());
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPinnedDefault() async {
    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId == null) return;
    final pinned = await ItemTaxRatePreference.readPinned(businessId);
    if (!mounted) return;
    setState(() => _pinnedDefaultRate = pinned);
  }

  void _scheduleRebuild() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(() {});
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  GstTaxRateOption? _selectedOption() {
    return GstTaxRateCatalog.allOptions()
            .where((option) => option.value == widget.value)
            .firstOrNull ??
        GstTaxRateCatalog.findByValue(widget.value);
  }

  bool get _isCurrentValuePinned => _pinnedDefaultRate == widget.value;

  Future<void> _togglePinDefault() async {
    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId == null) return;

    if (_isCurrentValuePinned) {
      await ItemTaxRatePreference.clearPinned(businessId);
      if (!mounted) return;
      setState(() => _pinnedDefaultRate = null);
      return;
    }

    await ItemTaxRatePreference.writePinned(businessId, widget.value);
    if (!mounted) return;
    setState(() => _pinnedDefaultRate = widget.value);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _searchFocusNode.unfocus();
    if (_isOpen) {
      _isOpen = false;
      _scheduleRebuild();
    }
  }

  void _selectOption(String value) {
    _removeOverlay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onSelected(value);
    });
  }

  void _openOverlay() {
    if (_overlayEntry != null) return;
    _searchController.clear();
    setState(() => _isOpen = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _overlayEntry != null) return;
      _insertOverlay();
    });
  }

  void _insertOverlay() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      _removeOverlay();
      return;
    }

    final triggerOffset = renderBox.localToGlobal(Offset.zero);
    final triggerSize = renderBox.size;
    final viewport = MediaQuery.sizeOf(context);

    _menuWidth = math.max(triggerSize.width, 320.0);
    final spaceBelow =
        viewport.height - (triggerOffset.dy + triggerSize.height) - 12;
    final spaceAbove = triggerOffset.dy - 12;
    final opensBelow = spaceBelow >= 120 || spaceBelow >= spaceAbove;
    _menuHeight = math
        .min(
          widget.maxMenuHeight,
          opensBelow ? spaceBelow : spaceAbove,
        )
        .clamp(100.0, widget.maxMenuHeight)
        .toDouble();

    _menuTop = opensBelow
        ? triggerOffset.dy + triggerSize.height + 4
        : triggerOffset.dy - _menuHeight - 4;
    _menuLeft = triggerOffset.dx.clamp(
      8.0,
      math.max(8.0, viewport.width - _menuWidth - 8),
    );
    _menuTop = _menuTop.clamp(8.0, viewport.height - _menuHeight - 8);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            Positioned(
              left: _menuLeft,
              top: _menuTop,
              width: _menuWidth,
              height: _menuHeight,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                child: _GstTaxRateOverlayMenu(
                  searchController: _searchController,
                  selectedValue: widget.value,
                  onSelect: _selectOption,
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isOpen) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedOption();
    final displayTitle = selected?.title ?? widget.value;
    final height =
        widget.triggerHeight ??
        (widget.borderless ? saleFieldHeight - 20 : saleFieldHeight);

    final showPinControl =
        _triggerHovered && widget.value.isNotEmpty && !_isOpen;

    return SizedBox(
      key: _triggerKey,
      height: height,
      width: double.infinity,
      child: _isOpen
          ? _GstTaxRateSearchBar(
              height: height,
              controller: _searchController,
              focusNode: _searchFocusNode,
              onClose: _removeOverlay,
            )
          : MouseRegion(
              onEnter: (_) => setState(() => _triggerHovered = true),
              onExit: (_) => setState(() => _triggerHovered = false),
              child: SaleFieldTrigger(
                onTap: _openOverlay,
                borderless: widget.borderless,
                child: Row(
                  children: [
                    if (selected != null && selected.percent != null) ...[
                      GstTaxRateBadge(option: selected, size: 24),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: AppEllipsisText(
                        widget.value.isEmpty ? 'Select tax rate' : displayTitle,
                        style: saleFieldTextStyle.copyWith(
                          color: widget.value.isEmpty
                              ? Colors.grey.shade400
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (showPinControl || _isCurrentValuePinned)
                      _PinDefaultButton(
                        isPinned: _isCurrentValuePinned,
                        visible: showPinControl || _isCurrentValuePinned,
                        onPressed: () => unawaited(_togglePinDefault()),
                      ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PinDefaultButton extends StatelessWidget {
  const _PinDefaultButton({
    required this.isPinned,
    required this.visible,
    required this.onPressed,
  });

  final bool isPinned;
  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: IgnorePointer(
          ignoring: !visible,
          child: IconButton(
            tooltip: isPinned
                ? 'Unpin default tax rate'
                : 'Pin as default tax rate',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onPressed,
            icon: Icon(
              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: 16,
              color: isPinned ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GstTaxRateOverlayMenu extends StatefulWidget {
  const _GstTaxRateOverlayMenu({
    required this.searchController,
    required this.selectedValue,
    required this.onSelect,
  });

  final TextEditingController searchController;
  final String selectedValue;
  final ValueChanged<String> onSelect;

  @override
  State<_GstTaxRateOverlayMenu> createState() => _GstTaxRateOverlayMenuState();
}

class _GstTaxRateOverlayMenuState extends State<_GstTaxRateOverlayMenu> {
  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<GstTaxRateOption> _filteredOptions() {
    final query = widget.searchController.text;
    return GstTaxRateCatalog.allOptions()
        .where((option) => option.matchesQuery(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.searchController.text;
    final filtered = _filteredOptions();
    final showResultsHeader = query.trim().isNotEmpty;

    return filtered.isEmpty
        ? Center(
            child: Text(
              'No matches',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          )
        : ListView(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            children: [
              _SectionHeader(
                label: showResultsHeader ? 'Results' : 'All Tax Rates',
              ),
              for (final option in filtered)
                _GstTaxRateMenuRow(
                  option: option,
                  isSelected: option.value == widget.selectedValue,
                  onSelect: () => widget.onSelect(option.value),
                ),
            ],
          );
  }
}

class _GstTaxRateSearchBar extends StatelessWidget {
  const _GstTaxRateSearchBar({
    required this.height,
    required this.controller,
    required this.focusNode,
    required this.onClose,
  });

  final double height;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
          color: AppColors.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.search,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: saleFieldTextStyle.copyWith(
                    fontSize: 13,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    hintText: 'Search GST rate...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _GstTaxRateMenuRow extends StatelessWidget {
  const _GstTaxRateMenuRow({
    required this.option,
    required this.isSelected,
    required this.onSelect,
  });

  final GstTaxRateOption option;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : null,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
            children: [
              if (option.percent != null) ...[
                GstTaxRateBadge(option: option, size: 26),
                const SizedBox(width: 10),
              ] else
                const SizedBox(width: 36),
              Expanded(
                child: Text(
                  option.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
