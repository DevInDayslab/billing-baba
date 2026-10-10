import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/settings/models/party_settings.dart';
import 'package:flutter/material.dart';

/// Add/Edit payment reminder message (no close icon — use Cancel).
Future<String?> showPartyReminderMessageDialog({
  required BuildContext context,
  required String initialAdditionalMessage,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _PartyReminderMessageDialog(
      initialAdditionalMessage: initialAdditionalMessage,
    ),
  );
}

class _PartyReminderMessageDialog extends StatefulWidget {
  const _PartyReminderMessageDialog({required this.initialAdditionalMessage});

  final String initialAdditionalMessage;

  @override
  State<_PartyReminderMessageDialog> createState() =>
      _PartyReminderMessageDialogState();
}

class _PartyReminderMessageDialogState extends State<_PartyReminderMessageDialog> {
  late final TextEditingController _additionalController;
  late String _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialAdditionalMessage;
    _additionalController = TextEditingController(text: _draft);
  }

  @override
  void dispose() {
    _additionalController.dispose();
    super.dispose();
  }

  void _resetDefault() {
    setState(() {
      _draft = '';
      _additionalController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add/Edit Reminder Message',
                style: AppTypography.inter(
                  fontSize: AppTypography.titleMediumSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: listPanelCardBorder),
              const SizedBox(height: AppSpacing.md),
              Text(
                PartyPaymentReminderMessageTemplate.greetingLine,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodyMediumSize,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                PartyPaymentReminderMessageTemplate.pendingLine,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodyMediumSize,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _additionalController,
                maxLines: 4,
                onChanged: (v) => _draft = v,
                decoration: InputDecoration(
                  hintText: 'Type additional message',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.smBorder,
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                PartyPaymentReminderMessageTemplate.closingLine,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodyMediumSize,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: AppTypography.inter(
                        fontSize: AppTypography.bodySmallSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: _resetDefault,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: AppTypography.inter(
                        fontSize: AppTypography.bodySmallSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('RESET DEFAULT'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _draft.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.smBorder,
                      ),
                      textStyle: AppTypography.inter(
                        fontSize: AppTypography.bodySmallSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
