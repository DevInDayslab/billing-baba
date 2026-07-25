import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_order_table.dart';
import 'package:billing_baba/features/sales/application/sale_order_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sale Order list with optional inline form toggle (legacy).
class SaleOrderContent extends ConsumerWidget {
  const SaleOrderContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleOrderFormProvider());

    if (form.isFormOpen) {
      return const SizedBox.shrink();
    }

    return const SaleOrderTable();
  }
}
