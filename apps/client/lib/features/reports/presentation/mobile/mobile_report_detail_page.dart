import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/shared/chart/chart_axis_formatters.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum MobileReportDetailType {
  partyOutstanding,
  stockSummary,
  dayBook,
  profitLoss,
  gstr1,
}

class MobileReportDetailPage extends ConsumerWidget {
  const MobileReportDetailPage({
    required this.type,
    super.key,
  });

  final MobileReportDetailType type;

  String get _title => switch (type) {
    MobileReportDetailType.partyOutstanding => 'Party outstanding',
    MobileReportDetailType.stockSummary => 'Stock summary',
    MobileReportDetailType.dayBook => 'Day book',
    MobileReportDetailType.profitLoss => 'Profit & loss',
    MobileReportDetailType.gstr1 => 'GSTR-1',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: _title,
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: switch (type) {
        MobileReportDetailType.partyOutstanding => _PartyOutstandingBody(
          onRetry: () => ref.invalidate(partyOutstandingReportProvider),
        ),
        MobileReportDetailType.stockSummary => _StockSummaryBody(
          onRetry: () => ref.invalidate(stockSummaryReportProvider),
        ),
        MobileReportDetailType.dayBook => _DayBookBody(
          onRetry: () => ref.invalidate(dayBookReportProvider),
        ),
        MobileReportDetailType.profitLoss => _ProfitLossBody(
          onRetry: () => ref.invalidate(profitLossReportProvider),
        ),
        MobileReportDetailType.gstr1 => _Gstr1Body(
          onRetry: () => ref.invalidate(gstr1ReportProvider),
        ),
      },
    );
  }
}

class _PartyOutstandingBody extends ConsumerWidget {
  const _PartyOutstandingBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(partyOutstandingReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppError(
        message: OfflineUiMessages.messageFor(error),
        onRetry: onRetry,
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SummaryCard(
            title: 'Receivable',
            value: ChartAxisFormatters.formatCurrency(data.totalReceivable),
            subtitle: '${data.receivablePartyCount} parties',
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryCard(
            title: 'Payable',
            value: ChartAxisFormatters.formatCurrency(data.totalPayable),
            subtitle: '${data.payablePartyCount} parties',
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final party in data.rows.take(50))
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(party.name),
                trailing: Text(
                  ChartAxisFormatters.formatCurrency(party.balance),
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StockSummaryBody extends ConsumerWidget {
  const _StockSummaryBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(stockSummaryReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppError(
        message: OfflineUiMessages.messageFor(error),
        onRetry: onRetry,
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SummaryCard(
            title: 'Total stock value',
            value: ChartAxisFormatters.formatCurrency(data.totalStockValue),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final row in data.rows.take(50))
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(row.itemName),
                subtitle: Text('Qty ${row.stockQty}'),
                trailing: Text(
                  ChartAxisFormatters.formatCurrency(row.stockValue),
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayBookBody extends ConsumerWidget {
  const _DayBookBody({required this.onRetry});

  final VoidCallback onRetry;
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(dayBookReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppError(
        message: OfflineUiMessages.messageFor(error),
        onRetry: onRetry,
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SummaryCard(
            title: 'Net total',
            value: ChartAxisFormatters.formatCurrency(data.netTotal),
            subtitle:
                'In ${ChartAxisFormatters.formatCurrency(data.totalMoneyIn)} · Out ${ChartAxisFormatters.formatCurrency(data.totalMoneyOut)}',
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final row in data.rows.take(50))
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(row.partyName),
                subtitle: Text(
                  '${_dateFormat.format(row.date)} · ${row.type}',
                ),
                trailing: Text(
                  ChartAxisFormatters.formatCurrency(row.total),
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfitLossBody extends ConsumerWidget {
  const _ProfitLossBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(profitLossReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppError(
        message: OfflineUiMessages.messageFor(error),
        onRetry: onRetry,
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SummaryCard(
            title: 'Net profit',
            value: ChartAxisFormatters.formatCurrency(data.netProfit),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final item in data.items)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(
                  item.particular,
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySize,
                    fontWeight: item.isHeader
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                trailing: item.isHeader
                    ? null
                    : Text(
                        ChartAxisFormatters.formatCurrency(item.amount),
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Gstr1Body extends ConsumerWidget {
  const _Gstr1Body({required this.onRetry});

  final VoidCallback onRetry;
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(gstr1ReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppError(
        message: OfflineUiMessages.messageFor(error),
        onRetry: onRetry,
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          for (final row in data.rows.take(50))
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(row.partyName),
                subtitle: Text(
                  '${row.invoiceNo} · ${_dateFormat.format(row.date)}',
                ),
                trailing: Text(
                  ChartAxisFormatters.formatCurrency(row.value),
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTypography.inter(
                  fontSize: AppTypography.captionSize,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
