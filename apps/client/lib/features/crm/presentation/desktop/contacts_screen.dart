import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/contact_error_mapper.dart';
import 'package:billing_baba/features/crm/application/contacts_provider.dart';
import 'package:billing_baba/features/crm/application/contacts_selection_providers.dart';
import 'package:billing_baba/features/crm/domain/services/contact_service_types.dart';
import 'package:billing_baba/features/crm/presentation/desktop/widgets/add_contact_dialog.dart';
import 'package:billing_baba/features/crm/presentation/desktop/widgets/contacts_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _addContactRed = Color(0xFFE53935);
const _filterChipBg = Color(0xFFEAF2FB);
const _filterChipBorder = Color(0xFFD6E6F5);
const _filterBarBorder = Color(0xFFE0E0E0);
const _cardBorder = Color(0xFFE0E0E0);
const _filterPanelWidth = 280.0;
const _filterOverlayBreakpoint = 1180.0;
const _compactBreakpoint = 720.0;

const _systemFilterOptions = [
  'Activities',
  'Campaigns',
  'Notes',
  'Tasks',
];

const _fieldFilterOptions = [
  'Contact Name',
  'Account Name',
  'Email',
  'Phone',
  'Contact Owner',
];

class DesktopContactsScreen extends ConsumerStatefulWidget {
  const DesktopContactsScreen({super.key});

  @override
  ConsumerState<DesktopContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<DesktopContactsScreen> {
  bool _filterPanelOpen = true;
  String _panelSearchQuery = '';
  final Set<String> _systemFilters = {};
  final Set<String> _activeFieldFilters = {};

  Future<void> _saveContact(AddContactInput input) async {
    try {
      await ref
          .read(contactsProvider.notifier)
          .addContact(
            AddContactServiceInput.fromDialogInput(
              name: input.name,
              phone: input.phone,
              email: input.email,
              accountName: input.accountName,
              owner: input.owner,
              salutation: input.salutation,
              firstName: input.firstName,
              lastName: input.lastName,
              title: input.title,
              description: input.description,
              leadSource: input.leadSource,
              otherPhone: input.otherPhone,
              mobile: input.mobile,
              assistant: input.assistant,
              vendorName: input.vendorName,
              department: input.department,
              homePhone: input.homePhone,
              fax: input.fax,
              dateOfBirth: input.dateOfBirth,
              asstPhone: input.asstPhone,
              emailOptOut: input.emailOptOut,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact "${input.name}" saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ContactErrorMapper.messageFor(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openAddContactDialog() async {
    final input = await showAddContactDialog(
      context,
      onSaveAndNew: _saveContact,
    );
    if (!mounted || input == null) return;
    await _saveContact(input);
  }

  Future<void> _deleteSelectedContacts() async {
    final selectedIds = ref.read(selectedContactIdsProvider);
    if (selectedIds.isEmpty) return;

    final count = selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(count == 1 ? 'Delete contact?' : 'Delete $count contacts?'),
        content: Text(
          count == 1
              ? 'Are you sure you want to delete the selected contact?'
              : 'Are you sure you want to delete the selected contacts?',
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
      final notifier = ref.read(contactsProvider.notifier);
      for (final contactId in selectedIds.toList()) {
        await notifier.deleteContact(contactId);
      }
      if (!mounted) return;
      ref.read(selectedContactIdsProvider.notifier).clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 1
                ? 'Contact deleted successfully'
                : '$count contacts deleted successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ContactErrorMapper.messageFor(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(contactFiltersProvider);
    final filtersNotifier = ref.read(contactFiltersProvider.notifier);
    final selectedCount = ref.watch(selectedContactIdsProvider).length;

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
                    child: _ContactsTitleBar(
                      onAddContact: _openAddContactDialog,
                      onDelete: selectedCount == 0
                          ? null
                          : _deleteSelectedContacts,
                      selectedCount: selectedCount,
                      isCompact: isCompact,
                    ),
                  ),
                  SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pagePadding),
                    child: _ContactsFilterBar(
                      ownerLabel: filters.ownerLabel,
                      accountLabel: filters.accountLabel,
                      onOwnerSelected: (value) {
                        filtersNotifier.setAssignedTo(
                          value == 'All Owners' ? null : value,
                        );
                      },
                      onAccountSelected: (value) {
                        filtersNotifier.setAccountName(
                          value == 'All Accounts' ? null : value,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: _buildMainContent(
                      useFilterOverlay: useFilterOverlay,
                      maxWidth: constraints.maxWidth,
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

  Widget _buildMainContent({
    required bool useFilterOverlay,
    required double maxWidth,
  }) {
    final table = ContactsTable(
      filterPanelOpen: _filterPanelOpen,
      onToggleFilterPanel: () =>
          setState(() => _filterPanelOpen = !_filterPanelOpen),
    );

    final filterPanel = _ContactsFilterSidePanel(
      searchQuery: _panelSearchQuery,
      systemFilters: _systemFilters,
      activeFieldFilters: _activeFieldFilters,
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
          } else {
            _activeFieldFilters.add(field);
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

class _ContactsFilterSidePanel extends StatelessWidget {
  const _ContactsFilterSidePanel({
    required this.searchQuery,
    required this.systemFilters,
    required this.activeFieldFilters,
    required this.onSearchChanged,
    required this.onSystemFilterToggle,
    required this.onFieldFilterToggle,
    this.onClose,
    this.width = _filterPanelWidth,
  });

  final String searchQuery;
  final Set<String> systemFilters;
  final Set<String> activeFieldFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSystemFilterToggle;
  final ValueChanged<String> onFieldFilterToggle;
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
                    'Filter Contacts by',
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
                for (final option in fieldOptions)
                  _FilterCheckboxTile(
                    label: option,
                    checked: activeFieldFilters.contains(option),
                    onChanged: () => onFieldFilterToggle(option),
                  ),
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

class _ContactsTitleBar extends StatelessWidget {
  const _ContactsTitleBar({
    required this.onAddContact,
    this.onDelete,
    this.selectedCount = 0,
    this.isCompact = false,
  });

  final VoidCallback onAddContact;
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
              foregroundColor: _addContactRed,
              side: const BorderSide(color: _addContactRed),
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
              const Expanded(child: Text('Contacts', style: _titleStyle)),
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
              onPressed: onAddContact,
              style: _addContactButtonStyle,
              icon: const Icon(Icons.add, size: 22),
              label: const Text('Create Contact'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Expanded(child: Text('Contacts', style: _titleStyle)),
        if (deleteButton != null) ...[
          deleteButton,
          const SizedBox(width: AppSpacing.sm),
        ],
        FilledButton.icon(
          onPressed: onAddContact,
          style: _addContactButtonStyle,
          icon: const Icon(Icons.add, size: 22),
          label: const Text('Create Contact'),
        ),
        ...actionButtons,
      ],
    );
  }

  static ButtonStyle get _addContactButtonStyle => FilledButton.styleFrom(
    backgroundColor: _addContactRed,
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

class _ContactsFilterBar extends StatelessWidget {
  const _ContactsFilterBar({
    required this.ownerLabel,
    required this.accountLabel,
    required this.onOwnerSelected,
    required this.onAccountSelected,
  });

  final String ownerLabel;
  final String accountLabel;
  final ValueChanged<String> onOwnerSelected;
  final ValueChanged<String> onAccountSelected;

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
              label: ownerLabel,
              chipBackgroundColor: _filterChipBg,
              chipBorderColor: _filterChipBorder,
              options: const [
                'All Owners',
                'Saksham Koch',
                'Priya Mehta',
                'Amit Verma',
              ],
              selected: ownerLabel,
              onSelected: onOwnerSelected,
            ),
            SaleFilterDropdown(
              label: accountLabel,
              chipBackgroundColor: _filterChipBg,
              chipBorderColor: _filterChipBorder,
              options: const [
                'All Accounts',
                'ABC Traders',
                'XYZ Enterprises',
                'Verma and Sons',
                'Kumar Distributors',
                'Gupta Wholesale',
              ],
              selected: accountLabel,
              onSelected: onAccountSelected,
            ),
          ],
        ),
      ),
    );
  }
}
