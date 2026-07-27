import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_photo_button.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';

/// Mobile Add Item dialog header with balanced photo, title, and actions.
class MobileAddItemHeader extends StatelessWidget {
  const MobileAddItemHeader({
    required this.title,
    required this.photoButton,
    required this.actions,
    required this.bottom,
    super.key,
    this.height = 84,
  });

  final String title;
  final MobileAddItemPhotoButton photoButton;
  final Widget actions;
  final Widget bottom;
  final double height;

  static const double _titleSideInset = 76;

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MobileAddItemPhotoButton.defaultSize,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: photoButton,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: actions,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _titleSideInset,
                    ),
                    child: Text(
                      title,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            bottom,
          ],
        ),
      ),
    );
  }
}

/// Compact icon actions for [MobileAddItemHeader] (settings + close).
class MobileAddItemHeaderActions extends StatelessWidget {
  const MobileAddItemHeaderActions({
    required this.onSettingsTap,
    required this.onCloseTap,
    super.key,
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onCloseTap;

  static const double _buttonSize = 32;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactHeaderIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onTap: onSettingsTap,
        ),
        _CompactHeaderIconButton(
          icon: Icons.close_rounded,
          tooltip: 'Close',
          onTap: onCloseTap,
        ),
      ],
    );
  }
}

class _CompactHeaderIconButton extends StatelessWidget {
  const _CompactHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smBorder,
          child: SizedBox(
            width: MobileAddItemHeaderActions._buttonSize,
            height: MobileAddItemHeaderActions._buttonSize,
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
