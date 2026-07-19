import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/text_input_dialog.dart';
import 'package:billing_baba/features/export/presentation/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:billing_baba/features/sales/application/sales_document_scope_permissions.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_document_actions.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_table_shared.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _dateColWidth = 100.0;
const _docNoColWidth = 110.0;
const _statusColWidth = 100.0;
const _amountColWidth = 100.0;
const _actionsColWidth = 96.0;

const double _minTableWidth =
    _dateColWidth +
    _docNoColWidth +
    _statusColWidth +
    _amountColWidth +
    _actionsColWidth +
    salesTableColGap * 4 +
    200;

class SalesDocumentsTable extends ConsumerWidget {
  const SalesDocumentsTable({
    required this.config,
    this.title = 'Transactions',
    super.key,
  });

  final SalesDocumentTableConfig config;
  final String title;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(salesDocumentsListProvider(config.scope));
    final paginated = ref.watch(paginatedSalesDocumentsProvider(config.scope));
    final notifier = ref.read(
      salesDocumentsListProvider(config.scope).notifier,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: salesCardBorder),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showSearchDialog(context, ref),
                  icon: const Icon(Icons.search, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Search',
                ),
                SalesXlsChip(
                  onTap: () => ModuleExportActions.exportSalesDocuments(
                    context,
                    ref,
                    config.scope,
                  ),
                ),
                IconButton(
                  onPressed: notifier.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: salesCardBorder),
          documentsAsync.when(
            skipLoadingOnReload: true,
            loading: () => const SalesLoadingState(),
            error: (error, _) => SalesErrorState(
              message: SalesErrorMapper.messageFor(error),
              onRetry: notifier.refresh,
            ),
            data: (_) {
              if (paginated.items.isEmpty) {
                return SalesEmptyListState(message: config.emptyMessage);
              }

              return LayoutBuilder(
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
                          const _HeaderRow(),
                          for (var i = 0; i < paginated.items.length; i++) ...[
                            if (i > 0)
                              const Divider(height: 1, color: salesCardBorder),
                            _buildRow(context, ref, paginated.items[i]),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const Divider(height: 1, color: salesCardBorder),
          SalesPaginationRow(scope: config.scope),
        ],
      ),
    );
  }

  Future<void> _showSearchDialog(BuildContext context, WidgetRef ref) async {
    final current = ref.read(salesDocumentSearchQueryProvider(config.scope));
    final query = await showTextSearchDialog(
      context,
      title: config.searchTitle,
      hint: config.searchHint,
      initialValue: current,
    );

    if (query == null) return;
    ref
        .read(salesDocumentSearchQueryProvider(config.scope).notifier)
        .setQuery(
          query,
        );
    ref.invalidate(salesDocumentsListProvider(config.scope));
  }

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel document,
  ) {
    final module = permissionModuleForScope(config.scope);
    final permissions = ref.watch(permissionServiceProvider);
    final menuActions = config.actions.where((action) {
      return switch (action) {
        SalesDocumentMenuAction.view => permissions.canView(module),
        SalesDocumentMenuAction.edit => permissions.canEdit(module),
        SalesDocumentMenuAction.duplicate => permissions.canCreate(module),
        SalesDocumentMenuAction.delete => permissions.canDelete(module),
        SalesDocumentMenuAction.convertToSaleOrder ||
        SalesDocumentMenuAction.convertToDeliveryChallan ||
        SalesDocumentMenuAction.convertToInvoice =>
          permissions.canCreate(module),
      };
    }).toList();

    return SalesTableDataRow(
      children: [
        SalesTableCell(
          width: _dateColWidth,
          child: Text(_dateFormat.format(document.date)),
        ),
        SalesTableCell(
          width: _docNoColWidth,
          child: Text(document.invoiceNo),
        ),
        Expanded(
          child: SalesTableCell(
            child: Text(
              document.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SalesTableCell(
          width: _statusColWidth,
          child: SalesDocumentLifecycleBadge(
            status: document.documentStatus,
          ),
        ),
        SalesTableCell(
          width: _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(document.amount)),
        ),
        SalesTableCell(
          width: _actionsColWidth,
          gapAfter: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  salesDocumentPrintRequest(config, document.id),
                  filename: DocumentPrintActions.filenameFor(
                    document.invoiceNo,
                  ),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Print',
              ),
              SalesActionMenuButton(
                items: [
                  for (final action in menuActions)
                    SalesActionMenuItem(
                      label: salesDocumentMenuActionLabel(action),
                      onSelected: () => handleSalesDocumentMenuAction(
                        context: context,
                        ref: ref,
                        config: config,
                        action: action,
                        document: document,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SalesTableHeaderCell(label: 'Date', width: _dateColWidth),
          SalesTableHeaderCell(label: 'Document No', width: _docNoColWidth),
          Expanded(child: SalesTableHeaderCell(label: 'Party Name')),
          SalesTableHeaderCell(label: 'Status', width: _statusColWidth),
          SalesTableHeaderCell(
            label: 'Amount',
            width: _amountColWidth,
            alignment: Alignment.centerRight,
          ),
          SalesTableHeaderCell(
            label: 'Actions',
            width: _actionsColWidth,
            gapAfter: 0,
          ),
        ],
      ),
    );
  }
}

class SalesDocumentLifecycleBadge extends StatelessWidget {
  const SalesDocumentLifecycleBadge({required this.status, super.key});

  final SalesDocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      SalesDocumentStatus.draft => (
        'Draft',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      SalesDocumentStatus.finalized => (
        'Finalized',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      SalesDocumentStatus.cancelled => (
        'Cancelled',
        const Color(0xFFF5F5F5),
        const Color(0xFF616161),
      ),
      SalesDocumentStatus.converted => (
        'Converted',
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
