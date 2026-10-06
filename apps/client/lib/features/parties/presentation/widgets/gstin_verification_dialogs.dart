import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/gstin_verification_response.dart';
import 'package:flutter/material.dart';

const _activeStatusColor = Color(0xFF2E7D32);

Future<void> showGstinVerificationErrorDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Unable to verify GSTIN'),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class GstinVerificationLoadingDialog extends StatelessWidget {
  const GstinVerificationLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Material(
          elevation: 8,
          borderRadius: AppRadius.lgBorder,
          color: AppColors.surface,
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Verifying GSTIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Fetching business details...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

NavigatorState? _loadingDialogNavigator;
bool _loadingDialogVisible = false;

void showGstinVerificationLoadingDialog(BuildContext context) {
  if (_loadingDialogVisible) return;

  final navigator = Navigator.of(context, rootNavigator: true);
  _loadingDialogNavigator = navigator;
  _loadingDialogVisible = true;

  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: const Color(0x99000000),
    builder: (dialogContext) => const GstinVerificationLoadingDialog(),
  ).whenComplete(() {
    _loadingDialogVisible = false;
    _loadingDialogNavigator = null;
  });
}

Future<void> hideGstinVerificationLoadingDialog() async {
  if (!_loadingDialogVisible) return;

  final navigator = _loadingDialogNavigator;
  try {
    if (navigator != null && navigator.mounted) {
      navigator.pop();
    }
  } finally {
    _loadingDialogVisible = false;
    _loadingDialogNavigator = null;
  }
}

Future<bool?> showGstinVerificationConfirmationDialog(
  BuildContext context,
  GstinDetails data,
) {
  return showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Material(
        elevation: 8,
        borderRadius: AppRadius.lgBorder,
        color: AppColors.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: _activeStatusColor,
                      size: AppIconSize.lg,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'GST Verified',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                _GstinDetailRow(label: 'GSTIN', value: data.gstin),
                _GstinDetailRow(label: 'Legal Name', value: data.legalName),
                _GstinDetailRow(label: 'Trade Name', value: data.tradeName),
                _GstinDetailRow(
                  label: 'Status',
                  valueWidget: _GstStatusChip(status: data.status),
                ),
                _GstinDetailRow(
                  label: 'Constitution',
                  value: data.constitution,
                ),
                _GstinDetailRow(
                  label: 'Taxpayer Type',
                  value: data.taxpayerType,
                ),
                _GstinDetailRow(
                  label: 'Registration Date',
                  value: data.registrationDate,
                ),
                _GstinDetailRow(label: 'State', value: data.state),
                _GstinDetailRow(label: 'PAN', value: data.pan),
                _GstinDetailRow(label: 'Address', value: data.address),
                _GstinDetailRow(
                  label: 'Nature of Business',
                  value: data.natureOfBusiness.join(', '),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Use Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _GstinDetailRow extends StatelessWidget {
  const _GstinDetailRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child:
                valueWidget ??
                Text(
                  value ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _GstStatusChip extends StatelessWidget {
  const _GstStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? _activeStatusColor : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
