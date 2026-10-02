import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/form_control_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const _selectedDayFill = Color(0xFF212121);
const _monthCalendarWidth = 252.0;
const _navButtonSize = 32.0;
const _dayCellHeight = 32.0;
const _calendarRowCount = 6;
const double _panelHorizontalPadding = AppSpacing.md;
const double _panelWidth =
    _navButtonSize * 2 + _monthCalendarWidth + _panelHorizontalPadding * 2;
const _overlayVerticalOffset = 40.0;
const _screenEdgePadding = 8.0;

/// Single-date picker overlay — separate from the range picker in sale_date_range_picker.dart.
class SaleSingleDatePickerAnchor extends StatefulWidget {
  const SaleSingleDatePickerAnchor({
    required this.child,
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  final Widget child;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<SaleSingleDatePickerAnchor> createState() =>
      SaleSingleDatePickerAnchorState();
}

class SaleSingleDatePickerAnchorState
    extends State<SaleSingleDatePickerAnchor> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void showPicker() {
    if (_overlayEntry == null) _showOverlay();
  }

  void closePicker() => _removeOverlay();

  void toggle() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final followerOffset = _followerOffset(context);

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
              offset: followerOffset,
              child: _SaleSingleDatePickerPanel(
                selectedDate: widget.selectedDate,
                onDateSelected: (date) {
                  widget.onDateSelected(date);
                  _removeOverlay();
                },
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  Offset _followerOffset(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return const Offset(0, _overlayVerticalOffset);
    }

    final targetOrigin = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.sizeOf(context).width;

    var dx = 0.0;
    final overflowRight =
        targetOrigin.dx + dx + _panelWidth - (screenWidth - _screenEdgePadding);
    if (overflowRight > 0) dx -= overflowRight;

    final leftEdge = targetOrigin.dx + dx;
    if (leftEdge < _screenEdgePadding) {
      dx += _screenEdgePadding - leftEdge;
    }

    return Offset(dx, _overlayVerticalOffset);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }
}

final _saleSingleDateDisplayFormat = DateFormat('dd/MM/yyyy');

String formatSaleSingleDate(DateTime? date) {
  if (date == null) return 'Select date';
  return _saleSingleDateDisplayFormat.format(date);
}

/// Formats typed digits into `dd/MM/yyyy` (max 8 digits).
class SaleSingleDateMaskFormatter extends TextInputFormatter {
  const SaleSingleDateMaskFormatter();

  static const _maxDigits = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > _maxDigits) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();

    var offset = newValue.selection.end;
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '').length;
    final newDigits = digits.length;
    if (newDigits > oldDigits) {
      offset = text.length;
    } else {
      offset = offset.clamp(0, text.length);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

const saleSingleDateMaskFormatter = SaleSingleDateMaskFormatter();

DateTime? parseSaleSingleDateInput(String value) {
  final trimmed = value.trim();
  if (trimmed.length != 10) return null;
  try {
    final parsed = _saleSingleDateDisplayFormat.parseStrict(trimmed);
    if (parsed.year < 1900 || parsed.year > 2100) return null;
    return parsed;
  } on FormatException {
    return null;
  }
}

/// Single date field: type `dd/MM/yyyy` or open the calendar overlay.
class SaleEditableSingleDateField extends StatefulWidget {
  const SaleEditableSingleDateField({
    required this.selectedDate,
    required this.onDateSelected,
    this.datePickerKey,
    this.decoration,
    this.hintText = 'DD/MM/YYYY',
    super.key,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final GlobalKey<SaleSingleDatePickerAnchorState>? datePickerKey;
  final InputDecoration? decoration;
  final String hintText;

  @override
  State<SaleEditableSingleDateField> createState() =>
      _SaleEditableSingleDateFieldState();
}

class _SaleEditableSingleDateFieldState extends State<SaleEditableSingleDateField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  DateTime? _lastCommittedDate;

  @override
  void initState() {
    super.initState();
    _lastCommittedDate = widget.selectedDate;
    _controller = TextEditingController(text: _textForDate(widget.selectedDate));
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(SaleEditableSingleDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate && !_focusNode.hasFocus) {
      _lastCommittedDate = widget.selectedDate;
      final nextText = _textForDate(widget.selectedDate);
      if (_controller.text != nextText) {
        _controller.text = nextText;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _textForDate(DateTime? date) {
    if (date == null) return '';
    return _saleSingleDateDisplayFormat.format(date);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitTypedDateOrRevert();
    }
  }

  void _commitTypedDateOrRevert() {
    final parsed = parseSaleSingleDateInput(_controller.text);
    if (parsed != null) {
      final normalized = DateTime(parsed.year, parsed.month, parsed.day);
      _lastCommittedDate = normalized;
      _controller.text = _textForDate(normalized);
      widget.onDateSelected(normalized);
      return;
    }

    final fallback = _lastCommittedDate ?? widget.selectedDate;
    _controller.text = _textForDate(fallback);
  }

  void _openPicker() {
    widget.datePickerKey?.currentState?.toggle();
  }

  void _onTextChanged(String value) {
    final parsed = parseSaleSingleDateInput(value);
    if (parsed == null) return;
    final normalized = DateTime(parsed.year, parsed.month, parsed.day);
    _lastCommittedDate = normalized;
    widget.onDateSelected(normalized);
  }

  void _onPickerDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    _lastCommittedDate = normalized;
    widget.onDateSelected(normalized);
    _controller.text = _textForDate(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final calendarSuffix = IconButton(
      onPressed: _openPicker,
      icon: Icon(
        Icons.calendar_today_outlined,
        size: 16,
        color: Colors.grey.shade600,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      tooltip: 'Pick date',
    );

    final baseDecoration =
        widget.decoration ??
        buildFormControlDecoration(hint: widget.hintText);
    final decoration = baseDecoration.copyWith(
      suffixIcon: calendarSuffix,
      hintText: baseDecoration.hintText ?? widget.hintText,
    );

    return SaleSingleDatePickerAnchor(
      key: widget.datePickerKey,
      selectedDate: widget.selectedDate,
      onDateSelected: _onPickerDate,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: saleFieldTextStyle,
        decoration: decoration,
        keyboardType: TextInputType.number,
        inputFormatters: [saleSingleDateMaskFormatter],
        onChanged: _onTextChanged,
        onEditingComplete: _commitTypedDateOrRevert,
        onTapOutside: (_) => _commitTypedDateOrRevert(),
      ),
    );
  }
}

class _SaleSingleDatePickerPanel extends StatefulWidget {
  const _SaleSingleDatePickerPanel({
    required this.onDateSelected,
    this.selectedDate,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<_SaleSingleDatePickerPanel> createState() =>
      _SaleSingleDatePickerPanelState();
}

class _SaleSingleDatePickerPanelState
    extends State<_SaleSingleDatePickerPanel> {
  static final _monthFormat = DateFormat('MMMM yyyy');
  static const _weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  late DateTime _displayMonth;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.selectedDate ?? DateTime.now();
    _displayMonth = DateTime(initial.year, initial.month);
    _selected = _dateOnly(initial);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _shiftMonth(int delta) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + delta);
    });
  }

  void _onDayTap(DateTime day) {
    final tapped = _dateOnly(day);
    setState(() => _selected = tapped);
    widget.onDateSelected(tapped);
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      elevation: 4,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(_panelHorizontalPadding),
        child: SizedBox(
          width: _monthCalendarWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    onTap: () => _shiftMonth(-1),
                  ),
                  Expanded(
                    child: Text(
                      _monthFormat.format(_displayMonth),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.chevron_right,
                    onTap: () => _shiftMonth(1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  for (final label in _weekdayLabels)
                    Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: _dayCellHeight * _calendarRowCount,
                child: _MonthGrid(
                  month: _displayMonth,
                  selected: _selected,
                  onDayTap: _onDayTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _navButtonSize,
      height: _navButtonSize,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onDayTap,
  });

  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;

    return Column(
      children: [
        for (var row = 0; row < _calendarRowCount; row++)
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      dayIndex: row * 7 + col - startOffset + 1,
                      daysInMonth: daysInMonth,
                      month: month,
                      selected: selected,
                      onDayTap: onDayTap,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayIndex,
    required this.daysInMonth,
    required this.month,
    required this.selected,
    required this.onDayTap,
  });

  final int dayIndex;
  final int daysInMonth;
  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    if (dayIndex < 1 || dayIndex > daysInMonth) {
      return const SizedBox.shrink();
    }

    final day = DateTime(month.year, month.month, dayIndex);
    final isSelected =
        selected != null &&
        selected!.year == day.year &&
        selected!.month == day.month &&
        selected!.day == day.day;

    return GestureDetector(
      onTap: () => onDayTap(day),
      child: Container(
        height: _dayCellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _selectedDayFill : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$dayIndex',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
