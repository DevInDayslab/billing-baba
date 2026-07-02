import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/providers/party_groups_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showManagePartyGroupsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const ManagePartyGroupsDialog(),
  );
}

class ManagePartyGroupsDialog extends ConsumerStatefulWidget {
  const ManagePartyGroupsDialog({super.key});

  @override
  ConsumerState<ManagePartyGroupsDialog> createState() =>
      _ManagePartyGroupsDialogState();
}

class _ManagePartyGroupsDialogState
    extends ConsumerState<ManagePartyGroupsDialog> {
  Future<void> _addGroup() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Party Group'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: saleFieldTextStyle,
          decoration: buildSaleFieldDecoration(hint: 'Group name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(dialogContext).pop(trimmed);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || !mounted) return;

    final added = ref.read(partyGroupsProvider.notifier).addGroup(name);
    if (!added && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "$name" already exists')),
      );
    }
  }

  Future<void> _renameGroup(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Party Group'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: saleFieldTextStyle,
          decoration: buildSaleFieldDecoration(hint: 'Group name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(dialogContext).pop(trimmed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || !mounted) return;

    final renamed = ref
        .read(partyGroupsProvider.notifier)
        .renameGroup(currentName, newName);
    if (!renamed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not rename group')),
      );
    }
  }

  Future<void> _deleteGroup(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Party Group'),
        content: Text(
          'Delete "$name"? Parties in this group will be ungrouped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    ref.read(partyGroupsProvider.notifier).deleteGroup(name);
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(partyGroupsProvider);

    return AlertDialog(
      title: const Text('Manage Party Groups'),
      content: SizedBox(
        width: 380,
        child: groups.isEmpty
            ? const Text(
                'No party groups yet.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            : SizedBox(
                height: 280,
                child: ListView.separated(
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        group,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _renameGroup(group),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Rename',
                            color: AppColors.primary,
                          ),
                          IconButton(
                            onPressed: () => _deleteGroup(group),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Delete',
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: _addGroup,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Group'),
        ),
      ],
    );
  }
}
