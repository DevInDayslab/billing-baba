import 'dart:async';

import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/member_form_dialog.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/party_reminder_schedule_provider.dart';
import 'package:billing_baba/features/parties/repositories/party_reminder_schedule_repository.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/settings/data/notifications_remote_data_source.dart';
import 'package:billing_baba/features/settings/providers/notifications_remote_provider.dart';
import 'package:billing_baba/features/settings/providers/whatsapp_settings_provider.dart';
import 'package:billing_baba/features/settings/repositories/notifications_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class PartyWhatsAppActions {
  static Future<void> showMenu(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) {
    final permissions = ref.read(permissionServiceProvider);
    final canShareSale = permissions.canShare(PermissionModule.sale);
    final canShareParty = permissions.canShare(PermissionModule.party);
    final canInvite = permissions.canCreate(PermissionModule.syncSettings) ||
        permissions.canShare(PermissionModule.syncSettings);

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'WhatsApp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            ListTile(
              enabled: canShareSale,
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Send Invoice'),
              onTap: !canShareSale
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      unawaited(_sendInvoice(context, ref, party));
                    },
            ),
            ListTile(
              enabled: canShareParty || canShareSale,
              leading: const Icon(Icons.alarm_outlined),
              title: const Text('Payment Reminder'),
              onTap: !(canShareParty || canShareSale)
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      unawaited(_sendPaymentReminder(context, ref, party));
                    },
            ),
            ListTile(
              enabled: canShareSale,
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Payment Received'),
              onTap: !canShareSale
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      unawaited(_notifyPaymentReceived(context, ref, party));
                    },
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Open Chat'),
              onTap: () {
                Navigator.pop(ctx);
                unawaited(_openChat(context, party));
              },
            ),
            ListTile(
              enabled: canInvite,
              leading: const Icon(Icons.business_outlined),
              title: const Text('Share Company'),
              subtitle: canInvite
                  ? null
                  : const Text('Requires Sync & Share permission'),
              onTap: !canInvite
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      unawaited(_shareCompany(context, ref, party));
                    },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Vyapar-style reminder schedule dialog (Once / Weekly / Monthly).
  ///
  /// Persists locally until a backend scheduler exists.
  /// Immediate WhatsApp reminders use [showMenu] → Payment Reminder.
  static Future<void> showReminderDialog(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    var frequency = PartyReminderFrequency.once;
    var date = DateTime.now().add(const Duration(days: 7));
    var sendCopy = false;
    var saving = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text('Set Reminder'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Frequency'),
                    const SizedBox(height: 8),
                    SegmentedButton<PartyReminderFrequency>(
                      segments: const [
                        ButtonSegment(
                          value: PartyReminderFrequency.once,
                          label: Text('Once'),
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
                      selected: {frequency},
                      onSelectionChanged: saving
                          ? null
                          : (s) => setLocal(() => frequency = s.first),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reminder date'),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(date)),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: saving
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: date,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 2),
                                ),
                              );
                              if (picked != null) {
                                setLocal(() => date = picked);
                              }
                            },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Send Copy to Myself'),
                      value: sendCopy,
                      onChanged: saving
                          ? null
                          : (v) => setLocal(() => sendCopy = v ?? false),
                    ),
                    // TODO(backend): Remove local-only notice when scheduler API ships.
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Saved on this device only until auto-reminders are enabled.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () {
                          setLocal(() => saving = true);
                          Navigator.pop(ctx, true);
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Next reminder: ${DateFormat('dd MMM yyyy').format(next)}'
          ' (${frequency.name})',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> _sendInvoice(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    final enabled = await _ensureWhatsAppEnabled(context, ref);
    if (!enabled || !context.mounted) return;

    final invoices = await _withLoading(
      context,
      () => _loadOutstandingInvoices(ref, party.id),
    );
    if (!context.mounted) return;
    if (invoices == null) return;

    if (invoices.isEmpty) {
      _snack(context, 'No outstanding invoices for this party');
      return;
    }

    final selected = await _pickInvoice(
      context,
      invoices,
      title: 'Select invoice',
    );
    if (selected == null || !context.mounted) return;

    final result = await _withLoading(
      context,
      () async {
        final repo = await ref.read(notificationsRepositoryProvider.future);
        await repo.shareSalesDocument(selected.id);
        return repo.notifySalesDocument(
          selected.id,
          phone: _digitsOrNull(party.phone),
        );
      },
    );
    if (!context.mounted || result == null) return;
    _showDispatchResult(
      context,
      result,
      success: 'Invoice sent on WhatsApp',
      deduped: 'Invoice already notified recently',
    );
  }

  static Future<void> _sendPaymentReminder(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    final enabled = await _ensureWhatsAppEnabled(context, ref);
    if (!enabled || !context.mounted) return;

    final invoices = await _withLoading(
      context,
      () => _loadOutstandingInvoices(ref, party.id),
    );
    if (!context.mounted) return;
    if (invoices == null) return;

    if (invoices.isEmpty) {
      _snack(context, 'No unpaid invoices for this party');
      return;
    }

    final selected = invoices.length == 1
        ? invoices.first
        : await _pickInvoice(
            context,
            invoices,
            title: 'Select invoice for reminder',
            showBalance: true,
          );
    if (selected == null || !context.mounted) return;

    final result = await _withLoading(
      context,
      () async {
        final repo = await ref.read(notificationsRepositoryProvider.future);
        return repo.sendPartyReminder(
          partyId: party.id,
          salesDocumentId: selected.id,
          phone: _digitsOrNull(party.phone),
          dueDate: selected.dueDate?.toUtc().toIso8601String(),
        );
      },
    );
    if (!context.mounted || result == null) return;
    _showDispatchResult(
      context,
      result,
      success: 'Payment reminder sent',
      deduped: 'Reminder already sent recently',
    );
  }

  static Future<void> _notifyPaymentReceived(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    final enabled = await _ensureWhatsAppEnabled(context, ref);
    if (!enabled || !context.mounted) return;

    final payments = await _withLoading(
      context,
      () => _loadRecentPayments(ref, party.id),
    );
    if (!context.mounted) return;
    if (payments == null) return;

    if (payments.isEmpty) {
      _snack(context, 'No payments found for this party');
      return;
    }

    final selected = payments.length == 1
        ? payments.first
        : await showDialog<PaymentInModel>(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: const Text('Select payment'),
              children: [
                for (final p in payments.take(20))
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(ctx, p),
                    child: Text(
                      '${p.receiptNo} · ₹${p.receivedAmount.toStringAsFixed(0)}',
                    ),
                  ),
              ],
            ),
          );
    if (selected == null || !context.mounted) return;

    final result = await _withLoading(
      context,
      () async {
        final repo = await ref.read(notificationsRepositoryProvider.future);
        return repo.notifyPaymentReceived(selected.id);
      },
    );
    if (!context.mounted || result == null) return;
    _showDispatchResult(
      context,
      result,
      success: 'Payment received message sent',
      deduped: 'Payment already notified recently',
    );
  }

  static Future<void> _openChat(BuildContext context, PartyModel party) async {
    final digits = PartyModel.normalizePhone(party.phone);
    if (digits.length != 10) {
      _snack(context, 'Party has no valid phone number');
      return;
    }

    // Indian mobiles → wa.me expects country code without '+'.
    final uri = Uri.parse('https://wa.me/91$digits');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _snack(context, 'Could not open WhatsApp');
      }
    } on Object {
      if (context.mounted) {
        _snack(context, 'Could not open WhatsApp');
      }
    }
  }

  static Future<void> _shareCompany(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    final phone = PartyModel.normalizePhone(party.phone);
    await showAddMemberDialog(
      context,
      ref,
      initialName: party.name,
      initialPhoneOrEmail: phone.isEmpty ? party.email : phone,
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

  static Future<List<SaleInvoiceModel>> _loadOutstandingInvoices(
    WidgetRef ref,
    String partyId,
  ) async {
    final service = await ref.read(salesServiceProvider.future);
    final page = await service.fetchInvoicesPage(
      SalesDocumentListQuery(
        partyId: partyId,
        status: 'finalized',
        documentType: 'tax_invoice',
      ),
    );
    return page.items.where((i) => i.balance > 0).toList();
  }

  static Future<List<PaymentInModel>> _loadRecentPayments(
    WidgetRef ref,
    String partyId,
  ) async {
    final service = await ref.read(salesServiceProvider.future);
    final page = await service.fetchPaymentsPage(
      PaymentListQuery(
        partyId: partyId,
        direction: 'received',
      ),
    );
    return page.items;
  }

  static Future<SaleInvoiceModel?> _pickInvoice(
    BuildContext context,
    List<SaleInvoiceModel> invoices, {
    required String title,
    bool showBalance = false,
  }) {
    return showDialog<SaleInvoiceModel>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: [
          for (final inv in invoices.take(20))
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, inv),
              child: Text(
                showBalance
                    ? '${inv.invoiceNo} · Bal ₹${inv.balance.toStringAsFixed(0)}'
                    : '${inv.invoiceNo} · ₹${inv.amount.toStringAsFixed(0)}',
              ),
            ),
        ],
      ),
    );
  }

  static Future<T?> _withLoading<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const PopScope(
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
    _snack(
      context,
      result.errorMessage ?? 'Failed to send notification',
    );
  }

  static String? _digitsOrNull(String phone) {
    final digits = PartyModel.normalizePhone(phone);
    return digits.isEmpty ? null : digits;
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
