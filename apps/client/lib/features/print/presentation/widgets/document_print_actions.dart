import 'package:billing_baba/features/print/application/print_service.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/providers/print_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Print/share actions for any commercial document via [PrintService].
abstract final class DocumentPrintActions {
  static String filenameFor(String documentNumber) {
    final safe = documentNumber.replaceAll(RegExp(r'[^\w\-]+'), '_');
    return safe.isEmpty ? 'document' : safe;
  }

  static Future<void> preview(
    BuildContext context,
    WidgetRef ref,
    PrintRequest request, {
    String? filename,
  }) {
    return _run(
      context,
      ref,
      (service) => service.preview(
        context: context,
        request: request,
        name: filename,
      ),
    );
  }

  static Future<void> print(
    BuildContext context,
    WidgetRef ref,
    PrintRequest request, {
    String? filename,
  }) {
    return _run(
      context,
      ref,
      (service) => service.print(request, name: filename),
    );
  }

  static Future<void> share(
    BuildContext context,
    WidgetRef ref,
    PrintRequest request, {
    required String filename,
  }) {
    return _run(
      context,
      ref,
      (service) => service.share(
        request,
        filename: '$filename.pdf',
      ),
    );
  }

  static Future<void> save(
    BuildContext context,
    WidgetRef ref,
    PrintRequest request, {
    required String filename,
  }) {
    return _run(
      context,
      ref,
      (service) async {
        final path = await service.save(
          request,
          filename: '$filename.pdf',
        );
        if (!context.mounted) return;
        final message = path != null
            ? 'PDF saved to $path'
            : 'PDF ready to share';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  static Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(PrintService service) action,
  ) async {
    try {
      final service = await ref.read(printServiceProvider.future);
      if (!context.mounted) return;
      await action(service);
    } on PrintException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $error')),
      );
    }
  }
}
