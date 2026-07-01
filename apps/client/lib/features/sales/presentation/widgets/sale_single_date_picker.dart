import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _selectedDayFill = Color(0xFF212121);
const _monthCalendarWidth = 252.0;
const _navButtonSize = 32.0;
const _dayCellHeight = 32.0;
const _calendarRowCount = 6;
const _panelHorizontalPadding = AppSpacing.md;
const _panelWidth =
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
              followerAnchor: Alignment.topLeft,
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

String formatSaleSingleDate(DateTime? date) {
  if (date == null) return 'Select date';
  return DateFormat('dd/MM/yyyy').format(date);
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
    final firstDay = DateTime(month.year, month.month, 1);
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
