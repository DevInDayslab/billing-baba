import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/presentation/widgets/manage_party_groups_dialog.dart';
import 'package:flutter/material.dart';

class PartyPageTitleBar extends StatelessWidget {
  const PartyPageTitleBar({
    this.onAddParty,
    this.onSettingsTap,
    this.onMoreSelected,
    super.key,
  });

  final VoidCallback? onAddParty;
  final VoidCallback? onSettingsTap;
  final ValueChanged<String>? onMoreSelected;

  static const _addPartyRed = Color(0xFFE53935);

  static const _titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Party Details', style: _titleStyle),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAddParty,
                      style: FilledButton.styleFrom(
                        backgroundColor: _addPartyRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        minimumSize: const Size(0, 42),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 22),
                      label: const Text('Add Party'),
                    ),
                  ),
                  IconButton(
                    onPressed: onSettingsTap,
                    icon: const Icon(Icons.settings_outlined),
                    color: AppColors.textSecondary,
                    tooltip: 'Settings',
                  ),
                  _buildMoreMenu(context),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            const Expanded(
              child: Text(
                'Party Details',
                style: _titleStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FilledButton.icon(
              onPressed: onAddParty,
              style: FilledButton.styleFrom(
                backgroundColor: _addPartyRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                minimumSize: const Size(0, 42),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.add, size: 22),
              label: const Text('Add Party'),
            ),
            IconButton(
              onPressed: onSettingsTap,
              icon: const Icon(Icons.settings_outlined),
              color: AppColors.textSecondary,
              tooltip: 'Settings',
            ),
            _buildMoreMenu(context),
          ],
        );
      },
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More options',
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
        size: 22,
      ),
      onSelected: onMoreSelected ??
          (value) {
            if (value == 'Manage Party Groups') {
              showManagePartyGroupsDialog(context);
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$value coming soon')),
            );
          },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'Manage Party Groups',
          child: Text('Manage Party Groups'),
        ),
        PopupMenuItem(
          value: 'Import Parties',
          child: Text('Import Parties'),
        ),
        PopupMenuItem(
          value: 'Export Parties',
          child: Text('Export Parties'),
        ),
      ],
    );
  }
}
