import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const purchaseColumnFilterPopupMinWidth = 200.0;
const purchaseColumnFilterPopupMaxHeight = 320.0;
const purchaseColumnFilterPopupOffset = Offset(0, 4);

enum PurchaseColumnFilterKind {
  date,
  dueDate,
  documentNo,
  partyName,
  paymentType,
  amount,
  balanceDue,
  status,
  totalAmount,
  paidAmount,
  categoryName,
  typeName,
  receivedPaid,
}

/// Header filter trigger with an anchored popup below the filter icon.
class PurchaseColumnFilterCell extends StatefulWidget {
  const PurchaseColumnFilterCell({
    required this.label,
    required this.kind,
    required this.headerStyle,
    required this.isActive,
    required this.buildPopupContent,
    this.initialDateRange,
    this.onDateRangeSelected,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.gapAfter = 12,
    super.key,
  });

  final String label;
  final PurchaseColumnFilterKind kind;
  final TextStyle headerStyle;
  final bool isActive;
  final Widget Function(VoidCallback dismiss, VoidCallback dismissAfterSelect)
  buildPopupContent;
  final DateTimeRange? initialDateRange;
  final ValueChanged<DateTimeRange>? onDateRangeSelected;
  final double? width;
  final Alignment alignment;
  final double gapAfter;

  bool get _isDateKind =>
      kind == PurchaseColumnFilterKind.date ||
      kind == PurchaseColumnFilterKind.dueDate;

  @override
  State<PurchaseColumnFilterCell> createState() =>
      _PurchaseColumnFilterCellState();
}

class _PurchaseColumnFilterCellState extends State<PurchaseColumnFilterCell> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey<SaleDateRangePickerAnchorState> _datePickerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onFilterTap() {
    if (widget._isDateKind) {
      _datePickerKey.currentState?.toggle();
      return;
    }

    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showOverlay();
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final menuWidth = renderBox.size.width < purchaseColumnFilterPopupMinWidth
        ? purchaseColumnFilterPopupMinWidth
        : renderBox.size.width;
    final overlay = Overlay.of(context);

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
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              offset: purchaseColumnFilterPopupOffset,
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: menuWidth,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: purchaseColumnFilterPopupMaxHeight,
                    ),
                    child: widget.buildPopupContent(
                      _removeOverlay,
                      _removeOverlay,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final filterColor = widget.isActive
        ? AppColors.textPrimary
        : AppColors.textSecondary.withValues(alpha: 0.7);

    final trigger = Align(
      alignment: widget.alignment,
      child: InkWell(
        onTap: _onFilterTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  style: widget.headerStyle.copyWith(
                    color: widget.isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.filter_list, size: 14, color: filterColor),
            ],
          ),
        ),
      ),
    );

    Widget cellChild;
    if (widget._isDateKind) {
      cellChild = SaleDateRangePickerAnchor(
        key: _datePickerKey,
        initialRange: widget.initialDateRange,
        onRangeSelected: widget.onDateRangeSelected ?? (_) {},
        child: trigger,
      );
    } else {
      cellChild = CompositedTransformTarget(
        link: _layerLink,
        child: trigger,
      );
    }

    final content = ClipRect(
      child: Align(
        alignment: widget.alignment,
        widthFactor: 1,
        child: cellChild,
      ),
    );

    if (widget.width != null) {
      return Padding(
        padding: EdgeInsets.only(right: widget.gapAfter),
        child: SizedBox(width: widget.width, child: content),
      );
    }

    return ClipRect(child: content);
  }
}

class PurchaseColumnTextFilterPanel extends StatefulWidget {
  const PurchaseColumnTextFilterPanel({
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<PurchaseColumnTextFilterPanel> createState() =>
      _PurchaseColumnTextFilterPanelState();
}

class _PurchaseColumnTextFilterPanelState
    extends State<PurchaseColumnTextFilterPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.smBorder,
              ),
              prefixIcon: const Icon(Icons.search, size: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _controller.clear();
                widget.onClear();
              },
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
    );
  }
}

class PurchaseColumnPartyFilterPanel extends StatefulWidget {
  const PurchaseColumnPartyFilterPanel({
    required this.parties,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> parties;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<PurchaseColumnPartyFilterPanel> createState() =>
      _PurchaseColumnPartyFilterPanelState();
}

class _PurchaseColumnPartyFilterPanelState
    extends State<PurchaseColumnPartyFilterPanel> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.parties
        .where(
          (party) =>
              party == 'All Parties' ||
              party.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search party',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.smBorder,
              ),
              prefixIcon: const Icon(Icons.search, size: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (final party in filtered)
                PurchaseColumnFilterMenuItem(
                  label: party,
                  selected: party == widget.selected,
                  onTap: () => widget.onSelected(party),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class PurchaseColumnOptionListPanel extends StatelessWidget {
  const PurchaseColumnOptionListPanel({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        for (final option in options)
          PurchaseColumnFilterMenuItem(
            label: option,
            selected: option == selected,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

class PurchaseColumnNumericRangePanel extends StatefulWidget {
  const PurchaseColumnNumericRangePanel({
    required this.initialMin,
    required this.initialMax,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final double? initialMin;
  final double? initialMax;
  final void Function({double? min, double? max}) onChanged;
  final VoidCallback onClear;

  @override
  State<PurchaseColumnNumericRangePanel> createState() =>
      _PurchaseColumnNumericRangePanelState();
}

class _PurchaseColumnNumericRangePanelState
    extends State<PurchaseColumnNumericRangePanel> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.initialMin?.toStringAsFixed(0) ?? '',
    );
    _maxController = TextEditingController(
      text: widget.initialMax?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      min: _parseAmount(_minController.text),
      max: _parseAmount(_maxController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _minController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Min', isDense: true),
            style: const TextStyle(fontSize: 13),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _maxController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Max', isDense: true),
            style: const TextStyle(fontSize: 13),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _minController.clear();
                _maxController.clear();
                widget.onClear();
              },
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
    );
  }
}

class PurchaseColumnFilterMenuItem extends StatelessWidget {
  const PurchaseColumnFilterMenuItem({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check, size: 16),
          ],
        ),
      ),
    );
  }
}

double? _parseAmount(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}
