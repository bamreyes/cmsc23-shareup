import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/features/profile/providers/profile_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final raw = barcode.rawValue!;

    // Expected QR format: "shareup:postId"
    if (!raw.startsWith('shareup:')) {
      _showError('Invalid QR code. Please scan a ShareUP pickup pass.');
      return;
    }

    final postId = raw.substring('shareup:'.length).trim();
    if (postId.isEmpty) {
      _showError('Invalid QR code format.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    await _controller.stop();

    final scannerId =
        context.read<ProfileProvider>().userId ?? '';

    final result = await context.read<ExchangeProvider>().completePostByQr(
          postId: postId,
          scannerId: scannerId,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      if (mounted) {
        context.read<ExchangeProvider>().fetchMyPosts(scannerId);
        
        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data ?? 'Exchange completed successfully!'),
            backgroundColor: AppColors.primary500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      _showError(result.error ?? 'Something went wrong.');
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });
      await _controller.start();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppHeader.back(
        title: 'Scan QR Code',
        onBack: () => context.pop(),
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          _buildScannerOverlay(context),

          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary500,
                strokeWidth: 3,
              ),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.primary500,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Point the camera at the\nowner\'s Pickup Pass',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The exchange will be marked complete automatically.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const cutoutSize = 260.0;
    final cutoutTop = (size.height - cutoutSize) / 2 - 60;

    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: _OverlayPainter(
            cutoutRect: Rect.fromLTWH(
              (size.width - cutoutSize) / 2,
              cutoutTop,
              cutoutSize,
              cutoutSize,
            ),
          ),
        ),
        Positioned(
          top: cutoutTop,
          left: (size.width - cutoutSize) / 2,
          child: _buildCorners(cutoutSize),
        ),
      ],
    );
  }

  Widget _buildCorners(double size) {
    const cornerSize = 24.0;
    const strokeWidth = 3.0;
    const color = AppColors.primary500;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: cornerSize,
              height: strokeWidth,
              color: color,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: strokeWidth,
              height: cornerSize,
              color: color,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: cornerSize,
              height: strokeWidth,
              color: color,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: strokeWidth,
              height: cornerSize,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: cornerSize,
              height: strokeWidth,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: strokeWidth,
              height: cornerSize,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: cornerSize,
              height: strokeWidth,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: strokeWidth,
              height: cornerSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect cutoutRect;

  const _OverlayPainter({required this.cutoutRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.cutoutRect != cutoutRect;
}