import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Circular photo picker / preview control for mobile Add Item header.
class MobileAddItemPhotoButton extends StatelessWidget {
  static const double defaultSize = 36;

  const MobileAddItemPhotoButton({
    required this.onTap,
    super.key,
    this.imageBytes,
    this.size = defaultSize,
    this.accentColor = const Color(0xFF5D5FEF),
  });

  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final double size;
  final Color accentColor;

  bool get _hasImage => imageBytes != null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _hasImage ? 'View item photo' : 'Add item photo',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hasImage ? AppColors.surface : accentColor,
                border: Border.all(
                  color: _hasImage
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : accentColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: _hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            imageBytes!,
                            fit: BoxFit.cover,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: size * 0.38,
                              height: size * 0.38,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: size * 0.22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: size * 0.5,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
