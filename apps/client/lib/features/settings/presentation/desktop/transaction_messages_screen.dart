import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/settings/application/transaction_message_settings_provider.dart';
import 'package:billing_baba/features/settings/models/transaction_message_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopTransactionMessagesScreen extends ConsumerStatefulWidget {
  const DesktopTransactionMessagesScreen({this.embedded = false, super.key});

  final bool embedded;

  static const _narrowBreakpoint = 900.0;

  @override
  ConsumerState<DesktopTransactionMessagesScreen> createState() =>
      _TransactionMessagesScreenState();
}

class _TransactionMessagesScreenState
    extends ConsumerState<DesktopTransactionMessagesScreen> {
  TransactionMessageSettings? _draft;
  TransactionMessageType _selectedType = TransactionMessageType.sale;
  bool _saving = false;
  late final TextEditingController _bodyController;
  late final TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();
    _footerController = TextEditingController();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _syncEditors(TransactionMessageSettings draft) {
    final template = draft.templateFor(_selectedType);
    if (_bodyController.text != template.body) {
      _bodyController.value = TextEditingValue(
        text: template.body,
        selection: TextSelection.collapsed(offset: template.body.length),
      );
    }
    if (_footerController.text != template.footer) {
      _footerController.value = TextEditingValue(
        text: template.footer,
        selection: TextSelection.collapsed(offset: template.footer.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(transactionMessageSettingsProvider);

    final content = settingsAsync.when(
      // Local prefs — show defaults immediately instead of a full-screen spinner.
      loading: () {
        final draft = _draft ?? TransactionMessageSettings.defaults();
        _syncEditors(draft);
        return _buildBody(draft);
      },
      error: (e, _) => Center(child: Text(OfflineUiMessages.messageFor(e))),
      data: (settings) {
        _draft ??= settings;
        final draft = _draft!;
        _syncEditors(draft);
        return _buildBody(draft);
      },
    );

    final saveBar = settingsAsync.maybeWhen(
      data: (_) => _buildSaveBar(),
      loading: () => _draft != null ? _buildSaveBar() : const SizedBox.shrink(),
      orElse: () => const SizedBox.shrink(),
    );

    // Embedded in Settings IndexedStack — avoid nested Scaffold (blank body).
    if (widget.embedded) {
      return ColoredBox(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: content),
            saveBar,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Transaction Messages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: content,
      bottomNavigationBar: saveBar,
    );
  }

  Widget _buildBody(TransactionMessageSettings draft) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow =
            constraints.maxWidth <
            DesktopTransactionMessagesScreen._narrowBreakpoint;
        final left = _buildSettingsPanel(draft);
        final right = _buildEditorPreview(draft);
        if (narrow) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              left,
              const SizedBox(height: AppSpacing.lg),
              right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: left,
              ),
            ),
            Container(width: 1, color: listPanelCardBorder),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: right,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: listPanelCardBorder),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _draft == null || _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
              disabledForegroundColor: Colors.white70,
              elevation: 0,
              minimumSize: const Size(96, 40),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              textStyle: AppTypography.inter(
                fontSize: AppTypography.bodyMediumSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: _saving
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
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(TransactionMessageSettings draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message Recipient Settings',
          style: _sectionTitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        _checkbox(
          'Send Message to Party',
          draft.sendToParty,
          (v) => _update(draft.copyWith(sendToParty: v)),
        ),
        _checkbox(
          'Send Transaction Update Message',
          draft.sendTransactionUpdate,
          (v) => _update(draft.copyWith(sendTransactionUpdate: v)),
        ),
        _checkbox(
          'Send Copy to Myself',
          draft.sendCopyToMyself,
          (v) => _update(draft.copyWith(sendCopyToMyself: v)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Message Content', style: _sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        _checkbox(
          'Include Current Balance',
          draft.includeCurrentBalance,
          (v) => _update(draft.copyWith(includeCurrentBalance: v)),
        ),
        _checkbox(
          'Include Invoice Link',
          draft.includeInvoiceLink,
          (v) => _update(draft.copyWith(includeInvoiceLink: v)),
        ),
        _checkbox(
          'Include Footer',
          draft.includeFooter,
          (v) => _update(draft.copyWith(includeFooter: v)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Automatically Send For', style: _sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: [
            for (final type in TransactionMessageType.values)
              SizedBox(
                width: 220,
                child: _checkbox(
                  type.label,
                  draft.isAutoSendEnabled(type),
                  (v) {
                    final map = Map<TransactionMessageType, bool>.from(
                      draft.autoSend,
                    );
                    map[type] = v;
                    _update(draft.copyWith(autoSend: map));
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditorPreview(TransactionMessageSettings draft) {
    final preview = _renderPreview(draft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Transaction Type', style: _sectionTitle),
            const Spacer(),
            DropdownButton<TransactionMessageType>(
              value: _selectedType,
              items: [
                for (final type in TransactionMessageType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (type) {
                if (type == null || type == _selectedType) return;
                setState(() {
                  _selectedType = type;
                  _syncEditors(draft);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Edit Message', style: _sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _bodyController,
          maxLines: 10,
          onChanged: (body) {
            final templates = Map<TransactionMessageType, MessageTemplate>.from(
              draft.templates,
            );
            final current = draft.templateFor(_selectedType);
            templates[_selectedType] = current.copyWith(body: body);
            _update(draft.copyWith(templates: templates));
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _footerController,
          maxLines: 2,
          enabled: draft.includeFooter,
          onChanged: (footer) {
            final templates = Map<TransactionMessageType, MessageTemplate>.from(
              draft.templates,
            );
            final current = draft.templateFor(_selectedType);
            templates[_selectedType] = current.copyWith(footer: footer);
            _update(draft.copyWith(templates: templates));
          },
          decoration: const InputDecoration(
            labelText: 'Footer',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Message Preview', style: _sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFE5DDD5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF8C6),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  preview,
                  style: const TextStyle(height: 1.35, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _renderPreview(TransactionMessageSettings draft) {
    final template = draft.templateFor(_selectedType);
    var body = template.body;
    if (draft.includeFooter && template.footer.trim().isNotEmpty) {
      body = '$body\n\n${template.footer}';
    }
    const samples = {
      'customer_name': 'Ishu',
      'company_name': 'Billing Baba Traders',
      'business_name': 'Billing Baba Traders',
      'invoice_number': 'INV-1042',
      'amount': '12,500',
      'balance': '2,500',
      'invoice_url': 'https://billingbaba.com/invoice/sample',
      'due_date': '25 Jul 2026',
      'phone': '+91******8002',
    };
    for (final e in samples.entries) {
      body = body.replaceAll('{{${e.key}}}', e.value);
    }
    if (!draft.includeInvoiceLink) {
      body = body.replaceAll(samples['invoice_url']!, '');
    }
    if (!draft.includeCurrentBalance) {
      body = body.replaceAll(samples['balance']!, '');
    }
    return body.trim();
  }

  void _update(TransactionMessageSettings next) {
    setState(() => _draft = next);
  }

  Widget _checkbox(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: (v) => onChanged(v ?? false),
    );
  }

  TextStyle get _sectionTitle => AppTypography.inter(
    fontSize: AppTypography.titleSmallSize,
    fontWeight: FontWeight.w600,
  );

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(transactionMessageSettingsProvider.notifier).save(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction message settings saved')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save settings: ${OfflineUiMessages.messageFor(error)}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
