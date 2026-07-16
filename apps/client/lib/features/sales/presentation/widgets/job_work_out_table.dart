import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/widgets/module_export_actions.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/job_work_out_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/job_work_out_dialog.dart';
import 'package:billing_baba/features/sales/presentation/widgets/job_work_out_status_badge.dart';
import 'package:billing_baba/features/sales/providers/job_work_orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tableHeaderBg = Color(0xFFF5F7FA);
const _convertLinkColor = Color(0xFF1565C0);

const _dateColWidth = 120.0;
const _partyColWidth = 160.0;
const _jobIdColWidth = 90.0;
const _deliveryColWidth = 130.0;
const _statusColWidth = 180.0;
const _actionsColWidth = 220.0;

const double _minTableWidth =
    _dateColWidth +
    _partyColWidth +
    _jobIdColWidth +
    _deliveryColWidth +
    _statusColWidth +
    _actionsColWidth +
    80;

class JobWorkOutTable extends ConsumerWidget {
  const JobWorkOutTable({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    String? orderId,
  }) async {
    final saved = await showJobWorkOutDialog(context, orderId: orderId);
    if (saved == true) {
      await ref.read(jobWorkOrdersListProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(jobWorkOrdersListProvider);
    final listNotifier = ref.read(jobWorkOrdersListProvider.notifier);

    return ordersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error.toString(),
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: listNotifier.refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (page) => _JobWorkOutTableContent(
        items: page.items,
        onEdit: (item) => _openForm(context, ref, orderId: item.id),
        onRefresh: listNotifier.refresh,
      ),
    );
  }
}

class _JobWorkOutTableContent extends ConsumerWidget {
  const _JobWorkOutTableContent({
    required this.items,
    required this.onEdit,
    required this.onRefresh,
  });

  final List<JobWorkOrderListItem> items;
  final void Function(JobWorkOrderListItem item) onEdit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _XlsChip(
                  onTap: () => ModuleExportActions.exportJobWork(context, ref),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  color: AppColors.textSecondary,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth.clamp(
                  _minTableWidth,
                  double.infinity,
                );

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _TableHeaderRow(),
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: _cardBorder),
                          _DataRow(
                            item: items[i],
                            onTap: () => onEdit(items[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _tableHeaderBg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: const Row(
        children: [
          SizedBox(
            width: _dateColWidth,
            child: Text('DATE', style: _headerStyle),
          ),
          SizedBox(
            width: _partyColWidth,
            child: Text('PARTY', style: _headerStyle),
          ),
          SizedBox(
            width: _jobIdColWidth,
            child: Text('JOB ID', style: _headerStyle),
          ),
          SizedBox(
            width: _deliveryColWidth,
            child: Text('DELIVERY DATE', style: _headerStyle),
          ),
          SizedBox(
            width: _statusColWidth,
            child: Text('STATUS', style: _headerStyle),
          ),
          SizedBox(
            width: _actionsColWidth,
            child: Text('ACTIONS', style: _headerStyle),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends ConsumerWidget {
  const _DataRow({
    required this.item,
    required this.onTap,
  });

  final JobWorkOrderListItem item;
  final VoidCallback onTap;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static const _dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closedDate = item.closedAt;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: DefaultTextStyle(
          style: _dataStyle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: _dateColWidth,
                  child: Text(
                    item.invoiceDate != null
                        ? _dateFormat.format(item.invoiceDate!)
                        : '—',
                  ),
                ),
                SizedBox(
                  width: _partyColWidth,
                  child: Text(
                    item.party,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: _jobIdColWidth,
                  child: Text(item.jobId.isEmpty ? '—' : item.jobId),
                ),
                SizedBox(
                  width: _deliveryColWidth,
                  child: Text(
                    item.deliveryDate != null
                        ? _dateFormat.format(item.deliveryDate!)
                        : '—',
                  ),
                ),
                SizedBox(
                  width: _statusColWidth,
                  child: Row(
                    children: [
                      JobWorkOutStatusBadge(status: item.status),
                      if (closedDate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _dateFormat.format(closedDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  width: _actionsColWidth,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.convertedInvoiceNumber != null)
                        Flexible(
                          child: Text(
                            'Converted to invoice No.${item.convertedInvoiceNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _convertLinkColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      JobWorkOutActionsMenuButton(item: item),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _XlsChip extends StatelessWidget {
  const _XlsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Text(
            'xls',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ),
    );
  }
}
