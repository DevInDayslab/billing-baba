import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _popoverBorder = Color(0xFFE0E0E0);
const _clearButtonBg = Color(0xFFEEEEEE);
const _fieldHeight = 36.0;
const _popoverWidth = 260.0;

/// Column header numeric filter — Vyapar-style popover with operator dropdown,
/// value field, Clear/Apply.
class SaleColumnNumericFilterTrigger extends StatefulWidget {
  const SaleColumnNumericFilterTrigger({
    required this.label,
    required this.valueLabel,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.alignPopoverRight = false,
    super.key,
  });

  final String label;
  final String valueLabel;
  final PurchaseNumericFilter? initialFilter;
  final ValueChanged<PurchaseNumericFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final bool alignPopoverRight;

  @override
  State<SaleColumnNumericFilterTrigger> createState() =>
      _SaleColumnNumericFilterTriggerState();
}

class _SaleColumnNumericFilterTriggerState
    extends State<SaleColumnNumericFilterTrigger> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  static const _defaultHeaderStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _togglePopover() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showPopover();
  }

  void _showPopover() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

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
              targetAnchor: widget.alignPopoverRight
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              followerAnchor: widget.alignPopoverRight
                  ? Alignment.topRight
                  : Alignment.topLeft,
              offset: const Offset(0, 4),
              child: _SaleColumnNumericFilterPopover(
                valueLabel: widget.valueLabel,
                initialFilter: widget.initialFilter,
                onApply: (filter) {
                  _removeOverlay();
                  widget.onApply(filter);
                },
                onClose: _removeOverlay,
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
    final isActive = widget.initialFilter != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Align(
          alignment: widget.alignment,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: widget.headerStyle ?? _defaultHeaderStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 2),
              InkWell(
                key: _triggerKey,
                onTap: _togglePopover,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.filter_list,
                    size: 14,
                    color: isActive
                        ? AppColors.error
                        : AppColors.textSecondary,
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

class _SaleColumnNumericFilterPopover extends StatefulWidget {
  const _SaleColumnNumericFilterPopover({
    required this.valueLabel,
    required this.initialFilter,
    required this.onApply,
    required this.onClose,
  });

  final String valueLabel;
  final PurchaseNumericFilter? initialFilter;
  final ValueChanged<PurchaseNumericFilter?> onApply;
  final VoidCallback onClose;

  @override
  State<_SaleColumnNumericFilterPopover> createState() =>
      _SaleColumnNumericFilterPopoverState();
}

class _SaleColumnNumericFilterPopoverState
    extends State<_SaleColumnNumericFilterPopover> {
  late PurchaseNumericFilterOperator _operator;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _operator =
        widget.initialFilter?.operator ?? PurchaseNumericFilterOperator.equalTo;
    _valueController = TextEditingController(
      text: widget.initialFilter != null
          ? _formatAmount(widget.initialFilter!.value)
          : '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  double? _parseAmount(String raw) {
    final normalized = raw.trim().replaceAll(',', '');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  void _apply() {
    final value = _parseAmount(_valueController.text);
    if (value == null) {
      widget.onApply(null);
      return;
    }
    widget.onApply(PurchaseNumericFilter(operator: _operator, value: value));
  }

  void _clear() {
    widget.onApply(null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: SizedBox(
        width: _popoverWidth,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _NumericOperatorDropdownField(
                value: _operator,
                onChanged: (value) => setState(() => _operator = value),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: _fieldHeight,
                child: TextField(
                  controller: _valueController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  cursorColor: AppColors.primary,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: widget.valueLabel,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                    ),
                    floatingLabelStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smBorder,
                      borderSide: const BorderSide(color: _popoverBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smBorder,
                      borderSide: const BorderSide(color: _popoverBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smBorder,
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onSubmitted: (_) => _apply(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilterActionButton(
                      label: 'Clear',
                      backgroundColor: _clearButtonBg,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: _clear,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterActionButton(
                      label: 'Apply',
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      onPressed: _apply,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumericOperatorDropdownField extends StatefulWidget {
  const _NumericOperatorDropdownField({
    required this.value,
    required this.onChanged,
  });

  final PurchaseNumericFilterOperator value;
  final ValueChanged<PurchaseNumericFilterOperator> onChanged;

  @override
  State<_NumericOperatorDropdownField> createState() =>
      _NumericOperatorDropdownFieldState();
}

class _NumericOperatorDropdownFieldState
    extends State<_NumericOperatorDropdownField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() {});
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showOverlay();
  }

  void _selectItem(PurchaseNumericFilterOperator item) {
    _removeOverlay();
    widget.onChanged(item);
  }

  void _showOverlay() {
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
              offset: const Offset(0, 4),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.smBorder,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: _popoverWidth - (AppSpacing.md * 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in PurchaseNumericFilterOperator.values)
                        _CategoryDropdownItem(
                          label: item.label,
                          isSelected: item == widget.value,
                          onTap: () => _selectItem(item),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: AppRadius.smBorder,
        child: Container(
          height: _fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: _popoverBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.value.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _overlayEntry != null
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
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

class _CategoryDropdownItem extends StatelessWidget {
  const _CategoryDropdownItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _hoverColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: _hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _FilterActionButton extends StatelessWidget {
  const _FilterActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
