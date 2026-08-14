import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/device_contact_import_service.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vyapar-style searchable contact list for party import.
Future<DeviceContactEntry?> showDeviceContactPickerSheet(
  BuildContext context,
) {
  return showMobileBottomSheet<DeviceContactEntry>(
    context: context,
    title: 'Import from Contacts',
    maxHeightFraction: 0.92,
    builder: (_) => const _DeviceContactPickerBody(),
  );
}

class _DeviceContactPickerBody extends ConsumerStatefulWidget {
  const _DeviceContactPickerBody();

  @override
  ConsumerState<_DeviceContactPickerBody> createState() =>
      _DeviceContactPickerBodyState();
}

class _DeviceContactPickerBodyState
    extends ConsumerState<_DeviceContactPickerBody> {
  final _searchController = TextEditingController();
  List<DeviceContactEntry> _contacts = const [];
  var _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContacts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(deviceContactImportServiceProvider);
      final contacts = await service.loadContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load contacts. Please try again.';
      });
    }
  }

  List<DeviceContactEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _contacts;
    return _contacts.where((entry) {
      final haystack = [
        entry.displayName,
        ...entry.phones,
        entry.email ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: MobileSearchField(
            controller: _searchController,
            hint: 'Search contacts',
            onChanged: (_) {},
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No contacts found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    final subtitle = contact.phones.isNotEmpty
                        ? contact.phones.join(', ')
                        : (contact.email ?? '');
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          contact.displayName.isNotEmpty
                              ? contact.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(
                        contact.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: subtitle.isEmpty
                          ? null
                          : Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () => Navigator.of(context).pop(contact),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
