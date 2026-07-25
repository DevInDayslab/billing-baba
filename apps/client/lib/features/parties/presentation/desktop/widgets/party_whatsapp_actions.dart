import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/application/party_reminder_schedule_provider.dart';
import 'package:billing_baba/features/parties/repositories/party_reminder_schedule_repository.dart';
import 'package:billing_baba/features/settings/data/notifications_remote_data_source.dart';
import 'package:billing_baba/features/settings/application/notifications_remote_provider.dart';
import 'package:billing_baba/features/settings/application/whatsapp_settings_provider.dart';
import 'package:billing_baba/features/settings/repositories/notifications_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Party Details SMS / WhatsApp / Reminder actions (Vyapar workflow).
///
/// SMS and WhatsApp both call the same party reminder API immediately.
/// Only Reminder opens the schedule dialog.
abstract final class PartyWhatsAppActions {
  /// Immediate payment reminder (SMS or WhatsApp button).
  /// Both channels reuse `POST /parties/:id/reminders`.
  static Future<void> sendPaymentReminderNow(
    BuildContext context,
    WidgetRef ref,
    PartyModel party, {
    required double outstanding,
  }) async {
    if (outstanding <= 0) {
      _snack(context, 'No outstanding balance for this party');
      return;
    }

    final phone = PartyModel.normalizePhone(party.phone);
    if (phone.length != 10) {
      _snack(context, 'Party has no valid phone number');
      return;
    }

    final enabled = await _ensureWhatsAppEnabled(context, ref);
    if (!enabled || !context.mounted) return;

    final result = await _withLoading(context, () async {
      final repo = await ref.read(notificationsRepositoryProvider.future);
      return repo.sendPartyReminder(
        partyId: party.id,
        phone: phone,
      );
    });
    if (!context.mounted || result == null) return;

    _showDispatchResult(
      context,
      result,
      success: 'Payment reminder sent',
      deduped: 'Reminder already sent recently',
    );
  }

  /// Persists locally until a backend reminder-schedules API is available.
  static Future<void> showReminderDialog(
    BuildContext context,
    WidgetRef ref,
    PartyModel party, {
    required double outstanding,
  }) async {
    final existing = ref.read(partyNextReminderProvider(party.id));
    var frequency = existing?.frequency ?? PartyReminderFrequency.once;
    var date = existing?.nextReminderAt ??
        DateTime.now().add(const Duration(days: 1));
    var sendCopy = existing?.sendCopyToMyself ?? false;
    var saving = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final dateLabel = DateFormat('dd MMM, yyyy').format(date);
            final freqLabel = switch (frequency) {
              PartyReminderFrequency.once => null,
              PartyReminderFrequency.weekly => 'Weekly',
              PartyReminderFrequency.monthly => 'Monthly',
            };
            final nextLabel = freqLabel == null
                ? 'Next Reminder at $dateLabel'
                : 'Next Reminder at $dateLabel ($freqLabel)';

            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              existing == null
                                  ? 'Set Reminder'
                                  : 'Edit Reminder',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (existing != null)
                            IconButton(
                              tooltip: 'Delete reminder',
                              onPressed: saving
                                  ? null
                                  : () async {
                                      await ref
                                          .read(
                                            partyReminderScheduleMapProvider
                                                .notifier,
                                          )
                                          .clear(party.id);
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx, false);
                                      }
                                    },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: saving
                                ? null
                                : () => Navigator.pop(ctx, false),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${party.name}: ',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: PartyModel.displayOutstanding(outstanding),
                              style: TextStyle(
                                color: outstanding > 0
                                    ? const Color(0xFF2E7D32)
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select Frequency',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _FrequencyRadios(
                        value: frequency,
                        enabled: !saving,
                        onChanged: (v) => setLocal(() => frequency = v),
                      ),
                      const SizedBox(height: 16),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Select Date',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: saving
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: date.isBefore(DateTime.now())
                                      ? DateTime.now()
                                      : date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ),
                                );
                                if (picked != null) {
                                  setLocal(() => date = picked);
                                }
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                          ),
                          child: Text(dateLabel),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          nextLabel,
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Send a copy to yourself',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'You will receive a notification 24 hrs before '
                            'it is sent to the party.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          value: sendCopy,
                          onChanged: saving
                              ? null
                              : (v) => setLocal(() => sendCopy = v),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.pop(ctx, false),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade800,
                              backgroundColor: Colors.grey.shade200,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: saving
                                ? null
                                : () {
                                    setLocal(() => saving = true);
                                    Navigator.pop(ctx, true);
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                            ),
                            child: saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final next = DateTime(date.year, date.month, date.day);
    await ref.read(partyReminderScheduleMapProvider.notifier).save(
          PartyReminderSchedule(
            partyId: party.id,
            frequency: frequency,
            nextReminderAt: next,
            sendCopyToMyself: sendCopy,
          ),
        );

    if (!context.mounted) return;
    final freqSuffix = switch (frequency) {
      PartyReminderFrequency.once => '',
      PartyReminderFrequency.weekly => ' (Weekly)',
      PartyReminderFrequency.monthly => ' (Monthly)',
    };
    _snack(
      context,
      'Next Reminder at ${DateFormat('dd MMM yyyy').format(next)}$freqSuffix',
    );
  }

  static Future<bool> _ensureWhatsAppEnabled(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final settings = await ref.read(whatsAppSettingsProvider.future);
    if (settings.enabled) return true;
    if (!context.mounted) return false;
    _snack(context, 'Enable WhatsApp Messaging in Settings first');
    return false;
  }

  static Future<T?> _withLoading<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      return await action();
    } on Object catch (e) {
      if (context.mounted) {
        _snack(context, NotificationsRepository.messageFor(e));
      }
      return null;
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  static void _showDispatchResult(
    BuildContext context,
    NotifyDispatchResult result, {
    required String success,
    required String deduped,
  }) {
    if (result.notified) {
      _snack(context, result.deduped ? deduped : success);
      return;
    }
    _snack(context, result.errorMessage ?? 'Failed to send reminder');
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _FrequencyRadios extends StatelessWidget {
  const _FrequencyRadios({
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final PartyReminderFrequency value;
  final ValueChanged<PartyReminderFrequency> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PartyReminderFrequency>(
      segments: const [
        ButtonSegment(
          value: PartyReminderFrequency.once,
          label: Text('One Time'),
        ),
        ButtonSegment(
          value: PartyReminderFrequency.weekly,
          label: Text('Weekly'),
        ),
        ButtonSegment(
          value: PartyReminderFrequency.monthly,
          label: Text('Monthly'),
        ),
      ],
      selected: {value},
      onSelectionChanged: enabled
          ? (selected) {
              if (selected.isNotEmpty) onChanged(selected.first);
            }
          : null,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
      ),
    );
  }
}
