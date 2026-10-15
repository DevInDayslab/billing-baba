import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/device_contact_import_service.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/party_contact_import_service.dart';
import 'package:billing_baba/features/parties/models/party_contact_import_models.dart';
import 'package:billing_baba/features/parties/application/party_import_preview_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/device_contact_multi_picker_sheet.dart';
import 'package:billing_baba/features/utilities/application/import_parties_commit.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' hide PermissionStatus;

class PartyContactImportSessionPage extends ConsumerStatefulWidget {
  const PartyContactImportSessionPage({required this.token, super.key});

  final String token;

  @override
  ConsumerState<PartyContactImportSessionPage> createState() =>
      _PartyContactImportSessionPageState();
}

class _PartyContactImportSessionPageState
    extends ConsumerState<PartyContactImportSessionPage> {
  PartyContactImportSession? _session;
  String? _error;
  var _loading = true;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSession());
  }

  Future<void> _loadSession() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(partyContactImportServiceProvider);
      final session = await service.loadByToken(widget.token);
      if (!mounted) return;
      if (session.status == 'expired' || session.status == 'cancelled') {
        setState(() {
          _loading = false;
          _error = 'This import link has expired.';
        });
        return;
      }
      final activeBusinessId = ref.read(currentBusinessProvider)?.id;
      if (activeBusinessId != null &&
          activeBusinessId.isNotEmpty &&
          activeBusinessId != session.businessId) {
        setState(() {
          _loading = false;
          _error =
              'Switch to the correct company in the app before importing contacts.';
        });
        return;
      }
      setState(() {
        _session = session;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _pickAndSubmit() async {
    final contactService = ref.read(deviceContactImportServiceProvider);
    if (!contactService.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact import requires a mobile device.')),
      );
      return;
    }

    final permission = await contactService.requestAccess();
    if (!mounted) return;
    if (permission != DeviceContactPermissionResult.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission is required.')),
      );
      if (permission == DeviceContactPermissionResult.permanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    final picked = await showDeviceContactMultiPickerSheet(context);
    if (picked == null || picked.isEmpty || !mounted) return;

    setState(() => _submitting = true);
    try {
      final staging = picked
          .map(
            (entry) => PartyContactImportStagingRowDto(
              displayName: entry.displayName,
              primaryPhone: entry.phones.first,
              phones: entry.phones,
              email: entry.email,
              address: entry.address,
              sortOrder: 0,
            ),
          )
          .toList();

      await ref
          .read(partyContactImportServiceProvider)
          .submitContacts(widget.token, staging);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contacts sent'),
          content: const Text(
            'Return to your desktop to review and import these parties.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final company = session?.companyName ?? 'your business';

    return Scaffold(
      appBar: const MobileAppBar(title: 'Import contacts'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Import contacts for $company',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Select contacts from your phone. Your desktop will show a '
                    'preview before parties are created.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _submitting ? null : _pickAndSubmit,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Choose contacts'),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Bulk import on the same device (no QR session).
Future<void> openMobileBulkContactImport(
  BuildContext context,
  WidgetRef ref,
) async {
  final service = ref.read(deviceContactImportServiceProvider);
  if (!service.isSupported) return;

  final permission = await service.requestAccess();
  if (!context.mounted) return;
  if (permission != DeviceContactPermissionResult.granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacts permission is required.')),
    );
    return;
  }

  final picked = await showDeviceContactMultiPickerSheet(context);
  if (picked == null || picked.isEmpty || !context.mounted) return;

  final staging = picked
      .map(
        (entry) => PartyContactImportStagingRowDto(
          displayName: entry.displayName,
          primaryPhone: entry.phones.first,
          phones: entry.phones,
          email: entry.email,
          address: entry.address,
          sortOrder: 0,
        ),
      )
      .toList();

  final parties = ref.read(partyListProvider).asData?.value ?? const [];
  final rows = PartyImportPreviewMapper.fromContactStaging(
    staging: staging,
    existingParties: parties,
  );
  final result = await commitImportPartyRows(
    ref.read(partyListProvider.notifier),
    rows,
  );
  if (!context.mounted || result == null) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Imported ${result.successCount} parties'
        '${result.failedCount > 0 ? ', ${result.failedCount} failed' : ''}.',
      ),
    ),
  );
}
