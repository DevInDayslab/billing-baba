import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/barcode_confidence.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/barcode_scanner_viewfinder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// How the scanner should behave after a barcode is detected.
enum MobileBarcodeScannerMode {
  /// Returns the scanned barcode to the caller via [Navigator.pop].
  single,

  /// Keeps scanning and invokes the [onBarcodeDetected] callback for each unique barcode.
  continuous,
}

/// Full-screen camera barcode scanner with viewfinder overlay.
class MobileBarcodeScannerScreen extends StatefulWidget {
  const MobileBarcodeScannerScreen({
    this.mode = MobileBarcodeScannerMode.single,
    this.onBarcodeDetected,
    super.key,
  });

  final MobileBarcodeScannerMode mode;
  final ValueChanged<String>? onBarcodeDetected;

  @override
  State<MobileBarcodeScannerScreen> createState() =>
      _MobileBarcodeScannerScreenState();
}

class _MobileBarcodeScannerScreenState
    extends State<MobileBarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.itf14,
    ],
  );

  bool _torchEnabled = false;
  bool _isProcessing = false;
  String? _lastScannedValue;
  DateTime? _lastScanAt;
  Rect? _scanWindow;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  Rect _resolveScanWindow(Size size) {
    final width = size.width * 0.82;
    final height = width * 0.62;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.48),
      width: width,
      height: height,
    );
  }

  String? _sanitizeBarcode(String raw) {
    final normalized = BarcodeConfidence.normalize(raw);
    if (normalized.length < 3) return null;
    return normalized;
  }

  bool _shouldAcceptScan(String barcode) {
    final now = DateTime.now();
    if (_lastScannedValue == barcode &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(seconds: 2)) {
      return false;
    }
    return true;
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final raw = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .map((value) => value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (raw.isEmpty) return;

    final barcode = _sanitizeBarcode(raw);
    if (barcode == null) return;
    if (!_shouldAcceptScan(barcode)) return;

    _lastScannedValue = barcode;
    _lastScanAt = DateTime.now();
    _isProcessing = true;

    await HapticFeedback.mediumImpact();

    if (!mounted) return;

    switch (widget.mode) {
      case MobileBarcodeScannerMode.single:
        Navigator.of(context).pop(barcode);
      case MobileBarcodeScannerMode.continuous:
        widget.onBarcodeDetected?.call(barcode);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          setState(() => _isProcessing = false);
        }
    }
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (!mounted) return;
    setState(
      () => _torchEnabled = _controller.value.torchState == TorchState.on,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            _scanWindow = _resolveScanWindow(size);

            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  scanWindow: _scanWindow,
                  onDetect: _handleDetection,
                  errorBuilder: (context, error) => _ScannerErrorState(
                    message:
                        error.errorDetails?.message ??
                        'Unable to access the camera.',
                    onRetry: () => unawaited(_controller.start()),
                  ),
                ),
                if (_scanWindow != null)
                  BarcodeScannerViewfinder(scanWindow: _scanWindow!),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoBanner(),
                    ],
                  ),
                ),
                Positioned(
                  right: AppSpacing.lg,
                  bottom: AppSpacing.xl + 8,
                  child: _TorchButton(
                    enabled: _torchEnabled,
                    onPressed: _toggleTorch,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
          const Spacer(),
          _CameraStatusBadge(isActive: _controller.value.isInitialized),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Text(
            'Please wait while the application detects the barcode. '
            'This might take a few moments.',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: AppTypography.bodySmallSize,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraStatusBadge extends StatelessWidget {
  const _CameraStatusBadge({required this.isActive});

  final bool isActive;

  static const _statusGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? _statusGreen : Colors.grey.shade700,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.photo_camera_outlined,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            enabled
                ? Icons.flashlight_on_rounded
                : Icons.flashlight_off_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _ScannerErrorState extends StatelessWidget {
  const _ScannerErrorState({
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
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodyMediumSize,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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

/// Opens the barcode scanner and returns the scanned value, or null if dismissed.
Future<String?> showMobileBarcodeScanner(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => const MobileBarcodeScannerScreen(),
    ),
  );
}
