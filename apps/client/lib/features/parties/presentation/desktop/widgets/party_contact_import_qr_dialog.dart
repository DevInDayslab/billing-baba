import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_contact_import_service.dart';
import 'package:billing_baba/features/parties/models/party_contact_import_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Starts a contact import session and polls until the phone submits contacts.
/// Returns session id when [status] is `submitted`, or null if dismissed.
Future<String?> showPartyContactImportQrDialog(BuildContext context) {
  return showDialog<String?>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _PartyContactImportQrDialog(),
  );
}

class _PartyContactImportQrDialog extends ConsumerStatefulWidget {
  const _PartyContactImportQrDialog();

  @override
  ConsumerState<_PartyContactImportQrDialog> createState() =>
      _PartyContactImportQrDialogState();
}

class _PartyContactImportQrDialogState
    extends ConsumerState<_PartyContactImportQrDialog> {
  PartyContactImportSessionCreated? _session;
  String? _error;
  var _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(partyContactImportServiceProvider);
      final created = await service.createSession();
      if (!mounted) return;
      setState(() {
        _session = created;
        _loading = false;
      });
      if (created.notificationSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Message has been sent to your WhatsApp/SMS. Kindly check your messages.',
            ),
          ),
        );
      }
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        unawaited(_poll(created.sessionId));
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _poll(String sessionId) async {
    try {
      final service = ref.read(partyContactImportServiceProvider);
      final session = await service.pollSession(sessionId);
      if (!mounted) return;
      if (session.status == 'submitted') {
        _pollTimer?.cancel();
        Navigator.of(context).pop(sessionId);
      } else if (session.status == 'expired' || session.status == 'cancelled') {
        _pollTimer?.cancel();
        setState(() => _error = 'Import session expired. Please try again.');
      }
    } on Object {
      // Keep polling on transient errors.
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return AlertDialog(
      title: const Text('Scan this QR on your phone'),
      content: SizedBox(
        width: 360,
        child: _loading
            ? const Center(
                heightFactor: 2,
                child: CircularProgressIndicator(),
              )
            : _error != null
            ? Text(_error!, style: const TextStyle(color: AppColors.error))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (session != null) _QrImage(dataUrl: session.qrDataUrl),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Or open the link we\'ve sent on your WhatsApp/SMS.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Waiting for contacts from your phone…',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (_error != null)
          FilledButton(
            onPressed: () => unawaited(_start()),
            child: const Text('Try again'),
          ),
      ],
    );
  }
}

/// API returns a PNG [data URL](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URLs);
/// [Image.network] does not decode those on desktop, so render from bytes instead.
class _QrImage extends StatelessWidget {
  const _QrImage({required this.dataUrl});

  final String dataUrl;

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeDataUrlImage(dataUrl);
    if (bytes == null) {
      return const SizedBox(
        width: 240,
        height: 240,
        child: Center(
          child: Text(
            'Could not display QR code',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ),
      );
    }
    return Image.memory(bytes, width: 240, height: 240, fit: BoxFit.contain);
  }

  static Uint8List? _decodeDataUrlImage(String dataUrl) {
    const prefix = 'data:image';
    if (!dataUrl.startsWith(prefix)) return null;
    final comma = dataUrl.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(dataUrl.substring(comma + 1));
    } on FormatException {
      return null;
    }
  }
}
