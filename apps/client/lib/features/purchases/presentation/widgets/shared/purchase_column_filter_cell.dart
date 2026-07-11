import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/filter_icon.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const purchaseColumnFilterPopupMinWidth = 200.0;
const purchaseColumnFilterNumericPopupMinWidth = 280.0;
const purchaseColumnFilterPopupMaxHeight = 360.0;
const purchaseColumnFilterPopupOffset = Offset(0, 4);

bool purchaseColumnFilterKindIsNumeric(PurchaseColumnFilterKind kind) =>
    switch (kind) {
      PurchaseColumnFilterKind.amount ||
      PurchaseColumnFilterKind.balanceDue ||
      PurchaseColumnFilterKind.totalAmount ||
      PurchaseColumnFilterKind.paidAmount ||
      PurchaseColumnFilterKind.receivedPaid =>
        true,
      _ => false,
    };

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

    final isNumericFilter = purchaseColumnFilterKindIsNumeric(widget.kind);
    final minWidth = isNumericFilter
        ? purchaseColumnFilterNumericPopupMinWidth
        : purchaseColumnFilterPopupMinWidth;
    final menuWidth = renderBox.size.width < minWidth
        ? minWidth
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
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior:
                    isNumericFilter ? Clip.none : Clip.antiAlias,
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

    final trigger = InkWell(
      onTap: _onFilterTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: widget.alignment,
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
            ),
            AppFilterIcon(color: filterColor),
          ],
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
      child: SizedBox(
        width: double.infinity,
        child: cellChild,
      ),
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: content);
    }

    return content;
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

class PurchaseColumnPaymentTypeCheckboxPanel extends StatefulWidget {
  const PurchaseColumnPaymentTypeCheckboxPanel({
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onClear,
    super.key,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  @override
  State<PurchaseColumnPaymentTypeCheckboxPanel> createState() =>
      _PurchaseColumnPaymentTypeCheckboxPanelState();
}

class _PurchaseColumnPaymentTypeCheckboxPanelState
    extends State<PurchaseColumnPaymentTypeCheckboxPanel> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selected);
  }

  void _toggle(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {
        _selected.add(option);
      }
    });
    widget.onToggle(option);
  }

  void _clear() {
    setState(() => _selected = {});
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (final option in widget.options)
                CheckboxListTile(
                  value: _selected.contains(option),
                  onChanged: (_) => _toggle(option),
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            0,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _selected.isEmpty ? null : _clear,
              child: const Text('Clear'),
            ),
          ),
        ),
      ],
    );
  }
}

class PurchaseColumnAdvancedNumericFilterPanel extends StatefulWidget {
  const PurchaseColumnAdvancedNumericFilterPanel({
    required this.valueLabel,
    required this.initialFilter,
    required this.onApply,
    required this.onClear,
    super.key,
  });

  final String valueLabel;
  final PurchaseNumericFilter? initialFilter;
  final ValueChanged<PurchaseNumericFilter> onApply;
  final VoidCallback onClear;

  @override
  State<PurchaseColumnAdvancedNumericFilterPanel> createState() =>
      _PurchaseColumnAdvancedNumericFilterPanelState();
}

class _PurchaseColumnAdvancedNumericFilterPanelState
    extends State<PurchaseColumnAdvancedNumericFilterPanel> {
  static const _fieldBorderColor = Color(0xFFE2E8F0);
  static const _fieldFillColor = Color(0xFFF8FAFC);

  late PurchaseNumericFilterOperator _operator;
  late final TextEditingController _valueController;
  bool _operatorExpanded = false;

  @override
  void initState() {
    super.initState();
    _operator =
        widget.initialFilter?.operator ?? PurchaseNumericFilterOperator.equalTo;
    _valueController = TextEditingController(
      text: widget.initialFilter?.value.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: _fieldFillColor,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      prefixText: prefixText,
      prefixStyle: prefixText != null
          ? const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.2,
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: _fieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: _fieldBorderColor),
      ),
    );
  }

  void _handleApply() {
    final value = _parseAmount(_valueController.text);
    if (value == null) return;
    widget.onApply(PurchaseNumericFilter(operator: _operator, value: value));
  }

  void _handleClear() {
    _valueController.clear();
    setState(() {
      _operator = PurchaseNumericFilterOperator.equalTo;
      _operatorExpanded = false;
    });
    widget.onClear();
  }

  void _selectOperator(PurchaseNumericFilterOperator operator) {
    setState(() {
      _operator = operator;
      _operatorExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canApply = _parseAmount(_valueController.text) != null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter ${widget.valueLabel}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Select Category',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _PurchaseColumnInlineOperatorSelector(
            selected: _operator,
            expanded: _operatorExpanded,
            onToggle: () => setState(
              () => _operatorExpanded = !_operatorExpanded,
            ),
            onSelected: _selectOperator,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _valueController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _fieldDecoration(
              label: widget.valueLabel,
              prefixText: '₹ ',
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: _fieldBorderColor),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: _fieldBorderColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: canApply ? _handleApply : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PurchaseColumnInlineOperatorSelector extends StatelessWidget {
  const _PurchaseColumnInlineOperatorSelector({
    required this.selected,
    required this.expanded,
    required this.onToggle,
    required this.onSelected,
  });

  static const _fieldBorderColor = Color(0xFFE2E8F0);
  static const _fieldFillColor = Color(0xFFF8FAFC);
  static const _optionHoverColor = Color(0xFFF1F5F9);

  final PurchaseNumericFilterOperator selected;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<PurchaseNumericFilterOperator> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _fieldFillColor,
        borderRadius: AppRadius.smBorder,
        border: Border.all(
          color: expanded ? AppColors.primary : _fieldBorderColor,
          width: expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onToggle,
              borderRadius: expanded
                  ? const BorderRadius.vertical(top: Radius.circular(7))
                  : AppRadius.smBorder,
              hoverColor: _optionHoverColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm + 2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: _fieldBorderColor),
            for (final option in PurchaseNumericFilterOperator.values)
              _PurchaseColumnOperatorOptionTile(
                label: option.label,
                selected: option == selected,
                isLast: option == PurchaseNumericFilterOperator.values.last,
                onTap: () => onSelected(option),
              ),
          ],
        ],
      ),
    );
  }
}

class _PurchaseColumnOperatorOptionTile extends StatelessWidget {
  const _PurchaseColumnOperatorOptionTile({
    required this.label,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  static const _optionHoverColor = Color(0xFFF1F5F9);

  final String label;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: _optionHoverColor,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(7))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
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
