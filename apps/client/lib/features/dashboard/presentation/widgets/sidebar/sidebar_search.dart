import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_tokens.dart';
import 'package:flutter/material.dart';

/// Command palette placeholder — functionality TODO.
class SidebarSearch extends StatelessWidget {
  const SidebarSearch({
    required this.collapsed,
    required this.onToggleCollapse,
    super.key,
  });

  final bool collapsed;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: collapsed
          ? Center(
              child: IconButton(
                icon: const Icon(
                  Icons.last_page,
                  color: SidebarTokens.text,
                  size: 20,
                ),
                onPressed: onToggleCollapse,
                tooltip: 'Expand sidebar',
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      // TODO: Open command palette (Ctrl+F).
                    },
                    decoration: InputDecoration(
                      hintText: 'Open Anything (Ctrl+F)',
                      hintStyle: const TextStyle(
                        color: SidebarTokens.text,
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: SidebarTokens.text,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: SidebarTokens.searchBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(
                      color: SidebarTokens.textActive,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.first_page,
                    color: SidebarTokens.text,
                    size: 20,
                  ),
                  onPressed: onToggleCollapse,
                  tooltip: 'Collapse sidebar',
                ),
              ],
            ),
    );
  }
}
