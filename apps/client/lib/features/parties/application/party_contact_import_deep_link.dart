import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:billing_baba/core/routing/app_navigator_key.dart';
import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Listens for `billingbaba://import-contacts/{token}` deep links.
class PartyContactImportDeepLinkListener {
  PartyContactImportDeepLinkListener._();

  static final PartyContactImportDeepLinkListener instance =
      PartyContactImportDeepLinkListener._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  var _started = false;

  Future<void> start() async {
    if (_started || kIsWeb) return;
    _started = true;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handleUri(initial);
      }
    } on Object {
      // Ignore — plugin may be unavailable on desktop.
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _started = false;
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'billingbaba') return;
    final host = uri.host;
    final pathSegments = uri.pathSegments;
    String? token;

    if (host == 'import-contacts' && pathSegments.isNotEmpty) {
      token = pathSegments.first;
    } else if (pathSegments.length >= 2 &&
        pathSegments.first == 'import-contacts') {
      token = pathSegments[1];
    }

    if (token == null || token.isEmpty) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    GoRouter.of(context).push(AppRoutes.partyContactImport(token));
  }
}
