import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  static const _titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        if (isCompact) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PartiesTitle(),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _AddPartyButton(onPressed: onAddParty),
                    ),
                    IconButton(
                      onPressed: onSettingsTap,
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      color: AppColors.textSecondary,
                      tooltip: 'Settings',
                    ),
                    _buildMoreMenu(context),
                  ],
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              const _PartiesTitle(),
              const Spacer(),
              _AddPartyButton(onPressed: onAddParty),
              IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(Icons.settings_outlined, size: 20),
                color: AppColors.textSecondary,
                tooltip: 'Settings',
              ),
              _buildMoreMenu(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    if (onMoreSelected != null) {
      return SalesActionMenuButton(
        items: [
          for (final label in _moreMenuLabels)
            SalesActionMenuItem(
              label: label,
              onSelected: () async => onMoreSelected!(label),
            ),
        ],
      );
    }

    return SalesActionMenuButton(
      items: [
        SalesActionMenuItem(
          label: 'Import from Excel',
          onSelected: () async => _showComingSoon(context, 'Import from Excel'),
        ),
        SalesActionMenuItem(
          label: 'Import from Phone',
          onSelected: () async => _showComingSoon(context, 'Import from Phone'),
        ),
        SalesActionMenuItem(
          label: 'Import Via Google Contacts',
          onSelected: () async =>
              _showComingSoon(context, 'Import Via Google Contacts'),
        ),
        SalesActionMenuItem(
          label: 'Party Statement (Report)',
          onSelected: () async {
            if (!context.mounted) return;
            context.go(
              '${AppRoutes.reportsParty}?sub=partyStatement',
            );
          },
        ),
        SalesActionMenuItem(
          label: 'All Parties (Report)',
          onSelected: () async {
            if (!context.mounted) return;
            context.go('${AppRoutes.reportsParty}?sub=allParties');
          },
        ),
      ],
    );
  }

  static const _moreMenuLabels = [
    'Import from Excel',
    'Import from Phone',
    'Import Via Google Contacts',
    'Party Statement (Report)',
    'All Parties (Report)',
  ];

  void _showComingSoon(BuildContext context, String feature) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PartiesTitle extends StatelessWidget {
  const _PartiesTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Parties', style: PartyPageTitleBar._titleStyle),
        const SizedBox(width: 2),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Party views coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.keyboard_arrow_down, size: 22),
          color: AppColors.textPrimary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          tooltip: 'Party views',
        ),
      ],
    );
  }
}

class _AddPartyButton extends StatelessWidget {
  const _AddPartyButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minimumSize: const Size(0, 36),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Party'),
    );
  }
}
