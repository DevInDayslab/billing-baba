import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';

class InventoryHighlightedText extends StatelessWidget {
  const InventoryHighlightedText({
    required this.text,
    this.query = '',
    this.style,
    this.highlightStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    super.key,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    final baseStyle = style ?? InventoryStyles.listCellStyle;

    if (trimmedQuery.isEmpty) {
      return AppEllipsisTooltip(
        message: text,
        style: baseStyle,
        maxLines: maxLines,
        child: Text(
          text,
          style: baseStyle,
          maxLines: maxLines,
          overflow: overflow,
        ),
      );
    }

    final ranges = InventorySearchEngine.highlightRanges(
      text: text,
      query: trimmedQuery,
    );

    if (ranges.isEmpty) {
      return AppEllipsisTooltip(
        message: text,
        style: baseStyle,
        maxLines: maxLines,
        child: Text(
          text,
          style: baseStyle,
          maxLines: maxLines,
          overflow: overflow,
        ),
      );
    }

    final effectiveHighlightStyle =
        highlightStyle ??
        baseStyle.copyWith(
          fontWeight: FontWeight.w700,
          backgroundColor: const Color(0xFFFFF59D),
        );

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final range in ranges) {
      if (range.start > cursor) {
        spans.add(
          TextSpan(text: text.substring(cursor, range.start), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(range.start, range.end),
          style: effectiveHighlightStyle,
        ),
      );
      cursor = range.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }

    return AppEllipsisTooltip(
      message: text,
      style: baseStyle,
      maxLines: maxLines,
      child: Text.rich(
        TextSpan(children: spans),
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
