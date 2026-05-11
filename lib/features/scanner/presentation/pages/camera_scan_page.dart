// Wireframe 03-A: câmera fullscreen com bracket QR + tutorial overlay
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scan_bracket_painter.dart';
import '../widgets/nfce_result_bottom_sheet.dart';

class CameraScanPage extends ConsumerStatefulWidget {
  final bool showTutorial;
  const CameraScanPage({super.key, this.showTutorial = false});

  @override
  ConsumerState<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends ConsumerState<CameraScanPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final url = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (url == null) return;

    _handled = true;
    ref.read(scannerProvider.notifier).processQrCode(url);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerProvider);

    ref.listen(scannerProvider, (prev, next) {
      if (next.status == ScanStatus.success && next.result != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => NfceResultBottomSheet(
            result: next.result!,
            onConfirm: () {
              Navigator.of(context).pop();
              context.showSuccess('Itens prontos para dar entrada!');
              ref.read(scannerProvider.notifier).reset();
              context.pop();
            },
            onScanAgain: () {
              Navigator.of(context).pop();
              ref.read(scannerProvider.notifier).reset();
              setState(() => _handled = false);
            },
          ),
        );
      }

      if (next.status == ScanStatus.error) {
        context.showError(next.errorMessage ?? 'Erro ao processar NFC-e');
        ref.read(scannerProvider.notifier).reset();
        setState(() => _handled = false);
      }
    });

    final isProcessing = state.status == ScanStatus.processing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Dark vignette overlay with transparent bracket window
          CustomPaint(
            painter: _VignettePainter(),
            child: const SizedBox.expand(),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(scannerProvider.notifier).reset();
                      context.pop();
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),
                  const Text(
                    'Escanear NFC-e',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (_, value, __) => IconButton(
                      onPressed: () => _controller.toggleTorch(),
                      icon: Icon(
                        value.torchState == TorchState.on
                            ? Icons.flashlight_on
                            : Icons.flashlight_off,
                        color: value.torchState == TorchState.on
                            ? AppColors.accent
                            : Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bracket overlay centered
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: ScanBracketPainter(isActive: isProcessing),
              ),
            ),
          ),

          // Processing indicator
          if (isProcessing)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 260),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 12),
                  Text(
                    'Processando NFC-e…',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

          // Bottom hint
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Aponte para o QR Code da nota fiscal',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: Colors.white54),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'NFC-e (Nota Fiscal do Consumidor Eletrônica)',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const bracketSize = 240.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(
        center: Offset(cx, cy), width: bracketSize, height: bracketSize);

    final paint = Paint()..color = Colors.black.withOpacity(0.55);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_VignettePainter _) => false;
}
