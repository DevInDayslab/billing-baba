import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:billing_baba/shared/utils/camera_availability.dart';
import 'package:billing_baba/shared/widgets/barcode_scan_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Shared barcode scanner strip for mobile POS.
///
/// Camera and HID both call [handleBarcodeScan] → POS cart add.
class PosBarcodeScannerLayer extends ConsumerStatefulWidget {
  const PosBarcodeScannerLayer({
    required this.controller,
    required this.onClose,
    super.key,
    this.preferHardwareScanner = false,
  });

  final MobileScannerController controller;
  final VoidCallback onClose;

  /// When true (item settings = USB scanner), open in HID mode by default.
  final bool preferHardwareScanner;

  @override
  ConsumerState<PosBarcodeScannerLayer> createState() =>
      _PosBarcodeScannerLayerState();
}

class _PosBarcodeScannerLayerState
    extends ConsumerState<PosBarcodeScannerLayer> {
  bool _isHardwareMode = false;
  bool? _cameraAvailable;
  final _cameraHandler = BarcodeScanHandler(
    debounce: BarcodeScanHandler.cameraDebounce,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_initializeCamera());
  }

  Future<void> _initializeCamera() async {
    final available = await isBarcodeCameraAvailable();
    if (!mounted) return;

    if (!available) {
      setState(() {
        _cameraAvailable = false;
        _isHardwareMode = true;
      });
      return;
    }

    final startHardware = widget.preferHardwareScanner;
    setState(() {
      _cameraAvailable = true;
      _isHardwareMode = startHardware;
    });
    if (!startHardware) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isHardwareMode) return;
        unawaited(widget.controller.start());
      });
    }
  }

  void _setHardwareMode(bool hardware) {
    if (_isHardwareMode == hardware) return;
    if (!hardware && _cameraAvailable != true) return;

    if (hardware) {
      unawaited(widget.controller.stop());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isHardwareMode) return;
        unawaited(widget.controller.start());
      });
    }

    setState(() => _isHardwareMode = hardware);
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isHardwareMode) return;

    final raw = capture.barcodes
        .map((detected) => detected.rawValue?.trim())
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (raw.isEmpty) return;
    await _processBarcode(raw, handler: _cameraHandler);
  }

  /// Shared entry for camera detects (HID is handled by the parent POS page).
  Future<void> processScannedBarcode(String barcode) =>
      _processBarcode(barcode, handler: _cameraHandler);

  Future<void> _processBarcode(
    String barcode, {
    required BarcodeScanHandler handler,
  }) async {
    await handleBarcodeScan(
      barcode,
      handler: handler,
      engine: ref.read(inventorySearchEngineProvider),
      items: ref.read(inventoryItemListProvider),
      onItemFound: (item, _) async {
        final categories =
            ref.read(inventoryCategoriesProvider).value ?? const [];
        final categoryName =
            categoryNamesById(categories)[item.categoryId] ?? 'Uncategorized';
        final posItem = mapInventoryItemToPosItem(
          item,
          categoryName: categoryName,
        );
        ref.read(posCartProvider.notifier).addItem(posItem);
        if (!mounted) return;
        showBarcodeAddedSnackBar(context, item.name);
      },
      onNotFound: (code) {
        if (!mounted) return;
        showBarcodeNotFoundSnackBar(context, code);
      },
    );
  }

  Rect _stripScanWindow(Size size) {
    final windowWidth = size.width * 0.78;
    final windowHeight = size.height * 0.72;
    final left = (size.width - windowWidth) / 2;
    final top = (size.height - windowHeight) / 2;
    return Rect.fromLTWH(left, top, windowWidth, windowHeight);
  }

  @override
  Widget build(BuildContext context) {
    // HID is owned by the parent POS page so camera + wedge share one listener.
    // Hardware mode only shows the placeholder UI.
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final scanWindow = _stripScanWindow(size);

        return Stack(
          fit: StackFit.expand,
          children: [
            if (_isHardwareMode)
              const ColoredBox(
                color: Colors.white,
                child: _HardwareScannerPlaceholder(),
              )
            else if (_cameraAvailable == null)
              const ColoredBox(color: Colors.black)
            else
              MobileScanner(
                controller: widget.controller,
                onDetect: _onBarcodeDetected,
                errorBuilder: (context, error) => _CameraScannerErrorState(
                  message:
                      error.errorDetails?.message ??
                      'Unable to access the camera.',
                  onRetry: () => unawaited(widget.controller.start()),
                ),
              ),
            if (!_isHardwareMode)
              IgnorePointer(
                child: CustomPaint(
                  painter: _StripScanWindowPainter(scanWindow: scanWindow),
                  size: size,
                ),
              ),
            Positioned(
              top: AppSpacing.xs,
              left: 0,
              right: 0,
              child: Center(
                child: _ScannerModeToggle(
                  isHardwareMode: _isHardwareMode,
                  cameraEnabled: _cameraAvailable == true,
                  onChanged: _setHardwareMode,
                  onDarkBackground: !_isHardwareMode,
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: _StripIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Close scanner',
                onPressed: widget.onClose,
              ),
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
    this.cameraEnabled = true,
    this.onDarkBackground = false,
  });

  final bool isHardwareMode;
  final bool cameraEnabled;
  final ValueChanged<bool> onChanged;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final shellColor = onDarkBackground
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.grey.shade200;
    final unselectedIconColor = onDarkBackground
        ? Colors.white70
        : AppColors.textSecondary;

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
              icon: Icons.photo_camera_outlined,
              selected: !isHardwareMode,
              onTap: cameraEnabled ? () => onChanged(false) : null,
              unselectedIconColor: unselectedIconColor,
            ),
            _ToggleSegment(
              icon: Icons.barcode_reader,
              selected: isHardwareMode,
              onTap: () => onChanged(true),
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
  final VoidCallback? onTap;
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
            color: onTap == null
                ? unselectedIconColor.withValues(alpha: 0.35)
                : (selected ? Colors.white : unselectedIconColor),
            size: 20,
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
        child: Text(
          'Scan with a USB/Bluetooth barcode scanner\n'
          'or type the code and press Enter',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: muted,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _CameraScannerErrorState extends StatelessWidget {
  const _CameraScannerErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white70,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySmallSize,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
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
