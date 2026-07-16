import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum BusinessCardAction { edit, delete }

class BusinessCard extends StatefulWidget {
  const BusinessCard({
    required this.business,
    required this.onOpen,
    this.onAction,
    super.key,
  });

  final BusinessModel business;
  final VoidCallback onOpen;
  final ValueChanged<BusinessCardAction>? onAction;

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  var _isHovered = false;

  static const _currentBadgeColor = Color(0xFFFF9800);
  static const _syncOnColor = Color(0xFF2E7D32);
  static const _borderColor = Color(0xFFE8EAED);

  @override
  Widget build(BuildContext context) {
    final business = widget.business;
    final dateFormat = DateFormat("dd/MM/yyyy 'at' hh:mm a");
    final syncOn = business.syncStatus == SyncStatus.on;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: _isHovered
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
              name: business.name,
              seed: business.id,
              diameter: 44,
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
                          business.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (business.isCurrent) ...[
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
                  if (business.lastSaleAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last sale: ${dateFormat.format(business.lastSaleAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Container(
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
                          syncOn
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                          size: 14,
                          color: syncOn
                              ? _syncOnColor
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          syncOn ? 'Sync On' : 'Sync Off',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: syncOn
                                ? _syncOnColor
                                : AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _OpenButton(onPressed: widget.onOpen, isHovered: _isHovered),
            const SizedBox(width: AppSpacing.xs),
            _BusinessCardMenu(
              business: business,
              onAction: widget.onAction,
            ),
          ],
        ),
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

class _BusinessCardMenu extends StatelessWidget {
  const _BusinessCardMenu({
    required this.business,
    required this.onAction,
  });

  final BusinessModel business;
  final ValueChanged<BusinessCardAction>? onAction;

  @override
  Widget build(BuildContext context) {
    final canManage = !business.isShared && business.isOwner;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          textStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
      child: PopupMenuButton<BusinessCardAction>(
        tooltip: 'More options',
        icon: Icon(
          Icons.more_vert,
          color: AppColors.textSecondary.withValues(alpha: 0.85),
          size: 22,
        ),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        offset: const Offset(0, 8),
        onSelected: onAction,
        itemBuilder: (context) => [
          if (canManage) ...[
            const PopupMenuItem(
              value: BusinessCardAction.edit,
              child: _MenuRow(
                icon: Icons.edit_outlined,
                label: 'Edit Company',
              ),
            ),
            const PopupMenuItem(
              value: BusinessCardAction.delete,
              child: _MenuRow(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Company',
                destructive: true,
              ),
            ),
          ] else
            const PopupMenuItem(
              enabled: false,
              child: _MenuRow(
                icon: Icons.info_outline,
                label: 'No actions available',
                muted: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.destructive = false,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? AppColors.error
        : muted
        ? AppColors.textSecondary.withValues(alpha: 0.6)
        : AppColors.textPrimary;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
