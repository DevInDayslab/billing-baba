import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/members_provider.dart';
import 'package:billing_baba/features/crm/application/crm_assignee_options_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CrmOwnerSelectDropdown extends ConsumerWidget {
  const CrmOwnerSelectDropdown({
    required this.value,
    required this.onSelected,
    this.hintText = crmOwnerNoneOption,
    this.includeNoneOption = true,
    super.key,
  });

  final String value;
  final ValueChanged<String> onSelected;
  final String hintText;
  final bool includeNoneOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = includeNoneOption
        ? ref.watch(crmAssigneeFormOptionsProvider)
        : ref.watch(crmAssigneeNamesProvider);

    return optionsAsync.when(
      loading: () => AbsorbPointer(
        child: SaleGenericSelectDropdown(
          value: '',
          hintText: 'Loading owners...',
          options: const [],
          onSelected: (_) {},
        ),
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AbsorbPointer(
            child: SaleGenericSelectDropdown(
              value: '',
              hintText: 'Failed to load owners',
              options: const [],
              onSelected: (_) {},
              hasError: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => ref.invalidate(membersProvider),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
      data: (options) {
        final resolvedOptions = includeNoneOption
            ? options
            : (options.isEmpty ? <String>[] : options);
        final resolvedValue = resolvedOptions.contains(value)
            ? value
            : (includeNoneOption
                  ? crmOwnerNoneOption
                  : (resolvedOptions.isNotEmpty ? resolvedOptions.first : ''));

        return SaleGenericSelectDropdown(
          value: resolvedValue,
          hintText: hintText,
          options: resolvedOptions.isEmpty
              ? (includeNoneOption ? const [crmOwnerNoneOption] : const [])
              : resolvedOptions,
          onSelected: onSelected,
        );
      },
    );
  }
}
