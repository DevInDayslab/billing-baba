import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

const _popoverBorder = Color(0xFFE0E0E0);
const _clearButtonBg = Color(0xFFEEEEEE);
const _fieldHeight = 36.0;
const _popoverWidth = 280.0;

class AmountColumnFilter {
  const AmountColumnFilter({
    required this.min,
    required this.max,
    this.ceiling = defaultCeiling,
  });

  static const defaultCeiling = 5000000.0;

  final double min;
  final double max;
  final double ceiling;

  bool get isActive => min > 0 || max < ceiling;

  bool matches(double amount) {
    if (amount < min) return false;
    if (max >= ceiling) return true;
    return amount <= max;
  }
}

/// Column header amount filter — popover with range slider, min/max inputs, Clear/Apply.
class SaleColumnAmountFilterTrigger extends StatefulWidget {
  const SaleColumnAmountFilterTrigger({
    required this.label,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.maxAmount = AmountColumnFilter.defaultCeiling,
    this.rangeLabel = 'Price range',
    super.key,
  });

  final String label;
  final AmountColumnFilter? initialFilter;
  final ValueChanged<AmountColumnFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final double maxAmount;
  final String rangeLabel;

  @override
  State<SaleColumnAmountFilterTrigger> createState() =>
      _SaleColumnAmountFilterTriggerState();
}

class _SaleColumnAmountFilterTriggerState
    extends State<SaleColumnAmountFilterTrigger> {
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
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 4),
              child: _SaleColumnAmountFilterPopover(
                initialFilter: widget.initialFilter,
                maxAmount: widget.maxAmount,
                rangeLabel: widget.rangeLabel,
                onApply: (filter) {
                  _removeOverlay();
                  widget.onApply(filter);
                },
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
    final isActive = widget.initialFilter?.isActive ?? false;

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
                  textAlign: widget.alignment == Alignment.centerRight
                      ? TextAlign.right
                      : TextAlign.left,
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

class _SaleColumnAmountFilterPopover extends StatefulWidget {
  const _SaleColumnAmountFilterPopover({
    required this.initialFilter,
    required this.maxAmount,
    required this.rangeLabel,
    required this.onApply,
  });

  final AmountColumnFilter? initialFilter;
  final double maxAmount;
  final String rangeLabel;
  final ValueChanged<AmountColumnFilter?> onApply;

  @override
  State<_SaleColumnAmountFilterPopover> createState() =>
      _SaleColumnAmountFilterPopoverState();
}

class _SaleColumnAmountFilterPopoverState
    extends State<_SaleColumnAmountFilterPopover> {
  static final _amountFormat = NumberFormat('#,##0', 'en_IN');
  static final _amountInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9,]'),
  );

  late RangeValues _rangeValues;
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    final initialMin = widget.initialFilter?.min ?? 0;
    final initialMax = widget.initialFilter?.max ?? widget.maxAmount;
    _rangeValues = RangeValues(
      initialMin.clamp(0, widget.maxAmount),
      initialMax.clamp(0, widget.maxAmount),
    );
    _minController = TextEditingController(text: _formatAmount(_rangeValues.start));
    _maxController = TextEditingController(
      text: _formatAmount(_rangeValues.end, showPlus: _rangeValues.end >= widget.maxAmount),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String _formatAmount(double value, {bool showPlus = false}) {
    final formatted = _amountFormat.format(value.round());
    return showPlus ? '$formatted+' : formatted;
  }

  double _parseAmount(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('+', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  void _syncFromSlider(RangeValues values) {
    setState(() {
      _rangeValues = values;
      _minController.text = _formatAmount(values.start);
      _maxController.text = _formatAmount(
        values.end,
        showPlus: values.end >= widget.maxAmount,
      );
    });
  }

  void _syncFromMinInput(String value) {
    final parsed = _parseAmount(value).clamp(0, widget.maxAmount).toDouble();
    final end = parsed > _rangeValues.end ? parsed : _rangeValues.end;
    _syncFromSlider(RangeValues(parsed, end));
  }

  void _syncFromMaxInput(String value) {
    final parsed = _parseAmount(value).clamp(0, widget.maxAmount).toDouble();
    final start = parsed < _rangeValues.start ? parsed : _rangeValues.start;
    _syncFromSlider(RangeValues(start, parsed));
  }

  void _apply() {
    final min = _parseAmount(_minController.text).clamp(0, widget.maxAmount);
    final max = _parseAmount(_maxController.text).clamp(0, widget.maxAmount);

    if (min == 0 && max >= widget.maxAmount) {
      widget.onApply(null);
      return;
    }

    widget.onApply(
      AmountColumnFilter(
        min: min.toDouble(),
        max: max.toDouble(),
        ceiling: widget.maxAmount,
      ),
    );
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
              Text(
                widget.rangeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                  rangeThumbShape: const _OutlinedRangeSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: const Color(0xFFE0E0E0),
                  overlayColor: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: RangeSlider(
                  values: _rangeValues,
                  min: 0,
                  max: widget.maxAmount,
                  onChanged: _syncFromSlider,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _AmountInputField(
                      label: 'Min.',
                      controller: _minController,
                      inputFormatters: [_amountInputFormatter],
                      onChanged: _syncFromMinInput,
                      onSubmitted: _syncFromMinInput,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _AmountInputField(
                      label: 'Max.',
                      controller: _maxController,
                      inputFormatters: [_amountInputFormatter],
                      onChanged: _syncFromMaxInput,
                      onSubmitted: _syncFromMaxInput,
                    ),
                  ),
                ],
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

class _AmountInputField extends StatelessWidget {
  const _AmountInputField({
    required this.label,
    required this.controller,
    required this.inputFormatters,
    required this.onChanged,
    required this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: _fieldHeight,
          child: TextField(
            controller: controller,
            cursorColor: AppColors.primary,
            keyboardType: TextInputType.number,
            inputFormatters: inputFormatters,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
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
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }
}

class _OutlinedRangeSliderThumbShape extends RangeSliderThumbShape {
  const _OutlinedRangeSliderThumbShape({this.enabledThumbRadius = 8});

  final double enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center,
      enabledThumbRadius,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      enabledThumbRadius,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
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
