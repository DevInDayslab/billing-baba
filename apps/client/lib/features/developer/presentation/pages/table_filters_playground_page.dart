import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';

/// Interactive playground and documentation for every reusable table filter.
class TableFiltersPlaygroundPage extends StatefulWidget {
  const TableFiltersPlaygroundPage({super.key});

  @override
  State<TableFiltersPlaygroundPage> createState() =>
      _TableFiltersPlaygroundPageState();
}

class _TableFiltersPlaygroundPageState
    extends State<TableFiltersPlaygroundPage> {
  late final FilterController _controller = FilterController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(String id, FilterResult? result) {
    _controller.apply(id, result);
  }

  Object? _valueFor(ColumnFilter config) {
    return FilterUtils.fromResult(_controller.filters[config.id]);
  }

  String _valueLabel(ColumnFilter config) {
    final result = _controller.filters[config.id];
    if (result == null || !result.isActive) return '(none)';
    return result.displayLabel;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final configs = FilterWidgetSpecs.all.map((s) => s.config).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'Table Filters',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Live playground and reference for the canonical filter widgets. '
                'Every module must compose from these primitives only.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle('Filter type reference'),
              const SizedBox(height: AppSpacing.sm),
              _ReferenceTable(),
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle('All filter widgets'),
              const SizedBox(height: AppSpacing.sm),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1200
                      ? 3
                      : constraints.maxWidth >= 760
                      ? 2
                      : 1;

                  final specs = [
                    ...FilterWidgetSpecs.all,
                    const FilterWidgetSpec(
                      name: 'Disabled example',
                      widgetClass: 'TextFilterWidget',
                      typeLabel: 'Text Filter',
                      operators: ['Contains', 'Exact Match'],
                      usedIn: ['—'],
                      exampleFields: ['—'],
                      config: ColumnFilter(
                        id: 'disabled',
                        title: 'Disabled',
                        type: FilterType.text,
                        disabled: true,
                      ),
                    ),
                  ];

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 340,
                    ),
                    itemCount: specs.length,
                    itemBuilder: (context, index) {
                      final spec = specs[index];
                      return _FilterDemoCard(
                        spec: spec,
                        initialValue: _valueFor(spec.config),
                        currentValueLabel: _valueLabel(spec.config),
                        onApply: (result) => _apply(spec.config.id, result),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                _controller.hasActiveFilters ? 'Active filters' : 'Empty state',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_controller.hasActiveFilters)
                ActiveFilterChips(
                  filters: _controller.filters,
                  configs: configs,
                  onRemove: _controller.removeFilter,
                  onClearAll: _controller.clearAll,
                )
              else
                const Text(
                  'No active filters — open a filter above and click Apply.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ReferenceTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: TableFilterTheme.popoverBorder),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          const TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TableFilterTheme.popoverBorder),
              ),
            ),
            children: [
              _TableHead('Widget'),
              _TableHead('Purpose'),
              _TableHead('Used In'),
            ],
          ),
          for (final row in FilterWidgetSpecs.referenceTable)
            TableRow(
              children: [
                _TableCell(row.$1, monospace: true),
                _TableCell(row.$2),
                _TableCell(row.$3),
              ],
            ),
        ],
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  const _TableHead(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.text, {this.monospace = false});
  final String text;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontFamily: monospace ? 'monospace' : null,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _FilterDemoCard extends StatelessWidget {
  const _FilterDemoCard({
    required this.spec,
    required this.initialValue,
    required this.currentValueLabel,
    required this.onApply,
  });

  final FilterWidgetSpec spec;
  final Object? initialValue;
  final String currentValueLabel;
  final ValueChanged<FilterResult?> onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: TableFilterTheme.popoverBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            spec.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(label: 'Widget', value: spec.widgetClass),
                  _MetaRow(label: 'Type', value: spec.typeLabel),
                  _MetaRow(
                    label: 'Operators',
                    value: spec.operators.join(', '),
                  ),
                  _MetaRow(label: 'Used In', value: spec.usedIn.join(', ')),
                  _MetaRow(
                    label: 'Example fields',
                    value: spec.exampleFields.join(', '),
                  ),
                  _MetaRow(
                    label: 'Current value',
                    value: currentValueLabel,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TableColumnFilterTrigger(
            config: spec.config,
            initialValue: initialValue,
            onApply: onApply,
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
