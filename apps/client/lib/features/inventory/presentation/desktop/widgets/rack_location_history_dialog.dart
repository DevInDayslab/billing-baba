import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_location_history_model.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const int _rackLocationHistoryDisplayLimit = 5;

Future<void> showRackLocationHistoryDialog(
  BuildContext context, {
  required List<ItemLocationHistoryModel> history,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => RackLocationHistoryDialog(history: history),
  );
}

class RackLocationHistoryDialog extends StatelessWidget {
  const RackLocationHistoryDialog({required this.history, super.key});

  final List<ItemLocationHistoryModel> history;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final entries = [...history]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (entries.length > _rackLocationHistoryDisplayLimit) {
      entries.removeRange(
        _rackLocationHistoryDisplayLimit,
        entries.length,
      );
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Last location updates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Showing the 5 most recent updates.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: entries.isEmpty
                    ? const Center(
                        child: Text(
                          'No location updates recorded yet.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final locationLabel = [
                            if (entry.rack != null && entry.rack!.isNotEmpty)
                              entry.rack,
                            if (entry.shelf != null && entry.shelf!.isNotEmpty)
                              entry.shelf,
                          ].join(' / ');

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.photoUrl != null &&
                                    entry.photoUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AppNetworkImage(
                                      imageUrl: entry.photoUrl!,
                                      width: 72,
                                      height: 72,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      LucideIcons.imageOff,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateFormat.format(entry.createdAt),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (locationLabel.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          locationLabel,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      if (entry.employeeLabel != null &&
                                          entry.employeeLabel!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Updated by: ${entry.employeeLabel}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
