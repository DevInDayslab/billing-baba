import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

/// Formats [time] as `h:MM AM/PM` (Vyapar-style, no leading zero on hour).
String formatSaleTime(TimeOfDay? time, {String placeholder = 'Select time'}) {
  if (time == null) return placeholder;

  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

/// Parses typed times such as `7:30 PM`, `7pm`, `19:30`, and `7.30 pm`.
TimeOfDay? parseSaleTime(String input) {
  var s = input.trim().toUpperCase();
  if (s.isEmpty) return null;

  s = s.replaceAll('.', ':').replaceAll(RegExp(r'\s+'), '');

  final period = _saleTimePeriodSuffix(s);
  if (period != null) {
    s = s.replaceFirst(RegExp(r'[AP]M?$'), '');
  }

  final match = RegExp(r'^(\d{1,2})(?::(\d{2}))?$').firstMatch(s);
  if (match == null) return null;

  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2) ?? '0');
  if (minute > 59) return null;

  if (period != null) {
    if (hour < 1 || hour > 12) return null;
    if (period == DayPeriod.am) {
      if (hour == 12) hour = 0;
    } else if (hour != 12) {
      hour += 12;
    }
  } else if (hour > 23) {
    return null;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

DayPeriod? _saleTimePeriodSuffix(String compactUpper) {
  if (compactUpper.endsWith('AM') || compactUpper.endsWith('A')) {
    return DayPeriod.am;
  }
  if (compactUpper.endsWith('PM') || compactUpper.endsWith('P')) {
    return DayPeriod.pm;
  }
  return null;
}

List<TimeOfDay> buildSaleTimeOptions({int intervalMinutes = 1}) {
  assert(intervalMinutes > 0 && 60 % intervalMinutes == 0);

  final options = <TimeOfDay>[];
  for (var hour = 0; hour < 24; hour++) {
    for (var minute = 0; minute < 60; minute += intervalMinutes) {
      options.add(TimeOfDay(hour: hour, minute: minute));
    }
  }
  return options;
}

int saleTimeOptionIndex(TimeOfDay time, {int intervalMinutes = 1}) {
  final snappedMinute = (time.minute ~/ intervalMinutes) * intervalMinutes;
  return time.hour * (60 ~/ intervalMinutes) + snappedMinute ~/ intervalMinutes;
}

/// Scrollable time dropdown with a clock icon, matching Vyapar-style invoice forms.
class SaleTimeDropdown extends StatefulWidget {
  const SaleTimeDropdown({
    required this.value,
    required this.onSelected,
    this.intervalMinutes = 60,
    this.placeholder = 'Select time',
    this.maxMenuHeight = 250,
    this.hasError = false,
    this.compact = false,
    this.allowTyping = false,
    super.key,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onSelected;
  final int intervalMinutes;
  final String placeholder;
  final double maxMenuHeight;
  final bool hasError;
  final bool compact;
  final bool allowTyping;

  @override
  State<SaleTimeDropdown> createState() => SaleTimeDropdownState();
}

class SaleTimeDropdownState extends State<SaleTimeDropdown> {
  final MenuController _menuController = MenuController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final List<TimeOfDay> _options = buildSaleTimeOptions(
    intervalMinutes: widget.intervalMinutes,
  );

  static const _itemHeight = 40.0;
  static const _defaultMinMenuWidth = 120.0;

  @override
  void initState() {
    super.initState();
    _syncTextFromValue();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant SaleTimeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _syncTextFromValue();
    }
  }

  void _syncTextFromValue() {
    _textController.text = widget.value == null
        ? ''
        : formatSaleTime(widget.value);
  }

  void closeMenu() => _closeMenu();

  void _closeMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    }
  }

  TimeOfDay get _referenceTime {
    final typed = widget.allowTyping
        ? parseSaleTime(_textController.text)
        : null;
    return typed ?? widget.value ?? TimeOfDay.now();
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;

    final index = saleTimeOptionIndex(
      _referenceTime,
      intervalMinutes: widget.intervalMinutes,
    ).clamp(0, _options.length - 1);

    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset =
        (index * _itemHeight) - (widget.maxMenuHeight / 2) + (_itemHeight / 2);
    _scrollController.jumpTo(targetOffset.clamp(0.0, maxScroll));
  }

  void _openMenu() {
    if (_menuController.isOpen) return;
    _menuController.open();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToSelected();
    });
  }

  void _toggleMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
      return;
    }
    _openMenu();
  }

  void _prefillCurrentTimeIfEmpty() {
    if (!widget.allowTyping || _textController.text.trim().isNotEmpty) {
      return;
    }
    final nowText = formatSaleTime(TimeOfDay.now());
    _textController.value = TextEditingValue(
      text: nowText,
      selection: TextSelection(baseOffset: 0, extentOffset: nowText.length),
    );
  }

  void _onFocusChange() {
    if (!mounted || !widget.allowTyping) return;

    if (_focusNode.hasFocus) {
      _prefillCurrentTimeIfEmpty();
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
      _openMenu();
      setState(() {});
      return;
    }

    _commitTypedTime();
  }

  void _commitTypedTime({bool closeMenu = true}) {
    final parsed = parseSaleTime(_textController.text);
    if (parsed != null) {
      widget.onSelected(parsed);
      _textController.text = formatSaleTime(parsed);
    } else {
      _syncTextFromValue();
    }
    if (closeMenu) _closeMenu();
  }

  void _onOptionSelected(TimeOfDay option) {
    _textController.text = formatSaleTime(option);
    widget.onSelected(option);
    _closeMenu();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = formatSaleTime(
      widget.value,
      placeholder: widget.placeholder,
    );
    final isPlaceholder = widget.value == null;
    final highlightIndex = saleTimeOptionIndex(
      _referenceTime,
      intervalMinutes: widget.intervalMinutes,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final triggerWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : _defaultMinMenuWidth;
        final menuWidth = math.max(triggerWidth, _defaultMinMenuWidth);

        return MenuAnchor(
          controller: _menuController,
          useRootOverlay: true,
          consumeOutsideTap: true,
          alignmentOffset: Offset(0, widget.compact ? 2 : 4),
          style: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
            elevation: const WidgetStatePropertyAll(4),
            shadowColor: const WidgetStatePropertyAll(Colors.black26),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
            ),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            minimumSize: WidgetStatePropertyAll(Size(menuWidth, 0)),
            maximumSize: WidgetStatePropertyAll(
              Size(menuWidth, widget.maxMenuHeight),
            ),
          ),
          menuChildren: [
            SizedBox(
              width: menuWidth,
              height: widget.maxMenuHeight,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemExtent: _itemHeight,
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final isSelected = index == highlightIndex;

                  return InkWell(
                    onTap: () => _onOptionSelected(option),
                    child: ColoredBox(
                      color: isSelected
                          ? const Color(0xFFF5F5F5)
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatSaleTime(option),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          builder: (context, controller, child) {
            return SaleFieldTrigger(
              onTap: () {
                if (widget.allowTyping) {
                  _focusNode.requestFocus();
                  _openMenu();
                  return;
                }
                _toggleMenu();
              },
              hasError: widget.hasError,
              compact: widget.compact,
              child: Row(
                children: [
                  Expanded(
                    child: widget.allowTyping
                        ? SizedBox(
                            height: (widget.compact ? 13.0 : 14.0) + 4,
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              style: TextStyle(
                                fontSize: widget.compact ? 13 : 14,
                                height: 1,
                                color: AppColors.textPrimary,
                              ),
                              strutStyle: StrutStyle(
                                fontSize: widget.compact ? 13 : 14,
                                height: 1,
                                forceStrutHeight: true,
                                leading: 0,
                              ),
                              cursorHeight: widget.compact ? 13 : 14,
                              cursorColor: AppColors.primary,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _commitTypedTime(),
                              decoration: InputDecoration(
                                isDense: true,
                                isCollapsed: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: widget.placeholder,
                                hintStyle: TextStyle(
                                  fontSize: widget.compact ? 13 : 14,
                                  height: 1,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            displayText,
                            style: TextStyle(
                              fontSize: widget.compact ? 13 : 14,
                              color: isPlaceholder
                                  ? Colors.grey.shade400
                                  : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  GestureDetector(
                    onTap: _toggleMenu,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.access_time,
                      size: widget.compact ? 15 : 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
