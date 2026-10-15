import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_contact_import_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/application/party_import_preview_mapper.dart';
import 'package:billing_baba/features/utilities/application/import_parties_commit.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:billing_baba/features/utilities/models/import_party_preview_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showPartyContactImportPreviewDialog(
  BuildContext context,
  WidgetRef ref, {
  required String sessionId,
}) async {
  final service = ref.read(partyContactImportServiceProvider);
  final session = await service.pollSession(sessionId, includeStaging: true);
  final parties = ref.read(partyListProvider).asData?.value ?? const [];
  final rows = PartyImportPreviewMapper.fromContactStaging(
    staging: session.stagingRows,
    existingParties: parties,
  );

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _PartyContactImportPreviewDialog(
      sessionId: sessionId,
      initialRows: rows,
    ),
  );
}

class _PartyContactImportPreviewDialog extends ConsumerStatefulWidget {
  const _PartyContactImportPreviewDialog({
    required this.sessionId,
    required this.initialRows,
  });

  final String sessionId;
  final List<ImportPartyPreviewRow> initialRows;

  @override
  ConsumerState<_PartyContactImportPreviewDialog> createState() =>
      _PartyContactImportPreviewDialogState();
}

class _PartyContactImportPreviewDialogState
    extends ConsumerState<_PartyContactImportPreviewDialog> {
  late List<ImportPartyPreviewRow> _rows;
  var _importing = false;

  @override
  void initState() {
    super.initState();
    _rows = List<ImportPartyPreviewRow>.from(widget.initialRows);
  }

  int get _selectedValidCount =>
      _rows.where((row) => row.canImport).length;

  Future<void> _import() async {
    if (_importing || _selectedValidCount == 0) return;
    setState(() => _importing = true);
    try {
      final result = await commitImportPartyRows(
        ref.read(partyListProvider.notifier),
        _rows,
      );
      if (!mounted) return;
      if (result != null) {
        await ref
            .read(partyContactImportServiceProvider)
            .commitSession(widget.sessionId);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${result.successCount} parties'
              '${result.failedCount > 0 ? ', ${result.failedCount} failed' : ''}.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review imported contacts'),
      content: SizedBox(
        width: 520,
        height: 420,
        child: _rows.isEmpty
            ? const Center(child: Text('No contacts to import.'))
            : ListView.builder(
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  final canSelect = row.status == ImportRowStatus.valid;
                  return CheckboxListTile(
                    value: row.isSelected && canSelect,
                    onChanged: canSelect
                        ? (selected) {
                            setState(() {
                              _rows[index] = row.copyWith(
                                isSelected: selected ?? false,
                              );
                            });
                          }
                        : null,
                    title: Text(row.partyName),
                    subtitle: Text(
                      row.issueMessage ??
                          '${row.mobile} · ${row.typeLabel}',
                      style: TextStyle(
                        color: row.status == ImportRowStatus.error
                            ? AppColors.error
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: _importing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _importing || _selectedValidCount == 0 ? null : _import,
          child: _importing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Import $_selectedValidCount'),
        ),
      ],
    );
  }
}
