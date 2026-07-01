import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _rangeHighlight = Color(0xFFE0E0E0);
const _selectedDayFill = Color(0xFF212121);
const _monthCalendarWidth = 252.0;
const _navButtonSize = 32.0;
const _dayCellHeight = 32.0;
const _calendarRowCount = 6;
const double _panelHorizontalPadding = AppSpacing.md;
const double _panelWidth =
    _navButtonSize * 2 +
    _monthCalendarWidth * 2 +
    AppSpacing.lg +
    _panelHorizontalPadding * 2;
const _overlayVerticalOffset = 48.0;
const _overlayLeftOffset = -16.0;
const _screenEdgePadding = 8.0;

/// Dual-month date range picker overlay with click-click range selection.
class SaleDateRangePickerAnchor extends StatefulWidget {
  const SaleDateRangePickerAnchor({
    required this.child,
    required this.onRangeSelected,
    this.initialRange,
    super.key,
  });

  final Widget child;
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange> onRangeSelected;

  @override
  State<SaleDateRangePickerAnchor> createState() =>
      SaleDateRangePickerAnchorState();
}

class SaleDateRangePickerAnchorState extends State<SaleDateRangePickerAnchor> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void showPicker() {
    if (_overlayEntry == null) {
      _showOverlay();
    }
  }

  void closePicker() {
    _removeOverlay();
  }

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

  void _onRangeComplete(DateTimeRange range) {
    widget.onRangeSelected(range);
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
              child: _SaleDateRangePickerPanel(
                initialRange: widget.initialRange,
                onRangeSelected: _onRangeComplete,
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
      return const Offset(_overlayLeftOffset, _overlayVerticalOffset);
    }

    final targetOrigin = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.sizeOf(context).width;

    var dx = _overlayLeftOffset;
    final overflowRight =
        targetOrigin.dx + dx + _panelWidth - (screenWidth - _screenEdgePadding);
    if (overflowRight > 0) {
      dx -= overflowRight;
    }

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

class _SaleDateRangePickerPanel extends StatefulWidget {
  const _SaleDateRangePickerPanel({
    required this.onRangeSelected,
    this.initialRange,
  });

  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange> onRangeSelected;

  @override
  State<_SaleDateRangePickerPanel> createState() =>
      _SaleDateRangePickerPanelState();
}

class _SaleDateRangePickerPanelState extends State<_SaleDateRangePickerPanel> {
  static final _monthFormat = DateFormat('MMMM yyyy');
  static const _weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  late DateTime _leftMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRange;
    if (initial != null) {
      _leftMonth = DateTime(initial.start.year, initial.start.month);
      _rangeStart = _dateOnly(initial.start);
      _rangeEnd = _dateOnly(initial.end);
    } else {
      final now = DateTime.now();
      _leftMonth = DateTime(now.year, now.month);
    }
  }

  DateTime get _rightMonth => DateTime(_leftMonth.year, _leftMonth.month + 1);

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _shiftMonths(int delta) {
    setState(() {
      _leftMonth = DateTime(_leftMonth.year, _leftMonth.month + delta);
    });
  }

  void _onDayTap(DateTime day) {
    final tapped = _dateOnly(day);
    setState(() {
      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
        _rangeStart = tapped;
        _rangeEnd = null;
        return;
      }

      if (tapped.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = tapped;
      } else {
        _rangeEnd = tapped;
      }

      widget.onRangeSelected(
        DateTimeRange(start: _rangeStart!, end: _rangeEnd!),
      );
    });
  }

  bool _isRangeStart(DateTime day) =>
      _rangeStart != null && _isSameDay(day, _rangeStart!);

  bool _isRangeEnd(DateTime day) =>
      _rangeEnd != null && _isSameDay(day, _rangeEnd!);

  bool _isInRange(DateTime day) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    final normalized = _dateOnly(day);
    return !normalized.isBefore(_rangeStart!) &&
        !normalized.isAfter(_rangeEnd!);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _daysInMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;

  int _firstWeekdayOffset(DateTime month) =>
      DateTime(month.year, month.month).weekday % 7;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      elevation: 4,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: _panelWidth,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _MonthNavButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _shiftMonths(-1),
                  ),
                  SizedBox(
                    width: _monthCalendarWidth,
                    child: Text(
                      _monthFormat.format(_leftMonth),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  SizedBox(
                    width: _monthCalendarWidth,
                    child: Text(
                      _monthFormat.format(_rightMonth),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _MonthNavButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _shiftMonths(1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: _navButtonSize),
                  _MonthCalendar(
                    month: _leftMonth,
                    weekdayLabels: _weekdayLabels,
                    daysInMonth: _daysInMonth(_leftMonth),
                    firstWeekdayOffset: _firstWeekdayOffset(_leftMonth),
                    isRangeStart: _isRangeStart,
                    isRangeEnd: _isRangeEnd,
                    isInRange: _isInRange,
                    onDayTap: _onDayTap,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _MonthCalendar(
                    month: _rightMonth,
                    weekdayLabels: _weekdayLabels,
                    daysInMonth: _daysInMonth(_rightMonth),
                    firstWeekdayOffset: _firstWeekdayOffset(_rightMonth),
                    isRangeStart: _isRangeStart,
                    isRangeEnd: _isRangeEnd,
                    isInRange: _isInRange,
                    onDayTap: _onDayTap,
                  ),
                  const SizedBox(width: _navButtonSize),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _navButtonSize,
      height: _navButtonSize,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_navButtonSize / 2),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.weekdayLabels,
    required this.daysInMonth,
    required this.firstWeekdayOffset,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isInRange,
    required this.onDayTap,
  });

  final DateTime month;
  final List<String> weekdayLabels;
  final int daysInMonth;
  final int firstWeekdayOffset;
  final bool Function(DateTime day) isRangeStart;
  final bool Function(DateTime day) isRangeEnd;
  final bool Function(DateTime day) isInRange;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _monthCalendarWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (final label in weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var row = 0; row < _calendarRowCount; row++)
            SizedBox(
              height: _dayCellHeight,
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(child: _buildDayCell(row, col)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int row, int col) {
    final cellIndex = row * 7 + col;
    final dayNumber = cellIndex - firstWeekdayOffset + 1;

    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox.shrink();
    }

    final day = DateTime(month.year, month.month, dayNumber);
    final isStart = isRangeStart(day);
    final isEnd = isRangeEnd(day);
    final inRange = isInRange(day);
    final isEndpoint = isStart || isEnd;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onDayTap(day),
        hoverColor: _rangeHighlight.withValues(alpha: 0.5),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: inRange && !isEndpoint ? _rangeHighlight : null,
            borderRadius: _endpointBorderRadius(isStart, isEnd, inRange),
          ),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isEndpoint ? _selectedDayFill : null,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isEndpoint ? FontWeight.w600 : FontWeight.w400,
                color: isEndpoint ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius? _endpointBorderRadius(
    bool isStart,
    bool isEnd,
    bool inRange,
  ) {
    if (isStart && isEnd) return BorderRadius.circular(16);
    if (isStart) {
      return const BorderRadius.horizontal(left: Radius.circular(16));
    }
    if (isEnd) {
      return const BorderRadius.horizontal(right: Radius.circular(16));
    }
    if (inRange) return BorderRadius.zero;
    return null;
  }
}

/// Formats a date range for display in the filter bar.
String formatSaleDateRangeLabel(DateTimeRange range) {
  final format = DateFormat('dd/MM/yyyy');
  return '${format.format(range.start)} To ${format.format(range.end)}';
}

/// Default display label when no custom range is selected.
String defaultSaleDateRangeLabel() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final end = DateTime(now.year, now.month + 1, 0);
  return formatSaleDateRangeLabel(DateTimeRange(start: start, end: end));
}
