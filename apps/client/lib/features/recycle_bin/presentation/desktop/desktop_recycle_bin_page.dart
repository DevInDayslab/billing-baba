import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/recycle_bin/application/recycle_bin_provider.dart';
import 'package:billing_baba/features/recycle_bin/models/recycle_bin_item.dart';
import 'package:billing_baba/features/utilities/presentation/desktop/widgets/utilities_page_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopRecycleBinPage extends ConsumerWidget {
  const DesktopRecycleBinPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(recycleBinListProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: UtilitiesPageTitleBar(
              currentRoute: AppRoutes.utilitiesRecycleBin,
            ),
          ),
          Expanded(
            child: asyncItems.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No deleted transactions in the last 90 days'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _RecycleBinRow(item: items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecycleBinRow extends ConsumerWidget {
  const _RecycleBinRow({required this.item});

  final RecycleBinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(recycleBinListProvider.notifier);
    return ListTile(
      title: Text(item.label),
      subtitle: Text(
        '${item.entityType} · ${item.daysRemaining} days left',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => notifier.restore(item),
            child: const Text('Restore'),
          ),
          TextButton(
            onPressed: () => notifier.purge(item),
            child: const Text('Delete forever'),
          ),
        ],
      ),
    );
  }
}
