import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_card_menu.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Fade + slight slide when a company is scheduled for deletion.
class BusinessListCardMotion extends StatefulWidget {
  const BusinessListCardMotion({
    required this.isPendingDeletion,
    required this.child,
    super.key,
  });

  final bool isPendingDeletion;
  final Widget child;

  @override
  State<BusinessListCardMotion> createState() => _BusinessListCardMotionState();
}

class _BusinessListCardMotionState extends State<BusinessListCardMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _slideY;

  static const _duration = Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideY = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.isPendingDeletion) {
      unawaited(_controller.forward());
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(BusinessListCardMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isPendingDeletion && widget.isPendingDeletion) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPendingDeletion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _fade.value;
        return Opacity(
          opacity: 0.5 + (0.42 * t),
          child: Transform.translate(
            offset: Offset(0, _slideY.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class BusinessCard extends StatefulWidget {
  const BusinessCard({
    required this.entry,
    required this.onOpen,
    this.onAccept,
    this.onReject,
    this.onMenuAction,
    super.key,
  });

  final CompanyListEntry entry;
  final VoidCallback onOpen;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final ValueChanged<CompanyCardMenuAction>? onMenuAction;

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  var _isHovered = false;

  static const _currentBadgeColor = Color(0xFFFF9800);
  static const _borderColor = Color(0xFFE8EAED);

  static String _deletionCountdownLabel(DateTime scheduledDeletionAt) {
    final days = scheduledDeletionAt.difference(DateTime.now()).inDays;
    if (days <= 0) return 'Deleting soon';
    if (days == 1) return 'Deletes in 1 day';
    return 'Deletes in $days days';
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final dateFormat = DateFormat("dd/MM/yyyy 'at' hh:mm a");
    final syncOn = entry.syncStatus == SyncStatus.on;
    final isSharedTab = entry.isSharedTab;
    final isInvitePending = entry.relationship.isPending;
    final isExpired = entry.relationship.isExpired;
    final isPendingDeletion = entry.isPendingDeletion;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isPendingDeletion
              ? AppColors.error.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: isPendingDeletion
                ? AppColors.error.withValues(alpha: 0.35)
                : _isHovered
                ? AppColors.primary.withValues(alpha: 0.35)
                : _borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isHovered ? 0.08 : 0.04,
              ),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        child: Row(
          children: [
            BusinessAvatar(
              name: entry.name,
              seed: entry.id,
              diameter: 44,
              logoUrl: entry.logoUrl,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPendingDeletion) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _MetaChip(
                          label: _deletionCountdownLabel(
                            entry.scheduledDeletionAt!,
                          ),
                          color: AppColors.error,
                          backgroundColor: AppColors.error.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ],
                      if (entry.isCurrent) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _currentBadgeColor.withValues(alpha: 0.12),
                            borderRadius: AppRadius.smBorder,
                            border: Border.all(
                              color: _currentBadgeColor.withValues(alpha: 0.6),
                            ),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(
                              color: _currentBadgeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isSharedTab) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Shared by ${entry.ownerName ?? 'Business owner'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (entry.role != null)
                          _MetaChip(
                            label: 'Role: ${entry.role!.displayLabel}',
                            color: AppColors.primary,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        if (isExpired)
                          _MetaChip(
                            label: 'Expired',
                            color: AppColors.error,
                            backgroundColor: AppColors.error.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        _SyncStatusChip(syncOn: syncOn),
                      ],
                    ),
                  ] else ...[
                    if (entry.lastSaleAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Last sale: ${dateFormat.format(entry.lastSaleAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    _SyncStatusChip(syncOn: syncOn),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (isInvitePending && !isExpired) ...[
              OutlinedButton(
                onPressed: widget.onReject,
                child: const Text('Reject'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: widget.onAccept,
                child: const Text('Accept'),
              ),
            ] else if (isExpired) ...[
              const FilledButton(
                onPressed: null,
                child: Text('Accept'),
              ),
            ] else if (!isExpired)
              _OpenButton(onPressed: widget.onOpen, isHovered: _isHovered),
            const SizedBox(width: AppSpacing.xs),
            BusinessCardMenu(
              entry: entry,
              onAction: widget.onMenuAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SyncStatusChip extends StatelessWidget {
  const _SyncStatusChip({required this.syncOn});

  final bool syncOn;

  static const _syncOnColor = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: syncOn
            ? _syncOnColor.withValues(alpha: 0.08)
            : Colors.grey.shade100,
        borderRadius: AppRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            syncOn ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            size: 14,
            color: syncOn ? _syncOnColor : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            syncOn ? 'Sync On' : 'Sync Off',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: syncOn ? _syncOnColor : AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenButton extends StatefulWidget {
  const _OpenButton({
    required this.onPressed,
    required this.isHovered,
  });

  final VoidCallback onPressed;
  final bool isHovered;

  @override
  State<_OpenButton> createState() => _OpenButtonState();
}

class _OpenButtonState extends State<_OpenButton> {
  var _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _isPressed
                  ? const Color(0xFF0D47A1)
                  : widget.isHovered
                  ? const Color(0xFF1976D2)
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: widget.isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(24),
                splashColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.1),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 10,
                  ),
                  child: Text(
                    'Open',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
