import 'package:flutter/material.dart';

/// Tappable label for desktop chrome (support strip, inline actions).
///
/// Uses explicit [TextDecoration.none] so parent [DefaultTextStyle] / link themes
/// do not paint yellow or default link underlines on primary-colored text.
class DesktopInlineActionText extends StatelessWidget {
  const DesktopInlineActionText({
    required this.label,
    required this.onTap,
    required this.style,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final resolved = style.copyWith(
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(4),
        splashColor: style.color?.withValues(alpha: 0.08),
        highlightColor: style.color?.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Text(label, style: resolved),
        ),
      ),
    );
  }
}
