import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/application/deals_selection_providers.dart';
import 'package:billing_baba/features/crm/presentation/desktop/widgets/create_deal_task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _accountBlue = Color(0xFF1565C0);
const _quickActionBlue = Color(0xFF1A62D6);

class DealCard extends ConsumerStatefulWidget {
  const DealCard({
    required this.deal,
    this.onTap,
    super.key,
  });

  final Deal deal;
  final VoidCallback? onTap;

  @override
  ConsumerState<DealCard> createState() => _DealCardState();
}

class _DealCardState extends ConsumerState<DealCard> {
  bool _hovered = false;
  bool _showQuickActions = false;

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final selectedIds = ref.watch(selectedDealIdsProvider);
    final isSelected = selectedIds.contains(deal.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _showQuickActions = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(
                  color: isSelected ? AppColors.primary : _cardBorder,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deal.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: isSelected,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) => ref
                              .read(selectedDealIdsProvider.notifier)
                              .toggle(deal.id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deal.stage.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    deal.displayAccountName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _accountBlue,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deal.displayAssignedTo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    deal.displayAmount,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deal.displayCloseDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (_hovered)
              Positioned(
                right: -6,
                top: 0,
                bottom: AppSpacing.sm,
                child: Center(
                  child: _QuickActionButton(
                    showMenu: _showQuickActions,
                    onToggle: () =>
                        setState(() => _showQuickActions = !_showQuickActions),
                    onNewTask: () {
                      setState(() => _showQuickActions = false);
                      unawaited(
                        showCreateDealTaskDialog(
                          context,
                          dealName: deal.name,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.showMenu,
    required this.onToggle,
    required this.onNewTask,
  });

  final bool showMenu;
  final VoidCallback onToggle;
  final VoidCallback onNewTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMenu) ...[
          _QuickActionMenuItem(
            label: 'New Task',
            onTap: onNewTask,
          ),
          _QuickActionMenuItem(
            label: 'New Meeting',
            onTap: onToggle,
          ),
          _QuickActionMenuItem(
            label: 'New Call',
            onTap: onToggle,
          ),
          const SizedBox(height: 4),
        ],
        Material(
          color: _quickActionBlue,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onToggle,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionMenuItem extends StatelessWidget {
  const _QuickActionMenuItem({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        borderRadius: AppRadius.mdBorder,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          child: Text(
            '+ $label',
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
