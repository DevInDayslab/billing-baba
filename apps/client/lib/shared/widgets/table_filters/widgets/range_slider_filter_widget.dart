import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_inputs.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_layout.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup_widgets.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

typedef RangeSliderFilterApplyCallback =
    void Function(
      RangeSliderColumnFilter? filter,
    );

/// Continuous range slider — loyalty points, ratings, percentages, etc.
/// Not for currency amounts.
class RangeSliderFilterWidget extends StatefulWidget {
  const RangeSliderFilterWidget({
    required this.title,
    required this.initialFilter,
    required this.onApply,
    this.maxValue = RangeSliderColumnFilter.defaultCeiling,
    this.rangeLabel = 'Range',
    super.key,
  });

  final String title;
  final RangeSliderColumnFilter? initialFilter;
  final RangeSliderFilterApplyCallback onApply;
  final double maxValue;
  final String rangeLabel;

  @override
  State<RangeSliderFilterWidget> createState() =>
      _RangeSliderFilterWidgetState();
}

class _RangeSliderFilterWidgetState extends State<RangeSliderFilterWidget> {
  static final _inputFormatter = FilteringTextInputFormatter.allow(
    RegExp('[0-9.,]'),
  );

  late RangeValues _rangeValues;
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    final initialMin = widget.initialFilter?.min ?? 0;
    final initialMax = widget.initialFilter?.max ?? widget.maxValue;
    _rangeValues = RangeValues(
      initialMin.clamp(0, widget.maxValue),
      initialMax.clamp(0, widget.maxValue),
    );
    _minController = TextEditingController(text: _format(_rangeValues.start));
    _maxController = TextEditingController(
      text: _format(
        _rangeValues.end,
        showPlus: _rangeValues.end >= widget.maxValue,
      ),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String _format(double value, {bool showPlus = false}) {
    final formatted = NumberFormat('#,##0', 'en_IN').format(value.round());
    return showPlus ? '$formatted+' : formatted;
  }

  double _parse(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('+', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  void _syncFromSlider(RangeValues values) {
    setState(() {
      _rangeValues = values;
      _minController.text = _format(values.start);
      _maxController.text = _format(
        values.end,
        showPlus: values.end >= widget.maxValue,
      );
    });
  }

  void _apply() {
    final min = _parse(_minController.text).clamp(0, widget.maxValue);
    final max = _parse(_maxController.text).clamp(0, widget.maxValue);

    if (min == 0 && max >= widget.maxValue) {
      widget.onApply(null);
      return;
    }

    widget.onApply(
      RangeSliderColumnFilter(
        min: min.toDouble(),
        max: max.toDouble(),
        ceiling: widget.maxValue,
      ),
    );
  }

  void _clear() => widget.onApply(null);

  @override
  Widget build(BuildContext context) {
    return FilterPopoverLayout(
      title: widget.title,
      width: TableFilterTheme.amountPopoverWidth,
      operator: FilterSectionLabel(widget.rangeLabel),
      input: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
              rangeThumbShape: const _OutlinedRangeSliderThumbShape(),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: const Color(0xFFE0E0E0),
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: RangeSlider(
              values: _rangeValues,
              max: widget.maxValue,
              onChanged: _syncFromSlider,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FilterNumberInput(
                  controller: _minController,
                  inputFormatters: [_inputFormatter],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilterNumberInput(
                  controller: _maxController,
                  inputFormatters: [_inputFormatter],
                ),
              ),
            ],
          ),
        ],
      ),
      onClear: _clear,
      onApply: _apply,
    );
  }
}

class _OutlinedRangeSliderThumbShape extends RangeSliderThumbShape {
  const _OutlinedRangeSliderThumbShape();

  static const _thumbRadius = 8.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(_thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required SliderThemeData sliderTheme,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center,
      _thumbRadius,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      _thumbRadius,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
