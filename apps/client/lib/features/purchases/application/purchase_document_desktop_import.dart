import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/router/app_router.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/purchases/application/add_purchase_form_provider.dart';
import 'package:billing_baba/features/purchases/application/pending_purchase_document_parse_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_document_parsing_dialog.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
const _logPrefix = '[PurchaseParse]';

/// Runs the desktop import flow: pick file, parse via API, then fill Add Purchase.
///
/// [context] must be from a widget under [MaterialApp.router] (e.g. a page), not
/// from a dialog route. Routing uses [appRouterProvider] so overlays never call
/// [GoRouterState.of] on an invalid [BuildContext].
Future<void> runPurchaseDocumentDesktopImport({
  required BuildContext context,
  String? billId,
  VoidCallback? onUploadModalClosed,
}) async {
  if (!context.mounted) return;

  final container = ProviderScope.containerOf(context);
  final router = container.read(appRouterProvider);

  debugPrint(
    '$_logPrefix runPurchaseDocumentDesktopImport start billId=$billId',
  );

  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: _allowedExtensions,
    withData: true,
  );
  debugPrint('$_logPrefix file picker complete picked=${picked != null}');

  if (picked == null || picked.files.isEmpty) return;

  final file = picked.files.first;
  final extension = _extensionFor(file.name);
  if (!_allowedExtensions.contains(extension)) {
    final snackContext = _routerOverlayContext(router);
    if (snackContext == null || !snackContext.mounted) return;
    ScaffoldMessenger.of(snackContext).showSnackBar(
      const SnackBar(
        content: Text('Only .jpg, .jpeg, .png, and .pdf files are supported'),
      ),
    );
    return;
  }

  // Close the upload modal only after the user has chosen a file.
  onUploadModalClosed?.call();

  await _parseAndApply(
    router: router,
    container: container,
    billId: billId,
    file: file,
  );
}

Future<void> _parseAndApply({
  required GoRouter router,
  required ProviderContainer container,
  required PlatformFile file,
  String? billId,
}) async {
  final overlayContext = _routerOverlayContext(router);
  if (overlayContext == null || !overlayContext.mounted) {
    debugPrint('$_logPrefix abort: overlay context unavailable');
    return;
  }

  final rootNavigator = Navigator.of(overlayContext, rootNavigator: true);
  showPurchaseDocumentParsingDialog(overlayContext);

  var loadingDismissed = false;

  Future<void> dismissLoading(String reason) async {
    if (loadingDismissed) return;
    debugPrint('$_logPrefix dismiss loading ($reason)');
    final dismissed = await hidePurchaseDocumentParsingDialog(rootNavigator);
    loadingDismissed = dismissed || loadingDismissed;
    if (!loadingDismissed && isPurchaseDocumentParsingDialogVisible) {
      debugPrint(
        '$_logPrefix warn: parsing dialog still visible after dismiss',
      );
    }
  }

  try {
    debugPrint('$_logPrefix before readAsBytes');
    final bytes = await file.readAsBytes();
    debugPrint('$_logPrefix after readAsBytes bytes=${bytes.length}');
    if (bytes.isEmpty) {
      throw StateError('Could not read the selected file. Please try again.');
    }

    debugPrint('$_logPrefix before purchaseServiceProvider.future');
    final service = await container.read(purchaseServiceProvider.future);
    debugPrint('$_logPrefix after purchaseServiceProvider.future');

    debugPrint('$_logPrefix before parsePurchaseDocument');
    final parsed = await service.parsePurchaseDocument(
      filename: file.name,
      bytes: bytes,
      mimeType: _mimeTypeFor(file),
    );
    debugPrint(
      '$_logPrefix after parsePurchaseDocument lines=${parsed.lines.length}',
    );

    // Dismiss before apply/navigation so router.push does not leave the overlay up.
    await dismissLoading('parse succeeded');

    debugPrint('$_logPrefix before applyParsedDocument');
    await _applyParsedDocument(
      router: router,
      container: container,
      billId: billId,
      parsed: parsed,
    );
    debugPrint('$_logPrefix after applyParsedDocument');

    final snackContext = _routerOverlayContext(router);
    if (snackContext != null && snackContext.mounted) {
      ScaffoldMessenger.of(snackContext).showSnackBar(
        const SnackBar(
          content: Text('Document parsed. Review the fields and save.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  } on DioException catch (error, stackTrace) {
    debugPrint('$_logPrefix DioException: $error\n$stackTrace');
    await dismissLoading('dio error');
    await _showParseFailureDialog(
      router: router,
      container: container,
      billId: billId,
      file: file,
      message: _parseErrorMessage(error),
    );
  } on StateError catch (error, stackTrace) {
    debugPrint('$_logPrefix StateError: $error\n$stackTrace');
    await dismissLoading('state error');
    await _showParseFailureDialog(
      router: router,
      container: container,
      billId: billId,
      file: file,
      message: error.message,
    );
  } on Object catch (error, stackTrace) {
    debugPrint('$_logPrefix unexpected error: $error\n$stackTrace');
    await dismissLoading('unexpected error');

    if (_isGoRouterError(error)) {
      _showNavigationFailureSnackBar(router, error, stackTrace);
      return;
    }

    await _showParseFailureDialog(
      router: router,
      container: container,
      billId: billId,
      file: file,
      message: _parseErrorMessage(error),
    );
  } finally {
    await dismissLoading('finally');
  }
}

Future<void> _showParseFailureDialog({
  required GoRouter router,
  required ProviderContainer container,
  required PlatformFile file,
  required String message,
  String? billId,
}) async {
  final overlayContext = _routerOverlayContext(router);
  if (overlayContext == null || !overlayContext.mounted) {
    debugPrint('$_logPrefix parse failure dialog skipped: no overlay context');
    return;
  }

  debugPrint('$_logPrefix before parse failure dialog');
  final retry = await showPurchaseDocumentParseErrorDialog(
    overlayContext,
    message: message,
  );
  debugPrint('$_logPrefix after parse failure dialog retry=$retry');

  if (!overlayContext.mounted) return;

  if (retry == true) {
    await _parseAndApply(
      router: router,
      container: container,
      billId: billId,
      file: file,
    );
    return;
  }

  if (retry == false) {
    debugPrint('$_logPrefix before openManualEntry');
    await _openManualEntry(router: router);
    debugPrint('$_logPrefix after openManualEntry');
  }
}

Future<void> _applyParsedDocument({
  required GoRouter router,
  required ProviderContainer container,
  required String? billId,
  required PurchaseDocumentParseDto parsed,
}) async {
  final onAddPurchase = router.state.uri.path == AppRoutes.addPurchase;
  debugPrint('$_logPrefix applyParsedDocument onAddPurchase=$onAddPurchase');

  try {
    if (onAddPurchase) {
      debugPrint(
        '$_logPrefix before addPurchaseFormProvider.applyParsedDocument',
      );
      await container
          .read(addPurchaseFormProvider(billId: billId).notifier)
          .applyParsedDocument(parsed);
      debugPrint(
        '$_logPrefix after addPurchaseFormProvider.applyParsedDocument',
      );
      return;
    }

    debugPrint('$_logPrefix before pendingPurchaseDocumentParseProvider.set');
    container.read(pendingPurchaseDocumentParseProvider.notifier).set(parsed);
    debugPrint('$_logPrefix before router.push ${AppRoutes.addPurchase}');
    await router.push(AppRoutes.addPurchase);
    debugPrint('$_logPrefix after router.push ${AppRoutes.addPurchase}');
  } on Object catch (error, stackTrace) {
    debugPrint('$_logPrefix applyParsedDocument failed: $error\n$stackTrace');
    rethrow;
  }
}

Future<void> _openManualEntry({required GoRouter router}) async {
  if (router.state.uri.path == AppRoutes.addPurchase) return;
  await router.push(AppRoutes.addPurchase);
}

BuildContext? _routerOverlayContext(GoRouter router) {
  return router.routerDelegate.navigatorKey.currentContext;
}

bool _isGoRouterError(Object error) {
  if (error is GoError) return true;
  final message = error.toString();
  return message.contains('GoRouterState') ||
      message.contains('There is no GoRouterState above the current context');
}

void _showNavigationFailureSnackBar(
  GoRouter router,
  Object error,
  StackTrace stackTrace,
) {
  debugPrint('$_logPrefix navigation failed: $error\n$stackTrace');

  final snackContext = _routerOverlayContext(router);
  if (snackContext == null || !snackContext.mounted) return;

  ScaffoldMessenger.of(snackContext).showSnackBar(
    const SnackBar(
      content: Text(
        'Document parsed, but navigation failed. Open Add Purchase to review the imported data.',
      ),
      backgroundColor: Color(0xFFB45309),
    ),
  );
}

String _parseErrorMessage(Object error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Document parsing timed out. Try again with a smaller file, or enter details manually.';
    }
    return ApiErrorParser.userFacingMessage(error);
  }

  if (error is StateError) {
    return error.message;
  }

  return 'Could not parse the document. Please try again.';
}

String _extensionFor(String filename) {
  final parts = filename.toLowerCase().split('.');
  if (parts.length < 2) return '';
  return parts.last;
}

String? _mimeTypeFor(PlatformFile file) {
  final extension = file.extension?.toLowerCase() ?? _extensionFor(file.name);
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'pdf':
      return 'application/pdf';
    default:
      return null;
  }
}
