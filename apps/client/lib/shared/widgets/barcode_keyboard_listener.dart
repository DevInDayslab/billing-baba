import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Optional handle for restoring HID focus after a successful scan.
class BarcodeKeyboardController {
  _BarcodeKeyboardListenerState? _state;

  void requestFocus() => _state?.requestScannerFocus();

  void _attach(_BarcodeKeyboardListenerState state) => _state = state;

  void _detach(_BarcodeKeyboardListenerState state) {
    if (_state == state) _state = null;
  }
}

/// Listens for USB/Bluetooth HID barcode scanners in keyboard-wedge mode.
///
/// Scanners type characters then send Enter/Tab. This widget accumulates
/// printable characters and invokes [onBarcode] when a suffix key arrives.
///
/// Does **not** interfere with normal typing in [EditableText] fields when
/// [ignoreWhenEditableFocused] is true.
class BarcodeKeyboardListener extends StatefulWidget {
  const BarcodeKeyboardListener({
    required this.onBarcode,
    required this.child,
    super.key,
    this.enabled = true,
    this.autofocus = false,
    this.ignoreWhenEditableFocused = true,
    this.suffix = BarcodeScanSuffix.enterOrTab,
    this.focusNode,
    this.controller,
    this.minLength = 3,
  });

  final ValueChanged<String> onBarcode;
  final Widget child;
  final bool enabled;
  final bool autofocus;
  final bool ignoreWhenEditableFocused;
  final BarcodeScanSuffix suffix;
  final FocusNode? focusNode;
  final BarcodeKeyboardController? controller;
  final int minLength;

  @override
  State<BarcodeKeyboardListener> createState() =>
      _BarcodeKeyboardListenerState();
}

class _BarcodeKeyboardListenerState extends State<BarcodeKeyboardListener> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  final StringBuffer _buffer = StringBuffer();
  var _handlerAttached = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'barcodeHid');
    widget.controller?._attach(this);
    if (widget.enabled) {
      _attachHandler();
    }
    if (widget.autofocus && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.enabled) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant BarcodeKeyboardListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (widget.enabled && !_handlerAttached) {
      _attachHandler();
    } else if (!widget.enabled && _handlerAttached) {
      _detachHandler();
      _buffer.clear();
    }
    if (widget.autofocus && widget.enabled && !oldWidget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _detachHandler();
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _attachHandler() {
    if (_handlerAttached) return;
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
    _handlerAttached = true;
  }

  void _detachHandler() {
    if (!_handlerAttached) return;
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _handlerAttached = false;
  }

  /// Re-focus the HID listener after a successful scan (continuous scanning).
  void requestScannerFocus() {
    if (!widget.enabled) return;
    _focusNode.requestFocus();
  }

  bool _isEditableTextFocused() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null || !primaryFocus.hasFocus) return false;
    final focusContext = primaryFocus.context;
    if (focusContext == null) return false;
    return focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _onHardwareKey(KeyEvent event) {
    if (!widget.enabled) return false;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final isModifierHeld =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isAltPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (isModifierHeld) return false;

    if (widget.ignoreWhenEditableFocused && _isEditableTextFocused()) {
      return false;
    }

    final skipKeys = <LogicalKeyboardKey>{
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.f1,
      LogicalKeyboardKey.f2,
      LogicalKeyboardKey.f3,
      LogicalKeyboardKey.f4,
      LogicalKeyboardKey.f5,
      LogicalKeyboardKey.f6,
      LogicalKeyboardKey.f7,
      LogicalKeyboardKey.f8,
      LogicalKeyboardKey.f9,
      LogicalKeyboardKey.f10,
      LogicalKeyboardKey.f11,
      LogicalKeyboardKey.f12,
    };
    if (widget.suffix == BarcodeScanSuffix.enter) {
      skipKeys.add(LogicalKeyboardKey.tab);
    }
    if (skipKeys.contains(event.logicalKey)) return false;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _buffer.clear();
      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_buffer.isNotEmpty) {
        final current = _buffer.toString();
        _buffer
          ..clear()
          ..write(current.substring(0, current.length - 1));
      }
      return true;
    }

    if (event is! KeyDownEvent) return false;

    if (widget.suffix.matches(event.logicalKey)) {
      final barcode = _buffer.toString().trim();
      _buffer.clear();
      if (barcode.length >= widget.minLength) {
        widget.onBarcode(barcode);
      }
      return true;
    }

    final character = event.character;
    if (character != null &&
        character.isNotEmpty &&
        character != '\n' &&
        character != '\r' &&
        character != '\t') {
      final code = character.codeUnitAt(0);
      if (code >= 32 && code < 127) {
        _buffer.write(character);
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus && widget.enabled,
      canRequestFocus: widget.enabled,
      child: widget.child,
    );
  }
}
