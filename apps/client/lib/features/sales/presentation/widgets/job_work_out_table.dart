import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/job_work_out_dialog.dart';
import 'package:billing_baba/features/sales/providers/job_work_out_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _addJobWorkRed = Color(0xFFD32F2F);
const _statusOpenColor = Color(0xFF1565C0);
const _statusClosedColor = Color(0xFF616161);

const _dateColWidth = 120.0;
const _partyColWidth = 160.0;
const _jobIdColWidth = 120.0;
const _deliveryColWidth = 140.0;
const _statusColWidth = 120.0;
const _actionsColWidth = 80.0;

const _minTableWidth =
    _dateColWidth +
    _partyColWidth +
    _jobIdColWidth +
    _deliveryColWidth +
    _statusColWidth +
    _actionsColWidth +
    80;

class JobWorkOutTable extends ConsumerWidget {
  const JobWorkOutTable({super.key});

  Future<void> _openForm(BuildContext context, {SavedJobWorkOut? existing}) async {
    await showJobWorkOutDialog(context, existing: existing);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(savedJobWorkOutsProvider);

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
                FilledButton.icon(
                  onPressed: () => _openForm(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _addJobWorkRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Job Work Out',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
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
                            onTap: () => _openForm(context, existing: items[i]),
                            onDelete: () => ref
                                .read(savedJobWorkOutsProvider.notifier)
                                .removeJobWorkOut(items[i].id),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: const [
          SizedBox(width: _dateColWidth, child: Text('DATE', style: _headerStyle)),
          SizedBox(width: _partyColWidth, child: Text('PARTY', style: _headerStyle)),
          SizedBox(width: _jobIdColWidth, child: Text('JOB ID', style: _headerStyle)),
          SizedBox(
            width: _deliveryColWidth,
            child: Text('DELIVERY DATE', style: _headerStyle),
          ),
          SizedBox(width: _statusColWidth, child: Text('STATUS', style: _headerStyle)),
          SizedBox(width: _actionsColWidth, child: Text('ACTIONS', style: _headerStyle)),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final SavedJobWorkOut item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static const _dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final statusLabel =
        item.status == JobWorkOutStatus.open ? 'Open' : 'Closed';
    final statusColor =
        item.status == JobWorkOutStatus.open ? _statusOpenColor : _statusClosedColor;

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
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: _actionsColWidth,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: 'Delete',
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
