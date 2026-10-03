import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_document_actions.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_documents_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_documents_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopProformaInvoicePage extends ConsumerWidget {
  const DesktopProformaInvoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SalePageTitleBar(
              currentRoute: AppRoutes.saleProformaInvoice,
              addButtonLabel: 'Add Proforma',
              addButtonColor: AppColors.error,
              onAddTap: () => context.push(AppRoutes.addProforma),
            ),
            const SizedBox(height: AppSpacing.md),
            SalesDocumentsFilterBar(
              scope: proformaListScope(),
              onAdd: () => context.push(AppRoutes.addProforma),
              addButtonLabel: 'Create Proforma Invoice',
            ),
            const SizedBox(height: AppSpacing.md),
            SalesDocumentsTable(config: proformaTableConfig()),
          ],
        ),
      ),
    );
  }
}
