import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/lead_error_mapper.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/services/lead_service_types.dart';
import 'package:billing_baba/features/crm/presentation/providers/leads_provider.dart';
import 'package:billing_baba/features/crm/presentation/providers/leads_selection_providers.dart';
import 'package:billing_baba/features/crm/presentation/widgets/add_lead_dialog.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _addLeadRed = Color(0xFFE53935);
const _filterChipBg = Color(0xFFEAF2FB);
const _filterChipBorder = Color(0xFFD6E6F5);
const _filterBarBorder = Color(0xFFE0E0E0);
const _cardBorder = Color(0xFFE0E0E0);
const _rowHoverColor = Color(0xFFF5F5F5);
const _filterPanelWidth = 280.0;
const _filterOverlayBreakpoint = 1180.0;
const _compactBreakpoint = 720.0;
const _rowHeight = 56.0;
const _checkboxColWidth = 48.0;
const _manageColumnsColWidth = 40.0;
const _menuHoverColor = Color(0xFFE3F2FD);
const _menuMinWidth = 200.0;

enum _LeadColumnId { name, company, email, phone, source }

class _ColumnDef {
  const _ColumnDef({
    required this.id,
    required this.label,
    required this.flex,
    required this.fieldKey,
  });

  final _LeadColumnId id;
  final String label;
  final int flex;
  final String fieldKey;

  bool get isRequired => id == _LeadColumnId.name;

  String get manageLabel => switch (id) {
    _LeadColumnId.name => 'Lead Name',
    _LeadColumnId.company => 'Company',
    _LeadColumnId.email => 'Email',
    _LeadColumnId.phone => 'Phone',
    _LeadColumnId.source => 'Lead Source',
  };
}

const _allColumns = [
  _ColumnDef(
    id: _LeadColumnId.name,
    label: 'LEAD NAME',
    flex: 2,
    fieldKey: 'name',
  ),
  _ColumnDef(
    id: _LeadColumnId.company,
    label: 'COMPANY',
    flex: 2,
    fieldKey: 'company',
  ),
  _ColumnDef(
    id: _LeadColumnId.email,
    label: 'EMAIL',
    flex: 2,
    fieldKey: 'email',
  ),
  _ColumnDef(
    id: _LeadColumnId.phone,
    label: 'PHONE',
    flex: 3,
    fieldKey: 'phone',
  ),
  _ColumnDef(
    id: _LeadColumnId.source,
    label: 'LEAD SOURCE',
    flex: 3,
    fieldKey: 'source',
  ),
];

const _systemFilterOptions = [
  'Activities',
  'Cadences',
  'Campaigns',
  'Latest Email Status',
  'Locked',
  'Record Action',
  'Notes',
  'Tasks',
];

const _fieldFilterOptions = [
  'Lead Name',
  'Company',
  'Email',
  'Phone',
  'Lead Source',
  'Status',
];

const _sourceOptions = [
  'Google Ads',
  'Referral',
  'Website',
  'Walk-in',
];

const _statusOptions = [
  'New',
  'Contacted',
  'Qualified',
  'Converted',
  'Lost',
];

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  final Set<String> _selectedLeadKeys = {};

  bool _filterPanelOpen = true;
  String _panelSearchQuery = '';
  final Set<String> _systemFilters = {};
  final Set<String> _activeFieldFilters = {};
  final Map<String, Set<String>> _fieldFilterValues = {};

  final Set<_LeadColumnId> _hiddenColumns = {};
  final Set<_LeadColumnId> _pinnedColumns = {};
  _LeadColumnId? _sortColumn;
  bool _sortAscending = true;
  final Map<_LeadColumnId, String> _columnTextFilters = {};
  final Map<_LeadColumnId, Set<String>> _columnValueFilters = {};

  String _leadKey(Lead lead) => lead.id;

  String _leadFieldValue(Lead lead, _ColumnDef column) {
    return switch (column.id) {
      _LeadColumnId.name => lead.name,
      _LeadColumnId.company => lead.displayCompany,
      _LeadColumnId.email => lead.displayEmail,
      _LeadColumnId.phone => lead.displayPhone,
      _LeadColumnId.source => lead.displayLeadSource,
    };
  }

  bool get _hasActiveLocalFilters =>
      _systemFilters.isNotEmpty ||
      _activeFieldFilters.isNotEmpty ||
      _columnTextFilters.values.any((value) => value.trim().isNotEmpty) ||
      _columnValueFilters.values.any((values) => values.isNotEmpty);

  Future<void> _saveLead(AddLeadInput input) async {
    try {
      await ref.read(leadsProvider.notifier).addLead(input);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lead "${input.name}" saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LeadErrorMapper.messageFor(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openAddLeadDialog() async {
    final input = await showAddLeadDialog(
      context,
      onSaveAndNew: _saveLead,
    );
    if (!mounted || input == null) return;
    await _saveLead(input);
  }

  Future<void> _deleteSelectedLeads() async {
    if (_selectedLeadKeys.isEmpty) return;

    final count = _selectedLeadKeys.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(count == 1 ? 'Delete lead?' : 'Delete $count leads?'),
        content: Text(
          count == 1
              ? 'Are you sure you want to delete the selected lead?'
              : 'Are you sure you want to delete the selected leads?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final notifier = ref.read(leadsProvider.notifier);
      for (final leadId in _selectedLeadKeys.toList()) {
        await notifier.deleteLead(leadId);
      }
      if (!mounted) return;
      setState(() => _selectedLeadKeys.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 1
                ? 'Lead deleted successfully'
                : '$count leads deleted successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LeadErrorMapper.messageFor(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<_ColumnDef> get _visibleColumns {
    final visible = _allColumns
        .where((column) => !_hiddenColumns.contains(column.id))
        .toList();
    visible.sort((a, b) {
      final aPinned = _pinnedColumns.contains(a.id);
      final bPinned = _pinnedColumns.contains(b.id);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return _allColumns.indexOf(a).compareTo(_allColumns.indexOf(b));
    });
    return visible;
  }

  List<Lead> _applyLocalFilters(List<Lead> source) {
    var results = List<Lead>.from(source);

    if (_systemFilters.contains('Activities')) {
      results = results
          .where(
            (lead) =>
                lead.status == LeadStatus.contacted ||
                lead.status == LeadStatus.qualified,
          )
          .toList();
    }
    if (_systemFilters.contains('Tasks')) {
      results = results
          .where((lead) => lead.status == LeadStatus.newLead)
          .toList();
    }
    if (_systemFilters.contains('Locked')) {
      results = results
          .where((lead) => lead.status == LeadStatus.lost)
          .toList();
    }

    if (_activeFieldFilters.contains('Status') &&
        (_fieldFilterValues['Status']?.isNotEmpty ?? false)) {
      results = results
          .where(
            (lead) => _fieldFilterValues['Status']!.contains(lead.status.label),
          )
          .toList();
    }
    if (_activeFieldFilters.contains('Lead Source') &&
        (_fieldFilterValues['Lead Source']?.isNotEmpty ?? false)) {
      results = results
          .where(
            (lead) => _fieldFilterValues['Lead Source']!.contains(
              lead.displayLeadSource,
            ),
          )
          .toList();
    }
    if (_activeFieldFilters.contains('Company')) {
      results = results.where((lead) => lead.displayCompany != '—').toList();
    }

    for (final column in _allColumns) {
      final textFilter = _columnTextFilters[column.id]?.trim().toLowerCase();
      if (textFilter != null && textFilter.isNotEmpty) {
        results = results.where((lead) {
          final value = _leadFieldValue(lead, column).toLowerCase();
          if (column.id == _LeadColumnId.name) {
            final status = lead.status.label.toLowerCase();
            return value.contains(textFilter) || status.contains(textFilter);
          }
          return value.contains(textFilter);
        }).toList();
      }

      final valueFilter = _columnValueFilters[column.id];
      if (valueFilter != null && valueFilter.isNotEmpty) {
        results = results.where((lead) {
          if (column.id == _LeadColumnId.name) {
            return valueFilter.contains(lead.status.label);
          }
          return valueFilter.contains(_leadFieldValue(lead, column));
        }).toList();
      }
    }

    if (_sortColumn != null) {
      final column = _allColumns.firstWhere((c) => c.id == _sortColumn);
      results.sort((a, b) {
        final left = _leadFieldValue(a, column).toLowerCase();
        final right = _leadFieldValue(b, column).toLowerCase();
        final comparison = left.compareTo(right);
        return _sortAscending ? comparison : -comparison;
      });
    }

    return results;
  }

  void _sortByColumn(_LeadColumnId column, {required bool ascending}) {
    setState(() {
      _sortColumn = column;
      _sortAscending = ascending;
    });
  }

  void _toggleSortColumn(_LeadColumnId column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  void _togglePinColumn(_LeadColumnId column) {
    setState(() {
      if (_pinnedColumns.contains(column)) {
        _pinnedColumns.remove(column);
      } else {
        _pinnedColumns.add(column);
      }
    });
  }

  void _hideColumn(_LeadColumnId column) {
    if (_allColumns.firstWhere((c) => c.id == column).isRequired) return;
    setState(() => _hiddenColumns.add(column));
  }

  Future<void> _showManageColumnsDialog() async {
    final result = await showDialog<Set<_LeadColumnId>>(
      context: context,
      builder: (context) => _ManageColumnsDialog(
        hiddenColumns: _hiddenColumns,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _hiddenColumns
        ..clear()
        ..addAll(
          _allColumns
              .where((column) => !result.contains(column.id))
              .map((column) => column.id),
        );
    });
  }

  Future<void> _showColumnFilterDialog(_ColumnDef column) async {
    if (column.id == _LeadColumnId.source) {
      await _showValueFilterDialog(
        title: 'Filter by ${column.label}',
        options: _sourceOptions,
        selected: Set<String>.from(
          _columnValueFilters[column.id] ?? const {},
        ),
        onApply: (values) {
          setState(() {
            if (values.isEmpty) {
              _columnValueFilters.remove(column.id);
            } else {
              _columnValueFilters[column.id] = values;
            }
          });
        },
      );
      return;
    }

    if (column.id == _LeadColumnId.name) {
      await _showValueFilterDialog(
        title: 'Filter by Status',
        options: _statusOptions,
        selected: Set<String>.from(
          _columnValueFilters[column.id] ?? const {},
        ),
        onApply: (values) {
          setState(() {
            if (values.isEmpty) {
              _columnValueFilters.remove(column.id);
            } else {
              _columnValueFilters[column.id] = values;
            }
          });
        },
      );
      return;
    }

    final controller = TextEditingController(
      text: _columnTextFilters[column.id] ?? '',
    );
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter by ${column.label}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Contains...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      final trimmed = result.trim();
      if (trimmed.isEmpty) {
        _columnTextFilters.remove(column.id);
      } else {
        _columnTextFilters[column.id] = trimmed;
      }
    });
  }

  Future<void> _showValueFilterDialog({
    required String title,
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<Set<String>> onApply,
  }) async {
    final working = Set<String>.from(selected);
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final option in options)
                    CheckboxListTile(
                      value: working.contains(option),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            working.add(option);
                          } else {
                            working.remove(option);
                          }
                        });
                      },
                      title: Text(option),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onApply({});
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  onApply(working);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _columnHasActiveFilter(_LeadColumnId id) {
    final text = _columnTextFilters[id]?.trim();
    final values = _columnValueFilters[id];
    return (text != null && text.isNotEmpty) ||
        (values != null && values.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsProvider);
    final paginated = ref.watch(paginatedLeadsProvider);
    final filters = ref.watch(leadFiltersProvider);
    final filtersNotifier = ref.read(leadFiltersProvider.notifier);
    final sortedLeads = ref.watch(sortedLeadsListProvider);
    final locallyFiltered = _applyLocalFilters(sortedLeads);
    final tableLeads = _hasActiveLocalFilters
        ? locallyFiltered
        : paginated.items;
    final tablePagination = _hasActiveLocalFilters
        ? PaginatedLeads(
            items: locallyFiltered,
            currentPage: 1,
            totalPages: 1,
            totalItems: locallyFiltered.length,
            rangeStart: locallyFiltered.isEmpty ? 0 : 1,
            rangeEnd: locallyFiltered.length,
          )
        : paginated;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < _compactBreakpoint;
            final useFilterOverlay =
                constraints.maxWidth < _filterOverlayBreakpoint;
            final pagePadding = isCompact ? AppSpacing.sm : AppSpacing.md;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pagePadding),
                    child: _LeadsTitleBar(
                      onAddLead: _openAddLeadDialog,
                      onDelete: _selectedLeadKeys.isEmpty
                          ? null
                          : _deleteSelectedLeads,
                      selectedCount: _selectedLeadKeys.length,
                      isCompact: isCompact,
                    ),
                  ),
                  SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pagePadding),
                    child: _LeadsFilterBar(
                      statusLabel: filters.statusLabel,
                      sourceLabel: filters.leadSourceLabel,
                      onStatusSelected: (value) {
                        filtersNotifier.setStatus(
                          value == 'All Status'
                              ? null
                              : LeadStatusX.fromWire(value.toLowerCase()),
                        );
                      },
                      onSourceSelected: (value) {
                        filtersNotifier.setLeadSource(
                          value == 'All Source'
                              ? null
                              : _leadSourceFromFilterLabel(value),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: leadsAsync.when(
                      skipLoadingOnReload: true,
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(LeadErrorMapper.messageFor(error)),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () =>
                                  ref.read(leadsProvider.notifier).refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                      data: (_) => _buildMainContent(
                        leads: tableLeads,
                        pagination: tablePagination,
                        onPageChanged: filtersNotifier.setPage,
                        useFilterOverlay: useFilterOverlay,
                        maxWidth: constraints.maxWidth,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  LeadSource? _leadSourceFromFilterLabel(String value) {
    for (final source in LeadSource.values) {
      if (source.label == value) return source;
    }
    return LeadSource.other;
  }

  Widget _buildMainContent({
    required List<Lead> leads,
    required PaginatedLeads pagination,
    required ValueChanged<int> onPageChanged,
    required bool useFilterOverlay,
    required double maxWidth,
  }) {
    final table = _LeadsTableCard(
      visibleColumns: _visibleColumns,
      leads: leads,
      pagination: pagination,
      onPageChanged: onPageChanged,
      selectedLeadKeys: _selectedLeadKeys,
      sortColumn: _sortColumn,
      sortAscending: _sortAscending,
      pinnedColumns: _pinnedColumns,
      columnHasFilter: _columnHasActiveFilter,
      filterPanelOpen: _filterPanelOpen,
      onToggleFilterPanel: () =>
          setState(() => _filterPanelOpen = !_filterPanelOpen),
      onSort: _sortByColumn,
      onSortToggle: _toggleSortColumn,
      onPin: _togglePinColumn,
      onHide: _hideColumn,
      onFilterBy: _showColumnFilterDialog,
      onManageColumns: _showManageColumnsDialog,
      onToggleRow: (key) {
        setState(() {
          if (_selectedLeadKeys.contains(key)) {
            _selectedLeadKeys.remove(key);
          } else {
            _selectedLeadKeys.add(key);
          }
        });
      },
      onToggleAll: () {
        setState(() {
          final keys = leads.map(_leadKey).toSet();
          if (keys.every(_selectedLeadKeys.contains)) {
            _selectedLeadKeys.removeAll(keys);
          } else {
            _selectedLeadKeys.addAll(keys);
          }
        });
      },
      leadKey: _leadKey,
    );

    final filterPanel = _LeadsFilterSidePanel(
      searchQuery: _panelSearchQuery,
      systemFilters: _systemFilters,
      activeFieldFilters: _activeFieldFilters,
      fieldFilterValues: _fieldFilterValues,
      onSearchChanged: (value) => setState(() => _panelSearchQuery = value),
      onSystemFilterToggle: (filter) {
        setState(() {
          if (_systemFilters.contains(filter)) {
            _systemFilters.remove(filter);
          } else {
            _systemFilters.add(filter);
          }
        });
      },
      onFieldFilterToggle: (field) {
        setState(() {
          if (_activeFieldFilters.contains(field)) {
            _activeFieldFilters.remove(field);
            _fieldFilterValues.remove(field);
          } else {
            _activeFieldFilters.add(field);
          }
        });
      },
      onFieldValueToggle: (field, value) {
        setState(() {
          final current = _fieldFilterValues[field] ?? {};
          final next = Set<String>.from(current);
          if (next.contains(value)) {
            next.remove(value);
          } else {
            next.add(value);
          }
          if (next.isEmpty) {
            _fieldFilterValues.remove(field);
          } else {
            _fieldFilterValues[field] = next;
          }
        });
      },
      onClose: useFilterOverlay && _filterPanelOpen
          ? () => setState(() => _filterPanelOpen = false)
          : null,
      width: math.min(_filterPanelWidth, maxWidth * 0.9),
    );

    if (useFilterOverlay) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          table,
          if (_filterPanelOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _filterPanelOpen = false),
                child: Container(color: Colors.black.withValues(alpha: 0.18)),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: filterPanel,
            ),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_filterPanelOpen) filterPanel,
        Expanded(child: table),
      ],
    );
  }
}

class _LeadsFilterSidePanel extends StatelessWidget {
  const _LeadsFilterSidePanel({
    required this.searchQuery,
    required this.systemFilters,
    required this.activeFieldFilters,
    required this.fieldFilterValues,
    required this.onSearchChanged,
    required this.onSystemFilterToggle,
    required this.onFieldFilterToggle,
    required this.onFieldValueToggle,
    this.onClose,
    this.width = _filterPanelWidth,
  });

  final String searchQuery;
  final Set<String> systemFilters;
  final Set<String> activeFieldFilters;
  final Map<String, Set<String>> fieldFilterValues;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSystemFilterToggle;
  final ValueChanged<String> onFieldFilterToggle;
  final void Function(String field, String value) onFieldValueToggle;
  final VoidCallback? onClose;
  final double width;

  List<String> _filterList(List<String> options) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return options;
    return options
        .where((option) => option.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final systemOptions = _filterList(_systemFilterOptions);
    final fieldOptions = _filterList(_fieldFilterOptions);

    return Container(
      width: width,
      margin: EdgeInsets.only(right: onClose == null ? AppSpacing.md : 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
        boxShadow: onClose != null
            ? const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(2, 0),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filter Leads by',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 18),
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: 'Close filters',
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search',
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(color: _cardBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                const _FilterSectionHeader(label: 'System Defined Filters'),
                for (final option in systemOptions)
                  _FilterCheckboxTile(
                    label: option,
                    checked: systemFilters.contains(option),
                    onChanged: () => onSystemFilterToggle(option),
                  ),
                const SizedBox(height: AppSpacing.sm),
                const _FilterSectionHeader(label: 'Filter By Fields'),
                for (final option in fieldOptions) ...[
                  _FilterCheckboxTile(
                    label: option,
                    checked: activeFieldFilters.contains(option),
                    onChanged: () => onFieldFilterToggle(option),
                  ),
                  if (activeFieldFilters.contains(option) &&
                      option == 'Lead Source')
                    for (final value in _sourceOptions)
                      _FilterSubOptionTile(
                        label: value,
                        checked:
                            fieldFilterValues['Lead Source']?.contains(value) ??
                            false,
                        onChanged: () =>
                            onFieldValueToggle('Lead Source', value),
                      ),
                  if (activeFieldFilters.contains(option) && option == 'Status')
                    for (final value in _statusOptions)
                      _FilterSubOptionTile(
                        label: value,
                        checked:
                            fieldFilterValues['Status']?.contains(value) ??
                            false,
                        onChanged: () => onFieldValueToggle('Status', value),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSectionHeader extends StatelessWidget {
  const _FilterSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _FilterCheckboxTile extends StatelessWidget {
  const _FilterCheckboxTile({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: checked,
                onChanged: (_) => onChanged(),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSubOptionTile extends StatelessWidget {
  const _FilterSubOptionTile({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      child: _FilterCheckboxTile(
        label: label,
        checked: checked,
        onChanged: onChanged,
      ),
    );
  }
}

class _LeadsTitleBar extends StatelessWidget {
  const _LeadsTitleBar({
    required this.onAddLead,
    this.onDelete,
    this.selectedCount = 0,
    this.isCompact = false,
  });

  final VoidCallback onAddLead;
  final VoidCallback? onDelete;
  final int selectedCount;
  final bool isCompact;

  static const _titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final actionButtons = [
      if (!isCompact)
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh),
          color: AppColors.textSecondary,
          tooltip: 'Refresh',
        ),
      if (!isCompact)
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textSecondary,
          tooltip: 'Settings',
        ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert),
        color: AppColors.textSecondary,
        tooltip: 'More options',
      ),
    ];

    final deleteButton = onDelete == null
        ? null
        : OutlinedButton.icon(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: _addLeadRed,
              side: const BorderSide(color: _addLeadRed),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              minimumSize: const Size(0, 42),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.delete_outline, size: 20),
            label: Text(
              selectedCount > 1 ? 'Delete ($selectedCount)' : 'Delete',
            ),
          );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Leads', style: _titleStyle)),
              ...actionButtons,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (deleteButton != null) ...[
            SizedBox(width: double.infinity, child: deleteButton),
            const SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAddLead,
              style: _addLeadButtonStyle,
              icon: const Icon(Icons.add, size: 22),
              label: const Text('Add Lead'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Expanded(child: Text('Leads', style: _titleStyle)),
        if (deleteButton != null) ...[
          deleteButton,
          const SizedBox(width: AppSpacing.sm),
        ],
        FilledButton.icon(
          onPressed: onAddLead,
          style: _addLeadButtonStyle,
          icon: const Icon(Icons.add, size: 22),
          label: const Text('Add Lead'),
        ),
        ...actionButtons,
      ],
    );
  }

  static ButtonStyle get _addLeadButtonStyle => FilledButton.styleFrom(
    backgroundColor: _addLeadRed,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    minimumSize: const Size(0, 42),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _LeadsFilterBar extends StatelessWidget {
  const _LeadsFilterBar({
    required this.statusLabel,
    required this.sourceLabel,
    required this.onStatusSelected,
    required this.onSourceSelected,
  });

  final String statusLabel;
  final String sourceLabel;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<String> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _filterBarBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Filter by :',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SaleFilterDropdown(
              label: statusLabel,
              chipBackgroundColor: _filterChipBg,
              chipBorderColor: _filterChipBorder,
              options: const [
                'All Status',
                'New',
                'Contacted',
                'Qualified',
                'Converted',
                'Lost',
              ],
              selected: statusLabel,
              onSelected: onStatusSelected,
            ),
            SaleFilterDropdown(
              label: sourceLabel,
              chipBackgroundColor: _filterChipBg,
              chipBorderColor: _filterChipBorder,
              options: const [
                'All Source',
                'Google Ads',
                'Referral',
                'Website',
                'Walk-in',
              ],
              selected: sourceLabel,
              onSelected: onSourceSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadsTableCard extends StatelessWidget {
  const _LeadsTableCard({
    required this.visibleColumns,
    required this.leads,
    required this.pagination,
    required this.onPageChanged,
    required this.selectedLeadKeys,
    required this.sortColumn,
    required this.sortAscending,
    required this.pinnedColumns,
    required this.columnHasFilter,
    required this.filterPanelOpen,
    required this.onToggleFilterPanel,
    required this.onSort,
    required this.onSortToggle,
    required this.onPin,
    required this.onHide,
    required this.onFilterBy,
    required this.onManageColumns,
    required this.onToggleRow,
    required this.onToggleAll,
    required this.leadKey,
  });

  final List<_ColumnDef> visibleColumns;
  final List<Lead> leads;
  final PaginatedLeads pagination;
  final ValueChanged<int> onPageChanged;
  final Set<String> selectedLeadKeys;
  final _LeadColumnId? sortColumn;
  final bool sortAscending;
  final Set<_LeadColumnId> pinnedColumns;
  final bool Function(_LeadColumnId id) columnHasFilter;
  final bool filterPanelOpen;
  final VoidCallback onToggleFilterPanel;
  final void Function(_LeadColumnId column, {required bool ascending}) onSort;
  final ValueChanged<_LeadColumnId> onSortToggle;
  final ValueChanged<_LeadColumnId> onPin;
  final ValueChanged<_LeadColumnId> onHide;
  final ValueChanged<_ColumnDef> onFilterBy;
  final VoidCallback onManageColumns;
  final ValueChanged<String> onToggleRow;
  final VoidCallback onToggleAll;
  final String Function(Lead lead) leadKey;

  static const _tableMinWidth = 860.0;

  @override
  Widget build(BuildContext context) {
    final keys = leads.map(leadKey).toList();
    final allSelected =
        keys.isNotEmpty && keys.every(selectedLeadKeys.contains);
    final someSelected = keys.any(selectedLeadKeys.contains) && !allSelected;
    final headerCheckboxValue = allSelected
        ? true
        : (someSelected ? null : false);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LeadsTableToolbar(
            filterPanelOpen: filterPanelOpen,
            onToggleFilterPanel: onToggleFilterPanel,
          ),
          const Divider(height: 1, color: _cardBorder),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = math.max(
                  constraints.maxWidth,
                  _tableMinWidth,
                );

                final header = SizedBox(
                  width: tableWidth,
                  child: _LeadsTableHeaderRow(
                    visibleColumns: visibleColumns,
                    checkboxValue: headerCheckboxValue,
                    sortColumn: sortColumn,
                    sortAscending: sortAscending,
                    pinnedColumns: pinnedColumns,
                    columnHasFilter: columnHasFilter,
                    onToggleAll: onToggleAll,
                    onSort: onSort,
                    onSortToggle: onSortToggle,
                    onPin: onPin,
                    onHide: onHide,
                    onFilterBy: onFilterBy,
                    onManageColumns: onManageColumns,
                  ),
                );

                Widget tableBody;
                if (leads.isEmpty) {
                  tableBody = const _LeadsEmptyState();
                } else {
                  tableBody = ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: leads.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: _cardBorder),
                    itemBuilder: (context, index) => _LeadDataRow(
                      lead: leads[index],
                      leadKey: leadKey(leads[index]),
                      visibleColumns: visibleColumns,
                      isSelected: selectedLeadKeys.contains(
                        leadKey(leads[index]),
                      ),
                      onToggle: () => onToggleRow(leadKey(leads[index])),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: header,
                    ),
                    const Divider(height: 1, color: _cardBorder),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: tableWidth,
                          child: tableBody,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          _LeadsPaginationFooter(
            pagination: pagination,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}

class _LeadsTableToolbar extends StatelessWidget {
  const _LeadsTableToolbar({
    required this.filterPanelOpen,
    required this.onToggleFilterPanel,
  });

  final bool filterPanelOpen;
  final VoidCallback onToggleFilterPanel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _ToolbarIconButton(
            icon: Icons.filter_list,
            label: 'Filter',
            isActive: filterPanelOpen,
            onPressed: onToggleFilterPanel,
          ),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE3F2FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isActive ? const Color(0xFF90CAF9) : _cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadsTableHeaderRow extends StatelessWidget {
  const _LeadsTableHeaderRow({
    required this.visibleColumns,
    required this.checkboxValue,
    required this.sortColumn,
    required this.sortAscending,
    required this.pinnedColumns,
    required this.columnHasFilter,
    required this.onToggleAll,
    required this.onSort,
    required this.onSortToggle,
    required this.onPin,
    required this.onHide,
    required this.onFilterBy,
    required this.onManageColumns,
  });

  final List<_ColumnDef> visibleColumns;
  final bool? checkboxValue;
  final _LeadColumnId? sortColumn;
  final bool sortAscending;
  final Set<_LeadColumnId> pinnedColumns;
  final bool Function(_LeadColumnId id) columnHasFilter;
  final VoidCallback onToggleAll;
  final void Function(_LeadColumnId column, {required bool ascending}) onSort;
  final ValueChanged<_LeadColumnId> onSortToggle;
  final ValueChanged<_LeadColumnId> onPin;
  final ValueChanged<_LeadColumnId> onHide;
  final ValueChanged<_ColumnDef> onFilterBy;
  final VoidCallback onManageColumns;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        height: _rowHeight,
        child: Row(
          children: [
            SizedBox(
              width: _checkboxColWidth,
              child: Checkbox(
                value: checkboxValue,
                tristate: true,
                onChanged: (_) => onToggleAll(),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            for (final column in visibleColumns)
              Expanded(
                flex: column.flex,
                child: _ColumnHeaderMenu(
                  column: column,
                  isSorted: sortColumn == column.id,
                  sortAscending: sortAscending,
                  isPinned: pinnedColumns.contains(column.id),
                  hasFilter: columnHasFilter(column.id),
                  onSortAsc: () => onSort(column.id, ascending: true),
                  onSortDesc: () => onSort(column.id, ascending: false),
                  onSortToggle: () => onSortToggle(column.id),
                  onPin: () => onPin(column.id),
                  onHide: () => onHide(column.id),
                  onFilterBy: () => onFilterBy(column),
                ),
              ),
            SizedBox(
              width: _manageColumnsColWidth,
              child: IconButton(
                onPressed: onManageColumns,
                icon: const Icon(Icons.add, size: 20),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Manage columns',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnHeaderMenu extends StatefulWidget {
  const _ColumnHeaderMenu({
    required this.column,
    required this.isSorted,
    required this.sortAscending,
    required this.isPinned,
    required this.hasFilter,
    required this.onSortAsc,
    required this.onSortDesc,
    required this.onSortToggle,
    required this.onPin,
    required this.onHide,
    required this.onFilterBy,
  });

  final _ColumnDef column;
  final bool isSorted;
  final bool sortAscending;
  final bool isPinned;
  final bool hasFilter;
  final VoidCallback onSortAsc;
  final VoidCallback onSortDesc;
  final VoidCallback onSortToggle;
  final VoidCallback onPin;
  final VoidCallback onHide;
  final VoidCallback onFilterBy;

  @override
  State<_ColumnHeaderMenu> createState() => _ColumnHeaderMenuState();
}

class _ColumnHeaderMenuState extends State<_ColumnHeaderMenu> {
  final MenuController _menuController = MenuController();

  void _closeAnd(VoidCallback action) {
    _menuController.close();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final sortIcon = widget.isSorted
        ? (widget.sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.swap_vert;

    return Row(
      children: [
        Expanded(
          child: MenuAnchor(
            controller: _menuController,
            alignmentOffset: const Offset(0, 4),
            style: MenuStyle(
              backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
              elevation: const WidgetStatePropertyAll(4),
              shadowColor: const WidgetStatePropertyAll(Colors.black26),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                  side: const BorderSide(color: _cardBorder),
                ),
              ),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              minimumSize: const WidgetStatePropertyAll(Size(_menuMinWidth, 0)),
            ),
            menuChildren: [
              _ColumnMenuItem(
                icon: Icons.arrow_upward,
                label: 'Asc',
                onPressed: () => _closeAnd(widget.onSortAsc),
              ),
              _ColumnMenuItem(
                icon: Icons.arrow_downward,
                label: 'Desc',
                onPressed: () => _closeAnd(widget.onSortDesc),
              ),
              _ColumnMenuItem(
                icon: Icons.push_pin_outlined,
                label: widget.isPinned ? 'Unpin Column' : 'Pin Column',
                onPressed: () => _closeAnd(widget.onPin),
              ),
              _ColumnMenuItem(
                icon: Icons.filter_alt_outlined,
                label: 'Filter by',
                onPressed: () => _closeAnd(widget.onFilterBy),
              ),
              _ColumnMenuItem(
                icon: Icons.visibility_off_outlined,
                label: 'Hide Column',
                enabled: !widget.column.isRequired,
                onPressed: () => _closeAnd(widget.onHide),
              ),
            ],
            builder: (context, controller, child) {
              return InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu,
                      size: 14,
                      color: widget.hasFilter
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.column.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.hasFilter
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        InkWell(
          onTap: widget.onSortToggle,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              sortIcon,
              size: 14,
              color: widget.isSorted
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ColumnMenuItem extends StatelessWidget {
  const _ColumnMenuItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: enabled ? onPressed : null,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(40)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (!enabled) return AppColors.textSecondary.withValues(alpha: 0.4);
          return Colors.black87;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) && enabled) {
            return _menuHoverColor;
          }
          return null;
        }),
        splashFactory: NoSplash.splashFactory,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: enabled
                ? AppColors.textSecondary
                : AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: enabled
                  ? Colors.black87
                  : AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadDataRow extends StatefulWidget {
  const _LeadDataRow({
    required this.lead,
    required this.leadKey,
    required this.visibleColumns,
    required this.isSelected,
    required this.onToggle,
  });

  final Lead lead;
  final String leadKey;
  final List<_ColumnDef> visibleColumns;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  State<_LeadDataRow> createState() => _LeadDataRowState();
}

class _LeadDataRowState extends State<_LeadDataRow> {
  bool _isHovered = false;

  Widget _cellForColumn(_ColumnDef column) {
    switch (column.id) {
      case _LeadColumnId.name:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lead.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            _StatusChip(status: widget.lead.status.label),
          ],
        );
      case _LeadColumnId.source:
        return _LeadSourceCell(source: widget.lead.displayLeadSource);
      case _LeadColumnId.company:
        return _PlainCellText(widget.lead.displayCompany);
      case _LeadColumnId.email:
        return _PlainCellText(widget.lead.displayEmail);
      case _LeadColumnId.phone:
        return _PlainCellText(widget.lead.displayPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ColoredBox(
        color: _isHovered ? _rowHoverColor : AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SizedBox(
            height: _rowHeight,
            child: Row(
              children: [
                SizedBox(
                  width: _checkboxColWidth,
                  child: Checkbox(
                    value: widget.isSelected,
                    onChanged: (_) => widget.onToggle(),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                for (final column in widget.visibleColumns)
                  Expanded(
                    flex: column.flex,
                    child: _cellForColumn(column),
                  ),
                const SizedBox(width: _manageColumnsColWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlainCellText extends StatelessWidget {
  const _PlainCellText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    final isDash = value == '—';
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        color: isDash ? AppColors.textSecondary : AppColors.textPrimary,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (background, textColor) = switch (status) {
      'New' => (const Color(0xFFF5F5F5), const Color(0xFF757575)),
      'Contacted' => (const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      'Qualified' => (const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      'Converted' => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      'Lost' => (const Color(0xFFFFEBEE), const Color(0xFFC62828)),
      _ => (const Color(0xFFF5F5F5), const Color(0xFF757575)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

class _LeadSourceCell extends StatelessWidget {
  const _LeadSourceCell({required this.source});

  final String source;

  Color get _dotColor => switch (source) {
    'Google Ads' => const Color(0xFF1565C0),
    'Referral' => const Color(0xFF6A1B9A),
    'Website' => const Color(0xFF00695C),
    'Walk-in' => const Color(0xFFE65100),
    _ => const Color(0xFF757575),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            source,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: _dotColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeadsEmptyState extends StatelessWidget {
  const _LeadsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No leads found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Try adjusting your filters.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadsPaginationFooter extends StatelessWidget {
  const _LeadsPaginationFooter({
    required this.pagination,
    required this.onPageChanged,
  });

  final PaginatedLeads pagination;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = pagination.currentPage > 1;
    final canGoNext = pagination.currentPage < pagination.totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Total Records: ${pagination.totalItems}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (pagination.totalItems > 0)
            Text(
              '${pagination.rangeStart} to ${pagination.rangeEnd}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          IconButton(
            onPressed: canGoPrevious
                ? () => onPageChanged(pagination.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textSecondary,
            tooltip: 'Previous page',
          ),
          IconButton(
            onPressed: canGoNext
                ? () => onPageChanged(pagination.currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textSecondary,
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}

class _ManageColumnsDialog extends StatefulWidget {
  const _ManageColumnsDialog({required this.hiddenColumns});

  final Set<_LeadColumnId> hiddenColumns;

  @override
  State<_ManageColumnsDialog> createState() => _ManageColumnsDialogState();
}

class _ManageColumnsDialogState extends State<_ManageColumnsDialog> {
  late Set<_LeadColumnId> _visibleColumns;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _visibleColumns = {
      for (final column in _allColumns)
        if (!widget.hiddenColumns.contains(column.id)) column.id,
    };
    _visibleColumns.add(_LeadColumnId.name);
  }

  List<_ColumnDef> get _filteredColumns {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _allColumns;
    return _allColumns
        .where((column) => column.manageLabel.toLowerCase().contains(query))
        .toList();
  }

  void _toggleColumn(_ColumnDef column, bool? checked) {
    if (column.isRequired) return;
    setState(() {
      if (checked == true) {
        _visibleColumns.add(column.id);
      } else {
        _visibleColumns.remove(column.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Manage Columns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: _cardBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final column in _filteredColumns)
                      _ManageColumnTile(
                        column: column,
                        isVisible: _visibleColumns.contains(column.id),
                        onChanged: (checked) => _toggleColumn(column, checked),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _visibleColumns),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageColumnTile extends StatelessWidget {
  const _ManageColumnTile({
    required this.column,
    required this.isVisible,
    required this.onChanged,
  });

  final _ColumnDef column;
  final bool isVisible;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: column.isRequired ? null : () => onChanged(!isVisible),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: isVisible,
                onChanged: column.isRequired ? null : onChanged,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Row(
                children: [
                  Text(
                    column.manageLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: column.isRequired
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (column.isRequired) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
