import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/device_contact_import_service.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<List<DeviceContactEntry>?> showDeviceContactMultiPickerSheet(
  BuildContext context,
) {
  return showMobileBottomSheet<List<DeviceContactEntry>>(
    context: context,
    title: 'Select contacts',
    maxHeightFraction: 0.92,
    builder: (_) => const _DeviceContactMultiPickerBody(),
  );
}

class _DeviceContactMultiPickerBody extends ConsumerStatefulWidget {
  const _DeviceContactMultiPickerBody();

  @override
  ConsumerState<_DeviceContactMultiPickerBody> createState() =>
      _DeviceContactMultiPickerBodyState();
}

class _DeviceContactMultiPickerBodyState
    extends ConsumerState<_DeviceContactMultiPickerBody> {
  final _searchController = TextEditingController();
  List<DeviceContactEntry> _contacts = const [];
  final _selected = <String>{};
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

  void _toggleAllFiltered(bool select) {
    setState(() {
      for (final entry in _filtered) {
        if (select) {
          _selected.add(entry.id);
        } else {
          _selected.remove(entry.id);
        }
      }
    });
  }

  void _submit() {
    final picked = _contacts.where((c) => _selected.contains(c.id)).toList();
    Navigator.of(context).pop(picked);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final allSelected =
        filtered.isNotEmpty && filtered.every((e) => _selected.contains(e.id));

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              TextButton(
                onPressed: filtered.isEmpty
                    ? null
                    : () => _toggleAllFiltered(!allSelected),
                child: Text(allSelected ? 'Clear all' : 'Select all'),
              ),
              const Spacer(),
              Text(
                '${_selected.length} selected',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    final checked = _selected.contains(entry.id);
                    return CheckboxListTile(
                      value: checked,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selected.add(entry.id);
                          } else {
                            _selected.remove(entry.id);
                          }
                        });
                      },
                      title: Text(entry.displayName),
                      subtitle: Text(
                        entry.phones.join(', '),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FilledButton(
              onPressed: _selected.isEmpty ? null : _submit,
              child: Text('Import ${_selected.length} contacts'),
            ),
          ),
        ),
      ],
    );
  }
}
