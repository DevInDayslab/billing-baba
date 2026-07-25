import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/contact_error_mapper.dart';
import 'package:billing_baba/features/crm/application/contacts_provider.dart';
import 'package:billing_baba/features/crm/application/contacts_selection_providers.dart';
import 'package:billing_baba/features/crm/domain/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _rowHoverColor = Color(0xFFF5F5F5);
const _rowHeight = 56.0;
const _checkboxColWidth = 48.0;
const _manageColumnsColWidth = 40.0;
const _menuHoverColor = Color(0xFFE3F2FD);
const _menuMinWidth = 200.0;
const _tableMinWidth = 860.0;

enum _ContactColumnId { name, accountName, email, phone, assignedTo }

class _ColumnDef {
  const _ColumnDef({
    required this.id,
    required this.label,
    required this.flex,
    required this.fieldKey,
  });

  final _ContactColumnId id;
  final String label;
  final int flex;
  final String fieldKey;

  bool get isRequired => id == _ContactColumnId.name;

  String get manageLabel => switch (id) {
    _ContactColumnId.name => 'Contact Name',
    _ContactColumnId.accountName => 'Account Name',
    _ContactColumnId.email => 'Email',
    _ContactColumnId.phone => 'Phone',
    _ContactColumnId.assignedTo => 'Contact Owner',
  };
}

const _allColumns = [
  _ColumnDef(
    id: _ContactColumnId.name,
    label: 'CONTACT NAME',
    flex: 2,
    fieldKey: 'name',
  ),
  _ColumnDef(
    id: _ContactColumnId.accountName,
    label: 'ACCOUNT NAME',
    flex: 2,
    fieldKey: 'accountName',
  ),
  _ColumnDef(
    id: _ContactColumnId.email,
    label: 'EMAIL',
    flex: 2,
    fieldKey: 'email',
  ),
  _ColumnDef(
    id: _ContactColumnId.phone,
    label: 'PHONE',
    flex: 3,
    fieldKey: 'phone',
  ),
  _ColumnDef(
    id: _ContactColumnId.assignedTo,
    label: 'CONTACT OWNER',
    flex: 3,
    fieldKey: 'assignedTo',
  ),
];

class ContactsTable extends ConsumerStatefulWidget {
  const ContactsTable({
    required this.filterPanelOpen,
    required this.onToggleFilterPanel,
    super.key,
  });

  final bool filterPanelOpen;
  final VoidCallback onToggleFilterPanel;

  @override
  ConsumerState<ContactsTable> createState() => _ContactsTableState();
}

class _ContactsTableState extends ConsumerState<ContactsTable> {
  final Set<_ContactColumnId> _hiddenColumns = {};
  final Set<_ContactColumnId> _pinnedColumns = {};
  final Map<_ContactColumnId, String> _columnTextFilters = {};

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

  List<Contact> _applyColumnFilters(List<Contact> contacts) {
    var results = List<Contact>.from(contacts);

    for (final column in _allColumns) {
      final textFilter = _columnTextFilters[column.id]?.trim().toLowerCase();
      if (textFilter == null || textFilter.isEmpty) continue;

      results = results.where((contact) {
        final value = _contactFieldValue(contact, column.id).toLowerCase();
        return value.contains(textFilter);
      }).toList();
    }

    return results;
  }

  String _contactFieldValue(Contact contact, _ContactColumnId id) {
    return switch (id) {
      _ContactColumnId.name => contact.name,
      _ContactColumnId.accountName => contact.displayAccountName,
      _ContactColumnId.email => contact.displayEmail,
      _ContactColumnId.phone => contact.displayPhone,
      _ContactColumnId.assignedTo => contact.displayAssignedTo,
    };
  }

  void _sortByColumn(_ContactColumnId column, {required bool ascending}) {
    final sortColumn = switch (column) {
      _ContactColumnId.name => ContactSortColumn.name,
      _ContactColumnId.accountName => ContactSortColumn.accountName,
      _ContactColumnId.email => ContactSortColumn.email,
      _ContactColumnId.phone => ContactSortColumn.phone,
      _ContactColumnId.assignedTo => ContactSortColumn.assignedTo,
    };
    final notifier = ref.read(contactFiltersProvider.notifier);
    final filters = ref.read(contactFiltersProvider);

    if (filters.sortColumn != sortColumn) {
      notifier.toggleSort(sortColumn);
    }

    final isAscending =
        ref.read(contactFiltersProvider).sortDirection ==
        ContactSortDirection.ascending;
    if (ascending != isAscending) {
      notifier.toggleSort(sortColumn);
    }
  }

  void _toggleSortColumn(_ContactColumnId column) {
    final sortColumn = switch (column) {
      _ContactColumnId.name => ContactSortColumn.name,
      _ContactColumnId.accountName => ContactSortColumn.accountName,
      _ContactColumnId.email => ContactSortColumn.email,
      _ContactColumnId.phone => ContactSortColumn.phone,
      _ContactColumnId.assignedTo => ContactSortColumn.assignedTo,
    };
    ref.read(contactFiltersProvider.notifier).toggleSort(sortColumn);
  }

  void _togglePinColumn(_ContactColumnId column) {
    setState(() {
      if (_pinnedColumns.contains(column)) {
        _pinnedColumns.remove(column);
      } else {
        _pinnedColumns.add(column);
      }
    });
  }

  void _hideColumn(_ContactColumnId column) {
    if (_allColumns.firstWhere((c) => c.id == column).isRequired) return;
    setState(() => _hiddenColumns.add(column));
  }

  Future<void> _showManageColumnsDialog() async {
    final result = await showDialog<Set<_ContactColumnId>>(
      context: context,
      builder: (context) => _ManageColumnsDialog(hiddenColumns: _hiddenColumns),
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
    final controller = TextEditingController(
      text: _columnTextFilters[column.id] ?? '',
    );
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter by ${column.manageLabel}'),
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

  bool _columnHasActiveFilter(_ContactColumnId id) {
    final text = _columnTextFilters[id]?.trim();
    return text != null && text.isNotEmpty;
  }

  _ContactColumnId? _activeSortColumn(ContactFiltersState filters) {
    return switch (filters.sortColumn) {
      ContactSortColumn.name => _ContactColumnId.name,
      ContactSortColumn.accountName => _ContactColumnId.accountName,
      ContactSortColumn.email => _ContactColumnId.email,
      ContactSortColumn.phone => _ContactColumnId.phone,
      ContactSortColumn.assignedTo => _ContactColumnId.assignedTo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final paginated = ref.watch(paginatedContactsProvider);
    final filters = ref.watch(contactFiltersProvider);
    final notifier = ref.read(contactsProvider.notifier);
    final filteredContacts = _applyColumnFilters(paginated.items);
    final sortColumn = _activeSortColumn(filters);
    final sortAscending =
        filters.sortDirection == ContactSortDirection.ascending;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ContactsTableToolbar(
            filterPanelOpen: widget.filterPanelOpen,
            onToggleFilterPanel: widget.onToggleFilterPanel,
            onRefresh: notifier.refresh,
          ),
          const Divider(height: 1, color: _cardBorder),
          Expanded(
            child: contactsAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ContactErrorMapper.messageFor(error)),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: notifier.refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (_) {
                if (paginated.totalItems == 0) {
                  return const _ContactsEmptyState();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final tableWidth = math.max(
                      constraints.maxWidth,
                      _tableMinWidth,
                    );
                    final selectedIds = ref.watch(selectedContactIdsProvider);
                    final pageIds = filteredContacts.map((c) => c.id).toList();
                    final allSelected =
                        pageIds.isNotEmpty &&
                        pageIds.every(selectedIds.contains);
                    final someSelected =
                        pageIds.any(selectedIds.contains) && !allSelected;
                    final headerCheckboxValue = allSelected
                        ? true
                        : (someSelected ? null : false);

                    final header = SizedBox(
                      width: tableWidth,
                      child: _ContactsTableHeaderRow(
                        visibleColumns: _visibleColumns,
                        checkboxValue: headerCheckboxValue,
                        sortColumn: sortColumn,
                        sortAscending: sortAscending,
                        pinnedColumns: _pinnedColumns,
                        columnHasFilter: _columnHasActiveFilter,
                        onToggleAll: () => ref
                            .read(selectedContactIdsProvider.notifier)
                            .toggleAll(pageIds),
                        onSort: _sortByColumn,
                        onSortToggle: _toggleSortColumn,
                        onPin: _togglePinColumn,
                        onHide: _hideColumn,
                        onFilterBy: _showColumnFilterDialog,
                        onManageColumns: _showManageColumnsDialog,
                      ),
                    );

                    Widget tableBody;
                    if (filteredContacts.isEmpty) {
                      tableBody = const _ContactsEmptyState(
                        message: 'No contacts match your filters.',
                      );
                    } else {
                      tableBody = ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: filteredContacts.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: _cardBorder),
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          return _ContactDataRow(
                            contact: contact,
                            visibleColumns: _visibleColumns,
                            isSelected: selectedIds.contains(contact.id),
                            onToggle: () => ref
                                .read(selectedContactIdsProvider.notifier)
                                .toggle(contact.id),
                          );
                        },
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
                );
              },
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          _ContactsPaginationRow(paginated: paginated),
        ],
      ),
    );
  }
}

class _ContactsTableToolbar extends StatelessWidget {
  const _ContactsTableToolbar({
    required this.filterPanelOpen,
    required this.onToggleFilterPanel,
    required this.onRefresh,
  });

  final bool filterPanelOpen;
  final VoidCallback onToggleFilterPanel;
  final VoidCallback onRefresh;

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
          const Spacer(),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Refresh',
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

class _ContactsTableHeaderRow extends StatelessWidget {
  const _ContactsTableHeaderRow({
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
  final _ContactColumnId? sortColumn;
  final bool sortAscending;
  final Set<_ContactColumnId> pinnedColumns;
  final bool Function(_ContactColumnId id) columnHasFilter;
  final VoidCallback onToggleAll;
  final void Function(_ContactColumnId column, {required bool ascending})
  onSort;
  final ValueChanged<_ContactColumnId> onSortToggle;
  final ValueChanged<_ContactColumnId> onPin;
  final ValueChanged<_ContactColumnId> onHide;
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

class _ContactDataRow extends StatefulWidget {
  const _ContactDataRow({
    required this.contact,
    required this.visibleColumns,
    required this.isSelected,
    required this.onToggle,
  });

  final Contact contact;
  final List<_ColumnDef> visibleColumns;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  State<_ContactDataRow> createState() => _ContactDataRowState();
}

class _ContactDataRowState extends State<_ContactDataRow> {
  bool _isHovered = false;

  Widget _cellForColumn(_ColumnDef column) {
    switch (column.id) {
      case _ContactColumnId.name:
        return Text(
          widget.contact.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        );
      case _ContactColumnId.accountName:
        return _PlainCellText(widget.contact.displayAccountName);
      case _ContactColumnId.email:
        return _PlainCellText(widget.contact.displayEmail);
      case _ContactColumnId.phone:
        return _PlainCellText(widget.contact.displayPhone);
      case _ContactColumnId.assignedTo:
        return _PlainCellText(widget.contact.displayAssignedTo);
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

class _ContactsEmptyState extends StatelessWidget {
  const _ContactsEmptyState({this.message = 'No contacts found'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactsPaginationRow extends ConsumerWidget {
  const _ContactsPaginationRow({required this.paginated});

  final PaginatedContacts paginated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtersNotifier = ref.read(contactFiltersProvider.notifier);
    final canGoPrevious = paginated.currentPage > 1;
    final canGoNext = paginated.currentPage < paginated.totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Total Records: ${paginated.totalItems}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (paginated.totalItems > 0)
            Text(
              '${paginated.rangeStart} to ${paginated.rangeEnd}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          IconButton(
            onPressed: canGoPrevious
                ? () => filtersNotifier.setPage(paginated.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
          ),
          IconButton(
            onPressed: canGoNext
                ? () => filtersNotifier.setPage(paginated.currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}

class _ManageColumnsDialog extends StatefulWidget {
  const _ManageColumnsDialog({required this.hiddenColumns});

  final Set<_ContactColumnId> hiddenColumns;

  @override
  State<_ManageColumnsDialog> createState() => _ManageColumnsDialogState();
}

class _ManageColumnsDialogState extends State<_ManageColumnsDialog> {
  late Set<_ContactColumnId> _visibleColumns;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _visibleColumns = {
      for (final column in _allColumns)
        if (!widget.hiddenColumns.contains(column.id)) column.id,
    };
    _visibleColumns.add(_ContactColumnId.name);
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
