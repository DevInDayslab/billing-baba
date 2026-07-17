import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/domain/models/lead_activity.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeadActivityTable extends StatelessWidget {
  const LeadActivityTable({
    required this.activities,
    super.key,
  });

  final List<LeadActivity> activities;

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No activities recorded for this lead yet.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InventoryListHeader(
          showColumnSeparators: true,
          columns: [
            InventoryListColumn(label: 'TYPE', flex: 2),
            InventoryListColumn(label: 'NOTES', flex: 4),
            InventoryListColumn(label: 'DATE', flex: 3),
            InventoryListColumn(label: 'ADDED BY', flex: 2),
            InventoryListColumn(label: 'ACTIONS', flex: 1, fixedWidth: 48),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Container(
                decoration: BoxDecoration(
                  color: index.isOdd ? const Color(0xFFFAFAFA) : Colors.white,
                  border: const Border(
                    bottom: BorderSide(color: inventoryCardBorder),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        activity.type.label,
                        style: InventoryStyles.listCellStyle,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        activity.notes?.trim().isNotEmpty == true
                            ? activity.notes!
                            : '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: InventoryStyles.listCellStyle,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _dateFormat.format(activity.createdAt.toLocal()),
                        style: InventoryStyles.listCellStyle,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        activity.addedBy?.trim().isNotEmpty == true
                            ? activity.addedBy!
                            : '—',
                        style: InventoryStyles.listCellStyle,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: PopupMenuButton<String>(
                        tooltip: 'Actions',
                        icon: const Icon(
                          Icons.more_vert,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'view',
                            child: Text('View'),
                          ),
                        ],
                        onSelected: (_) {},
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
