import 'package:flutter/material.dart';

/// Returns whether [text] would be truncated at [maxWidth] with [maxLines].
bool isTextEllipsized({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required TextDirection textDirection,
  int maxLines = 1,
  TextAlign textAlign = TextAlign.start,
}) {
  if (text.isEmpty || !maxWidth.isFinite || maxWidth <= 0) {
    return false;
  }

  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: textDirection,
    textAlign: textAlign,
  )..layout(maxWidth: maxWidth);

  return painter.didExceedMaxLines;
}

/// Plain text that ellipsizes and shows a [Tooltip] on hover only when truncated.
class AppEllipsisText extends StatelessWidget {
  const AppEllipsisText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int maxLines;
  final TextOverflow overflow;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final effectiveTextAlign = textAlign ?? TextAlign.start;
    final textDirection = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textWidget = Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
        );

        final showTooltip = isTextEllipsized(
          text: text,
          style: effectiveStyle,
          maxWidth: constraints.maxWidth,
          maxLines: maxLines,
          textDirection: textDirection,
          textAlign: effectiveTextAlign,
        );

        if (showTooltip) {
          return Tooltip(message: text, child: textWidget);
        }

        return textWidget;
      },
    );
  }
}

/// Wraps [child] with a [Tooltip] for [message] only when [message] would truncate.
class AppEllipsisTooltip extends StatelessWidget {
  const AppEllipsisTooltip({
    required this.message,
    required this.child,
    super.key,
    this.style,
    this.textAlign,
    this.maxLines = 1,
  });

  final String message;
  final Widget child;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return child;

    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final effectiveTextAlign = textAlign ?? TextAlign.start;
    final textDirection = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showTooltip = isTextEllipsized(
          text: message,
          style: effectiveStyle,
          maxWidth: constraints.maxWidth,
          maxLines: maxLines,
          textDirection: textDirection,
          textAlign: effectiveTextAlign,
        );

        if (showTooltip) {
          return Tooltip(message: message, child: child);
        }

        return child;
      },
    );
  }
}

/// Converts a plain [Text] widget into [AppEllipsisText]; passes through other widgets.
Widget wrapEllipsisTooltipChild(Widget child) {
  if (child is Text && child.textSpan == null) {
    final data = child.data;
    if (data == null || data.isEmpty) return child;

    return AppEllipsisText(
      data,
      style: child.style,
      textAlign: child.textAlign,
      maxLines: child.maxLines ?? 1,
      overflow: child.overflow ?? TextOverflow.ellipsis,
      softWrap: child.softWrap ?? true,
    );
  }

  return child;
}

/// Truncates [text] to [maxLength] characters, appending "..." when longer.
String truncateTextByLength(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}

/// Single-line text truncated by character count. Shows a [Tooltip] with the
/// full [text] only when character-truncated; shorter values render as plain text.
class AppTruncatedText extends StatelessWidget {
  const AppTruncatedText(
    this.text, {
    super.key,
    this.maxLength = 20,
    this.style,
    this.textAlign,
  });

  final String text;
  final int maxLength;
  final TextStyle? style;
  final TextAlign? textAlign;

  bool get _isCharacterTruncated => text.length > maxLength;

  @override
  Widget build(BuildContext context) {
    final displayText = truncateTextByLength(text, maxLength);
    final textWidget = Text(
      displayText,
      style: style,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (!_isCharacterTruncated) {
      return textWidget;
    }

    return Tooltip(message: text, child: textWidget);
  }
}
