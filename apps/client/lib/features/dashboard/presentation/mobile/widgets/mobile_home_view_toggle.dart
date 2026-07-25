import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

/// Transaction Details / Party Details segmented toggle.
class MobileHomeViewToggle extends StatelessWidget {
  const MobileHomeViewToggle({
    required this.activeView,
    required this.onChanged,
    super.key,
  });

  final MobileHomeView activeView;
  final ValueChanged<MobileHomeView> onChanged;

  static const accentPurple = Color(0xFF5D5FEF);
  static const trackColor = Color(0xFFE8ECF1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Expanded(
              child: _Segment(
                label: 'Transaction Details',
                isActive: activeView == MobileHomeView.transactionDetails,
                onTap: () => onChanged(MobileHomeView.transactionDetails),
              ),
            ),
            Expanded(
              child: _Segment(
                label: 'Party Details',
                isActive: activeView == MobileHomeView.partyDetails,
                onTap: () => onChanged(MobileHomeView.partyDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isActive
                  ? MobileHomeViewToggle.accentPurple
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
