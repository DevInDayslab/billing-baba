import 'dart:developer' as developer;

import 'package:flutter/material.dart';

/// Set to a bright color (e.g. [Colors.magenta]) to probe whether the white
/// margin around checkout is painted by the Flutter host. Hot-restart, open
/// checkout: magenta in the margin means Flutter; white unchanged means Razorpay.
/// Must be `null` in committed code.
const Color? kSubscriptionPaymentHostProbeColor = null;

/// Walks ancestors from [webViewContext] and logs whether each paints a background.
void auditSubscriptionPaymentHostTree({
  required BuildContext overlayContext,
  BuildContext? webViewContext,
}) {
  final lines = <String>[
    'Payment overlay host audit (route → WebView)',
    'Declared tree:',
    '  PageRouteBuilder(opaque: false, barrierColor: transparent)',
    '  └── FadeTransition',
    '      └── SubscriptionPaymentOverlay',
    '          └── Stack(expand)',
    '              ├── AnimatedModalBarrier → PAINTS dimmed scrim',
    '              └── Center',
    '                  └── ClipRRect(12) → clips only',
    '                      └── [probe layer if enabled]',
    '                      └── DesktopPaymentWebView',
    '                          └── WebViewWidget → native platform view',
    '',
    'Ancestor walk (WebView → route):',
  ];

  if (webViewContext == null) {
    lines.add('  (WebView context not mounted yet)');
  } else {
    final ancestors = <String>[];
    webViewContext.visitAncestorElements((element) {
      ancestors.add(_formatWidgetPaint(element.widget));
      return true;
    });
    if (ancestors.isEmpty) {
      lines.add('  (no ancestors)');
    } else {
      for (var i = 0; i < ancestors.length; i++) {
        lines.add('  ${i + 1}. ${ancestors[i]}');
      }
    }
  }

  final route = ModalRoute.of(overlayContext);
  if (route != null) {
    lines.add('');
    lines.add('Route: ${route.runtimeType}');
    lines.add('  opaque: ${route.opaque}');
    lines.add('  barrierColor: ${route.barrierColor}');
  }

  if (kSubscriptionPaymentHostProbeColor != null) {
    lines.add('');
    lines.add(
      'Host probe ACTIVE: $kSubscriptionPaymentHostProbeColor behind WebView. '
      'If margins turn this color, Flutter paints them; if they stay white, Razorpay does.',
    );
  }

  lines.add('');
  lines.add(
    'Note: WKWebView / WebView2 may paint an opaque native backing that is not '
    'a Flutter Material/ColoredBox. Parent-page DOM audit already showed the '
    'Razorpay iframe fills the WebView at 100%.',
  );

  developer.log(lines.join('\n'), name: 'subscription.checkout.host_audit');
}

String _formatWidgetPaint(Widget widget) {
  final type = widget.runtimeType.toString();

  if (widget is Material) {
  return '$type → PAINTS Material(color: ${widget.color}, type: ${widget.type}, elevation: ${widget.elevation})';
  }
  if (widget is ColoredBox) {
    return '$type → PAINTS ColoredBox(color: ${widget.color})';
  }
  if (widget is DecoratedBox) {
    return '$type → PAINTS DecoratedBox(${widget.decoration})';
  }
  if (widget is Container) {
    final details = <String>[];
    if (widget.color != null) {
      details.add('color: ${widget.color}');
    }
    if (widget.decoration != null) {
      details.add('decoration: ${widget.decoration.runtimeType}');
    }
    if (details.isNotEmpty) {
      return '$type → PAINTS Container(${details.join(', ')})';
    }
    return '$type → no background (Container)';
  }
  if (widget is Card) {
    return '$type → PAINTS Card(color: ${widget.color}, surfaceTint: ${widget.surfaceTintColor})';
  }
  if (widget is Scaffold) {
    return '$type → PAINTS Scaffold(backgroundColor: ${widget.backgroundColor})';
  }
  if (widget is Dialog) {
    return '$type → Dialog (surface usually via child Material)';
  }
  if (widget is SafeArea) {
    return '$type → SafeArea (layout only, no fill)';
  }
  if (widget is AnimatedModalBarrier) {
    return '$type → PAINTS AnimatedModalBarrier(scrim)';
  }
  if (widget is ModalBarrier) {
    return '$type → PAINTS ModalBarrier(color: ${widget.color})';
  }
  if (widget is ClipRRect) {
    return '$type → ClipRRect (clip only, no fill)';
  }
  if (widget is FadeTransition) {
    return '$type → FadeTransition (opacity only)';
  }
  if (widget is Stack || widget is Center || widget is SizedBox) {
    return '$type → no background';
  }

  return '$type → (no known background paint)';
}
