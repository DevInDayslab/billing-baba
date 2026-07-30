import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:flutter/material.dart';

/// Plain-text godown label — no bordered box, per Vyapar reference.
class GodownLabelSelector extends StatefulWidget {
  const GodownLabelSelector({
    required this.value,
    required this.onSelected,
    this.options = SaleDropdownOptions.godowns,
    super.key,
  });

  final String value;
  final ValueChanged<String> onSelected;
  final List<String> options;

  @override
  State<GodownLabelSelector> createState() => GodownLabelSelectorState();
}

class GodownLabelSelectorState extends State<GodownLabelSelector> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        elevation: const WidgetStatePropertyAll(4),
        shadowColor: const WidgetStatePropertyAll(Colors.black26),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size(160, 0)),
      ),
      menuChildren: [
        for (final option in widget.options)
          MenuItemButton(
            onPressed: () => widget.onSelected(option),
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(40)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFF5F5F5);
                }
                return null;
              }),
              backgroundColor: WidgetStatePropertyAll(
                option == widget.value
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : null,
              ),
              splashFactory: NoSplash.splashFactory,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: option == widget.value
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: option == widget.value
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Godown: ',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }
}
