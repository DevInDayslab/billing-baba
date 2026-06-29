import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/providers/business_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessSearchBar extends ConsumerStatefulWidget {
  const BusinessSearchBar({
    super.key,
    this.compact = false,
    this.dark = false,
  });

  final bool compact;
  final bool dark;

  @override
  ConsumerState<BusinessSearchBar> createState() => _BusinessSearchBarState();
}

class _BusinessSearchBarState extends ConsumerState<BusinessSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(businessSearchProvider, (previous, next) {
      if (next != _controller.text) {
        _controller.text = next;
      }
    });

    final query = ref.watch(businessSearchProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = widget.dark;

    final fieldColor = isDark
        ? colorScheme.onInverseSurface.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHighest;
    final iconColor = isDark
        ? colorScheme.onInverseSurface.withValues(alpha: 0.7)
        : colorScheme.onSurfaceVariant;
    final hintStyle = TextStyle(
      color: isDark
          ? colorScheme.onInverseSurface.withValues(alpha: 0.55)
          : colorScheme.onSurfaceVariant,
    );

    return SizedBox(
      width: widget.compact ? double.infinity : 280,
      child: SearchBar(
        controller: _controller,
        hintText: 'Search businesses...',
        hintStyle: WidgetStatePropertyAll(hintStyle),
        leading: Icon(Icons.search, color: iconColor),
        trailing: query.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: iconColor),
                  onPressed: () {
                    _controller.clear();
                    ref.read(businessSearchProvider.notifier).clearQuery();
                  },
                ),
              ]
            : null,
        onChanged: (value) =>
            ref.read(businessSearchProvider.notifier).updateQuery(value),
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(fieldColor),
        side: isDark ? WidgetStateProperty.all(BorderSide.none) : null,
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            color: isDark ? colorScheme.onInverseSurface : null,
          ),
        ),
      ),
    );
  }
}
