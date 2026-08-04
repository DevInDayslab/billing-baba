import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/shared/attachments/attachment_offline_metadata_store.dart';
import 'package:billing_baba/shared/attachments/attachment_sync_helper.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_list_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyNotesAttachmentsSection extends ConsumerStatefulWidget {
  const PartyNotesAttachmentsSection({
    required this.party,
    this.useMobileCards = false,
    super.key,
  });

  final PartyModel party;
  final bool useMobileCards;

  @override
  ConsumerState<PartyNotesAttachmentsSection> createState() =>
      _PartyNotesAttachmentsSectionState();
}

class _PartyNotesAttachmentsSectionState
    extends ConsumerState<PartyNotesAttachmentsSection> {
  static const _entityType = 'party';

  late final TextEditingController _notesController;
  bool _savingNotes = false;
  bool _loadingAttachments = true;
  bool _syncingAttachments = false;
  List<SaleFormAttachment> _images = const [];
  List<SaleFormAttachment> _documents = const [];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.party.notes);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadAttachments());
    });
  }

  @override
  void didUpdateWidget(covariant PartyNotesAttachmentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.party.id != widget.party.id) {
      _notesController.text = widget.party.notes;
      _images = const [];
      _documents = const [];
      _loadingAttachments = true;
      unawaited(_loadAttachments());
    } else if (!_savingNotes && oldWidget.party.notes != widget.party.notes) {
      _notesController.text = widget.party.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAttachments() async {
    final service = await readDocumentAttachmentService(ref);
    final remote = service == null
        ? const <SaleFormAttachment>[]
        : await service.fetchAttachments(
            entityType: _entityType,
            entityId: widget.party.id,
          );
    final offline = await restoreOfflineTransactionAttachments(
      entityType: _entityType,
      entityId: widget.party.id,
    );
    final remoteSplit = splitTransactionAttachments(remote);
    if (!mounted) return;
    setState(() {
      _images = [...remoteSplit.images, ...offline.images];
      _documents = [...remoteSplit.documents, ...offline.documents];
      _loadingAttachments = false;
    });
  }

  Future<void> _saveNotes() async {
    final value = _notesController.text.trim();
    setState(() => _savingNotes = true);
    try {
      await ref
          .read(partyListProvider.notifier)
          .updatePartyNotes(widget.party.id, value.isEmpty ? null : value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes saved')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save notes: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _savingNotes = false);
      }
    }
  }

  Future<void> _clearNotes() async {
    _notesController.clear();
    await _saveNotes();
  }

  Future<void> _syncPendingAttachments() async {
    setState(() => _syncingAttachments = true);
    try {
      final service = await readDocumentAttachmentService(ref);
      if (service == null) return;
      final synced = await syncPendingAttachments(
        service: service,
        entityType: _entityType,
        entityId: widget.party.id,
        attachments: [..._images, ..._documents],
      );
      await AttachmentOfflineMetadataStore.create().then(
        (store) => store.clear(_entityType, widget.party.id),
      );
      if (mounted) {
        final split = splitTransactionAttachments(synced);
        setState(() {
          _images = split.images;
          _documents = split.documents;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _syncingAttachments = false);
      }
    }
  }

  void _replaceAttachment(
    String id,
    String name,
    List<SaleFormAttachment> source,
    void Function(List<SaleFormAttachment>) assign,
  ) {
    final index = source.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final next = List<SaleFormAttachment>.from(source);
    next[index] = next[index].copyWith(name: name);
    assign(next);
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionServiceProvider);
    final canEdit = permissions.canEdit(PermissionModule.party);
    final canDelete = permissions.canDelete(PermissionModule.party);
    final canShare = permissions.canShare(PermissionModule.party);

    final section = Column(
      children: [
        MobileListSection(
          title: 'Notes',
          children: [
            TextField(
              controller: _notesController,
              maxLines: 5,
              enabled: canEdit && !_savingNotes,
              decoration: const InputDecoration(
                hintText: 'Add private notes about this party',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                FilledButton(
                  onPressed: canEdit && !_savingNotes ? _saveNotes : null,
                  child: _savingNotes
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Notes'),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: canDelete && !_savingNotes ? _clearNotes : null,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
        if (_loadingAttachments)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          )
        else
          transactionAttachmentsSection(
            context: context,
            ref: ref,
            entityType: _entityType,
            entityId: widget.party.id,
            description: '',
            images: _images,
            documents: _documents,
            onDescriptionChanged: (_) {},
            addImage: (attachment) =>
                setState(() => _images = [..._images, attachment]),
            addDocument: (attachment) =>
                setState(() => _documents = [..._documents, attachment]),
            removeImage: (id) => setState(
              () => _images = _images.where((item) => item.id != id).toList(),
            ),
            removeDocument: (id) => setState(
              () =>
                  _documents = _documents.where((item) => item.id != id).toList(),
            ),
            updateImage: (id, name) => setState(
              () => _replaceAttachment(
                id,
                name,
                _images,
                (next) => _images = next,
              ),
            ),
            updateDocument: (id, name) => setState(
              () => _replaceAttachment(
                id,
                name,
                _documents,
                (next) => _documents = next,
              ),
            ),
          ),
        if (hasPendingTransactionAttachments(_images, _documents))
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: _syncingAttachments ? null : _syncPendingAttachments,
                child: Text(
                  _syncingAttachments ? 'Syncing...' : 'Sync pending attachments',
                ),
              ),
            ),
          ),
        if (!canEdit || !canDelete || !canShare)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Some attachment actions are restricted by your permissions.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.useMobileCards) {
      return section;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: section,
    );
  }
}
