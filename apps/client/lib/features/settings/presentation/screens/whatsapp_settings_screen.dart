import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/data/notifications_remote_data_source.dart';
import 'package:billing_baba/features/settings/models/whatsapp_settings.dart';
import 'package:billing_baba/features/settings/providers/notifications_remote_provider.dart';
import 'package:billing_baba/features/settings/providers/whatsapp_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WhatsAppSettingsScreen extends ConsumerStatefulWidget {
  const WhatsAppSettingsScreen({super.key});

  @override
  ConsumerState<WhatsAppSettingsScreen> createState() =>
      _WhatsAppSettingsScreenState();
}

class _WhatsAppSettingsScreenState
    extends ConsumerState<WhatsAppSettingsScreen> {
  WhatsAppSettings? _draft;
  bool _saving = false;
  bool _testing = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(whatsAppSettingsProvider);
    final statusAsync = ref.watch(_notificationStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('WhatsApp'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (settings) {
          _draft ??= settings;
          final draft = _draft!;
          final status = statusAsync.asData?.value;
          final apiConnected = status?.connected ?? false;
          final statusLabel = !draft.enabled
              ? 'Disabled'
              : apiConnected
                  ? 'Connected'
                  : 'Not connected';
          final statusColor = !draft.enabled
              ? Colors.grey.shade700
              : apiConnected
                  ? Colors.green.shade700
                  : Colors.orange.shade800;
          final sender = status?.senderMasked ?? '—';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'WhatsApp Messaging',
                style: AppTypography.inter(
                  fontSize: AppTypography.titleMediumSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable WhatsApp Messaging'),
                        value: draft.enabled,
                        onChanged: (v) => setState(
                          () => _draft = draft.copyWith(enabled: v),
                        ),
                      ),
                      const Divider(),
                      const _InfoRow(label: 'Provider', value: 'Twilio WhatsApp'),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(
                        label: 'Status',
                        value: statusLabel,
                        valueColor: statusColor,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(label: 'Sender Number', value: sender),
                      const SizedBox(height: AppSpacing.lg),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: !draft.enabled || _testing
                              ? null
                              : () => _sendTest(context),
                          icon: _testing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_outlined),
                          label: Text(_testing ? 'Sending…' : 'Test Message'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(
            onPressed: _draft == null || _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save'),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(whatsAppSettingsProvider.notifier).save(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp settings saved')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendTest(BuildContext context) async {
    final controller = TextEditingController();
    final phone = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send test message'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: '8920108002',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (phone == null || phone.isEmpty || !mounted) return;

    setState(() => _testing = true);
    try {
      final remote = await ref.read(notificationsRemoteProvider.future);
      final result = await remote.sendTest(phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.notified
                ? (result.deduped
                    ? 'Test already sent recently (deduped)'
                    : 'Test message sent')
                : (result.errorMessage ?? 'Failed to send test message'),
          ),
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

final FutureProvider<NotificationStatusDto> _notificationStatusProvider =
    FutureProvider.autoDispose((ref) async {
  final remote = await ref.watch(notificationsRemoteProvider.future);
  return remote.getStatus();
});
