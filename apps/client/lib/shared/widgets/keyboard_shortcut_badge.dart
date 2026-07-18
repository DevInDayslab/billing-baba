import 'dart:io';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Platform-aware keyboard shortcut display chips.
class KeyboardShortcutBadge extends StatelessWidget {
  const KeyboardShortcutBadge({
    required this.keys,
    super.key,
  });

  /// Builds badges from a [SingleActivator] (Alt+key rows).
  factory KeyboardShortcutBadge.forActivator(SingleActivator activator) {
    final labels = <String>[];
    if (activator.alt) {
      labels.add(_altLabel);
    }
    if (activator.control) {
      labels.add(_ctrlLabel);
    }
    if (activator.meta) {
      labels.add(_metaLabel);
    }
    if (activator.shift) {
      labels.add('Shift');
    }
    labels.add(_labelForKey(activator.trigger));
    return KeyboardShortcutBadge(keys: labels);
  }

  /// Footer shortcut for opening the quick-create menu.
  factory KeyboardShortcutBadge.platformOpenMenu() {
    if (Platform.isMacOS) {
      return const KeyboardShortcutBadge(keys: ['⌘', 'Enter']);
    }
    return const KeyboardShortcutBadge(keys: ['Ctrl', 'Enter']);
  }

  /// Footer shortcut for opening navigation search.
  factory KeyboardShortcutBadge.platformOpenSearch() {
    if (Platform.isMacOS) {
      return const KeyboardShortcutBadge(keys: ['⌘', 'F']);
    }
    return const KeyboardShortcutBadge(keys: ['Ctrl', 'F']);
  }

  final List<String> keys;

  static String get _altLabel => Platform.isMacOS ? '⌥' : 'Alt';
  static String get _ctrlLabel => Platform.isMacOS ? '⌃' : 'Ctrl';
  static String get _metaLabel => '⌘';

  static String _labelForKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    final label = key.keyLabel;
    if (label.length == 1) return label.toUpperCase();
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: AppTypography.captionSize,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          _KeyChip(label: keys[i]),
        ],
      ],
    );
  }
}

class _KeyChip extends StatelessWidget {
  const _KeyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: DashboardColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.2,
        ),
      ),
    );
  }
}
