import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges shell-level keyboard shortcuts to the mounted quick-create menu.
class QuickCreateMenuController {
  VoidCallback? _toggle;
  VoidCallback? _close;
  bool Function()? _isOpen;

  void register({
    required VoidCallback toggle,
    required VoidCallback close,
    required bool Function() isOpen,
  }) {
    _toggle = toggle;
    _close = close;
    _isOpen = isOpen;
  }

  void unregister() {
    _toggle = null;
    _close = null;
    _isOpen = null;
  }

  void toggle() => _toggle?.call();

  void close() => _close?.call();

  bool get isOpen => _isOpen?.call() ?? false;
}

final quickCreateMenuProvider =
    NotifierProvider<QuickCreateMenuNotifier, QuickCreateMenuController>(
      QuickCreateMenuNotifier.new,
    );

class QuickCreateMenuNotifier extends Notifier<QuickCreateMenuController> {
  @override
  QuickCreateMenuController build() => QuickCreateMenuController();

  void toggle() => state.toggle();

  void close() => state.close();

  bool get isOpen => state.isOpen;
}
