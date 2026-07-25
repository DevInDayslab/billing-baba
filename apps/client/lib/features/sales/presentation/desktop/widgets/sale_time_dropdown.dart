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
    super.key,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onSelected;
  final int intervalMinutes;
  final String placeholder;
  final double maxMenuHeight;
  final bool hasError;
  final bool compact;

  @override
  State<SaleTimeDropdown> createState() => SaleTimeDropdownState();
}

class SaleTimeDropdownState extends State<SaleTimeDropdown> {
  final MenuController _menuController = MenuController();
  final ScrollController _scrollController = ScrollController();
  late final List<TimeOfDay> _options = buildSaleTimeOptions(
    intervalMinutes: widget.intervalMinutes,
  );

  static const _itemHeight = 40.0;
  static const _defaultMinMenuWidth = 120.0;

  void closeMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    }
  }

  void _scrollToSelected() {
    if (widget.value == null || !_scrollController.hasClients) return;

    final index = saleTimeOptionIndex(
      widget.value!,
      intervalMinutes: widget.intervalMinutes,
    ).clamp(0, _options.length - 1);

    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset =
        (index * _itemHeight) - (widget.maxMenuHeight / 2) + (_itemHeight / 2);
    _scrollController.jumpTo(targetOffset.clamp(0.0, maxScroll));
  }

  void _toggleMenu(MenuController controller) {
    if (controller.isOpen) {
      controller.close();
      return;
    }

    controller.open();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
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
                  final selectedIndex = widget.value == null
                      ? -1
                      : saleTimeOptionIndex(
                          widget.value!,
                          intervalMinutes: widget.intervalMinutes,
                        );
                  final isSelected = index == selectedIndex;

                  return InkWell(
                    onTap: () {
                      widget.onSelected(option);
                      _menuController.close();
                    },
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
              onTap: () => _toggleMenu(controller),
              hasError: widget.hasError,
              compact: widget.compact,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
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
                  Icon(
                    Icons.access_time,
                    size: widget.compact ? 15 : 16,
                    color: AppColors.textSecondary,
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
