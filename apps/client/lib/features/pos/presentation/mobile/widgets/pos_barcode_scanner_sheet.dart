import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/barcode_import_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// Shared barcode scanner layer for inline strip and full-screen modes.
///
/// [controller] must be created and disposed by the parent so the camera
/// session persists when switching between modes.
class PosBarcodeScannerLayer extends ConsumerStatefulWidget {
  const PosBarcodeScannerLayer({
    required this.controller,
    required this.scanLineProgress,
    required this.isFullScreen,
    required this.onClose,
    required this.onExpand,
    required this.onCollapse,
    super.key,
  });

  final MobileScannerController controller;
  final Animation<double> scanLineProgress;
  final bool isFullScreen;
  final VoidCallback onClose;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;

  @override
  ConsumerState<PosBarcodeScannerLayer> createState() =>
      _PosBarcodeScannerLayerState();
}

class _PosBarcodeScannerLayerState extends ConsumerState<PosBarcodeScannerLayer> {
  bool _isProcessing = false;
  bool _isHardwareMode = false;
  String? _lastBarcode;
  DateTime? _lastScanAt;
  final StringBuffer _barcodeBuffer = StringBuffer();

  static const _scanCooldown = Duration(milliseconds: 1500);
  static const _fullScreenWindowWidth = 280.0;
  static const _fullScreenWindowHeight = 180.0;
  static final _nonDigit = RegExp(r'\D');

  @override
  void dispose() {
    if (_isHardwareMode) {
      HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    }
    super.dispose();
  }

  void _setHardwareMode(bool hardware) {
    if (_isHardwareMode == hardware) return;

    if (hardware) {
      unawaited(widget.controller.stop());
      HardwareKeyboard.instance.addHandler(_onHardwareKey);
    } else {
      HardwareKeyboard.instance.removeHandler(_onHardwareKey);
      _barcodeBuffer.clear();
      unawaited(widget.controller.start());
    }

    setState(() => _isHardwareMode = hardware);
  }

  bool _onHardwareKey(KeyEvent event) {
    if (!_isHardwareMode) return false;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final isModifierHeld = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isAltPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (isModifierHeld) return false;

    final skipKeys = {
      LogicalKeyboardKey.tab,
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
    if (skipKeys.contains(event.logicalKey)) return false;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _barcodeBuffer.clear();
      return true;
    }

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_barcodeBuffer.isNotEmpty) {
          final current = _barcodeBuffer.toString();
          _barcodeBuffer
            ..clear()
            ..write(current.substring(0, current.length - 1));
        }
        return true;
      }
    }

    if (event is! KeyDownEvent) return false;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final barcode = _barcodeBuffer.toString().trim();
      _barcodeBuffer.clear();
      if (barcode.isNotEmpty) {
        unawaited(_processBarcode(barcode));
      }
      return true;
    }

    final character = event.character;
    if (character != null &&
        character.isNotEmpty &&
        character != '\n' &&
        character != '\r') {
      if (_nonDigit.hasMatch(character)) return true;
      _barcodeBuffer.write(character);
      return true;
    }

    return false;
  }

  bool _shouldProcess(String barcode) {
    final now = DateTime.now();
    if (_lastBarcode == barcode &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < _scanCooldown) {
      return false;
    }
    _lastBarcode = barcode;
    _lastScanAt = now;
    return true;
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || _isHardwareMode) return;

    final barcode = capture.barcodes
        .map((detected) => detected.rawValue?.trim())
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    await _processBarcode(barcode);
  }

  Future<void> _processBarcode(String barcode) async {
    if (barcode.isEmpty || !_shouldProcess(barcode)) return;
    if (_isProcessing) return;

    _isProcessing = true;
    unawaited(HapticFeedback.mediumImpact());

    try {
      final service = await ref.read(barcodeLookupServiceProvider.future);
      final result = await service.lookup(barcode);
      if (!mounted) return;

      if (!result.found) {
        _showNotFoundSnackBar();
        return;
      }

      final items = ref.read(inventoryItemListProvider);
      final engine = ref.read(inventorySearchEngineProvider);
      final inventoryItem = findInventoryItemByBarcodeOrQuery(
        engine,
        items.where((item) => item.type == ItemType.product),
        query: barcode,
      );

      if (inventoryItem == null) {
        _showNotFoundSnackBar();
        return;
      }

      final categories = ref.read(inventoryCategoriesProvider).value ?? const [];
      final categoryName =
          categoryNamesById(categories)[inventoryItem.categoryId] ??
          'Uncategorized';
      final posItem = mapInventoryItemToPosItem(
        inventoryItem,
        categoryName: categoryName,
      );
      ref.read(posCartProvider.notifier).addItem(posItem);
    } on Object {
      if (mounted) {
        _showNotFoundSnackBar();
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _showNotFoundSnackBar() {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('No item found for this barcode'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          duration: Duration(seconds: 2),
        ),
      );
  }

  Rect _stripScanWindow(Size size) {
    final windowWidth = size.width * 0.55;
    final windowHeight = size.height * 0.55;
    final left = (size.width - windowWidth) / 2;
    final top = (size.height - windowHeight) / 2;
    return Rect.fromLTWH(left, top, windowWidth, windowHeight);
  }

  Rect _fullScreenScanWindow(Size size) {
    final left = (size.width - _fullScreenWindowWidth) / 2;
    final top = (size.height - _fullScreenWindowHeight) / 2;
    return Rect.fromLTWH(
      left,
      top,
      _fullScreenWindowWidth,
      _fullScreenWindowHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final scanWindow = widget.isFullScreen
            ? _fullScreenScanWindow(size)
            : _stripScanWindow(size);

        return Stack(
          fit: StackFit.expand,
          children: [
            if (_isHardwareMode)
              const ColoredBox(
                color: Colors.white,
                child: _HardwareScannerPlaceholder(),
              )
            else
              MobileScanner(
                controller: widget.controller,
                scanWindow: scanWindow,
                onDetect: _onBarcodeDetected,
              ),
            if (!_isHardwareMode)
              if (widget.isFullScreen)
                _ScanWindowOverlay(
                  scanWindow: scanWindow,
                  scanLineProgress: widget.scanLineProgress,
                  showTopBottomOverlay: true,
                )
              else
                IgnorePointer(
                  child: CustomPaint(
                    painter: _StripScanWindowPainter(scanWindow: scanWindow),
                    size: size,
                  ),
                ),
            if (!_isHardwareMode && !widget.isFullScreen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onExpand,
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),
            if (widget.isFullScreen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _FullScreenTopBar(
                  controller: widget.controller,
                  isHardwareMode: _isHardwareMode,
                  onBack: widget.onCollapse,
                  onModeChanged: _setHardwareMode,
                ),
              )
            else ...[
              Positioned(
                top: AppSpacing.xs,
                left: 0,
                right: 0,
                child: Center(
                  child: _ScannerModeToggle(
                    isHardwareMode: _isHardwareMode,
                    onChanged: _setHardwareMode,
                    onDarkBackground: !_isHardwareMode,
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StripIconButton(
                      icon: Icons.open_in_full_rounded,
                      tooltip: 'Expand scanner',
                      onPressed: widget.onExpand,
                    ),
                    _StripIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Close scanner',
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
            ],
            if (widget.isFullScreen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _FullScreenBottomBar(onDone: widget.onClose),
              ),
          ],
        );
      },
    );
  }
}

class _ScannerModeToggle extends StatelessWidget {
  const _ScannerModeToggle({
    required this.isHardwareMode,
    required this.onChanged,
    this.onDarkBackground = false,
  });

  final bool isHardwareMode;
  final ValueChanged<bool> onChanged;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final shellColor = onDarkBackground
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.grey.shade200;
    final unselectedIconColor =
        onDarkBackground ? Colors.white70 : AppColors.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: shellColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleSegment(
              icon: Icons.barcode_reader,
              selected: isHardwareMode,
              onTap: () => onChanged(true),
              unselectedIconColor: unselectedIconColor,
            ),
            _ToggleSegment(
              icon: Icons.photo_camera_outlined,
              selected: !isHardwareMode,
              onTap: () => onChanged(false),
              unselectedIconColor: unselectedIconColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.unselectedIconColor,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color unselectedIconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 32,
          child: Icon(
            icon,
            size: AppIconSize.md,
            color: selected ? Colors.white : unselectedIconColor,
          ),
        ),
      ),
    );
  }
}

class _HardwareScannerPlaceholder extends StatelessWidget {
  const _HardwareScannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = Colors.grey.shade500;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 120,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Items Added',
              style: theme.textTheme.titleMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Connect a USB/Bluetooth barcode scanner',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripIconButton extends StatelessWidget {
  const _StripIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: AppIconSize.md),
        color: Colors.white,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _FullScreenTopBar extends StatelessWidget {
  const _FullScreenTopBar({
    required this.controller,
    required this.isHardwareMode,
    required this.onBack,
    required this.onModeChanged,
  });

  final MobileScannerController controller;
  final bool isHardwareMode;
  final VoidCallback onBack;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final barColor = isHardwareMode
        ? Colors.white
        : Colors.black.withValues(alpha: 0.5);
    final iconColor = isHardwareMode ? AppColors.textPrimary : Colors.white;

    return ColoredBox(
      color: barColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: iconColor,
                tooltip: 'Back to strip',
              ),
              Expanded(
                child: Center(
                  child: _ScannerModeToggle(
                    isHardwareMode: isHardwareMode,
                    onChanged: onModeChanged,
                    onDarkBackground: !isHardwareMode,
                  ),
                ),
              ),
              if (!isHardwareMode)
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: controller,
                  builder: (context, state, _) {
                    final torchOn = state.torchState == TorchState.on;
                    return IconButton(
                      onPressed: state.torchState == TorchState.unavailable
                          ? null
                          : () => unawaited(controller.toggleTorch()),
                      icon: Icon(
                        torchOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                      ),
                      color: torchOn ? AppColors.primary : Colors.white,
                      tooltip: torchOn
                          ? 'Turn flashlight off'
                          : 'Turn flashlight on',
                    );
                  },
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenBottomBar extends ConsumerWidget {
  const _FullScreenBottomBar({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(posCartProvider);
    final theme = Theme.of(context);

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${cartState.totalQty} items · ${_currencyFormat.format(cartState.subtotal)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: onDone,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdBorder,
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StripScanWindowPainter extends CustomPainter {
  _StripScanWindowPainter({required this.scanWindow});

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, AppRadius.smBorder.topLeft),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StripScanWindowPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow;
  }
}

class _ScanWindowOverlay extends StatelessWidget {
  const _ScanWindowOverlay({
    required this.scanWindow,
    required this.scanLineProgress,
    required this.showTopBottomOverlay,
  });

  final Rect scanWindow;
  final Animation<double> scanLineProgress;
  final bool showTopBottomOverlay;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: scanLineProgress,
        builder: (context, _) {
          return CustomPaint(
            painter: _ScanWindowPainter(
              scanWindow: scanWindow,
              scanLineProgress: scanLineProgress.value,
              showTopBottomOverlay: showTopBottomOverlay,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ScanWindowPainter extends CustomPainter {
  _ScanWindowPainter({
    required this.scanWindow,
    required this.scanLineProgress,
    required this.showTopBottomOverlay,
  });

  final Rect scanWindow;
  final double scanLineProgress;
  final bool showTopBottomOverlay;

  @override
  void paint(Canvas canvas, Size size) {
    if (showTopBottomOverlay) {
      final overlayPaint =
          Paint()..color = Colors.black.withValues(alpha: 0.45);
      canvas
        ..drawRect(
          Offset.zero & Size(size.width, scanWindow.top),
          overlayPaint,
        )
        ..drawRect(
          Offset(0, scanWindow.bottom) &
              Size(size.width, size.height - scanWindow.bottom),
          overlayPaint,
        );
    }

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, AppRadius.mdBorder.topLeft),
      borderPaint,
    );

    final lineY =
        scanWindow.top + (scanWindow.height * scanLineProgress).clamp(0, 1);
    final linePaint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(scanWindow.left + AppSpacing.sm, lineY),
      Offset(scanWindow.right - AppSpacing.sm, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanWindowPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow ||
        oldDelegate.scanLineProgress != scanLineProgress ||
        oldDelegate.showTopBottomOverlay != showTopBottomOverlay;
  }
}
