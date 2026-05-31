import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:discount_scanner/app_theme.dart';
import 'package:camera/camera.dart';
import 'package:discount_scanner/manual_price_entry_screen.dart';
import 'package:discount_scanner/result_screen.dart';
import 'package:discount_scanner/utils/text_parser.dart';
import 'package:discount_scanner/widgets/themed_scaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isBusy = false;
  bool _isNavigating = false;
  Timer? _navigationTimer;
  double? _detectedPrice;
  double? _detectedDiscount;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await _controller!.initialize();
      if (!mounted) {
        return;
      }
      _controller!.startImageStream(_processImage);
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  void _processImage(CameraImage image) {
    if (_isBusy || _isNavigating) {
      return;
    }
    _isBusy = true;

    final InputImageRotation rotation =
        InputImageRotationValue.fromRawValue(_cameras![0].sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final InputImageFormat format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final InputImageMetadata metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final InputImage inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );

    _textRecognizer
        .processImage(inputImage)
        .then((RecognizedText recognizedText) {
          final parsedResult = TextParser.parse(recognizedText.text);
          final price = parsedResult['price'];
          final discount = parsedResult['discount'];

          if (price != null) {
            setState(() => _detectedPrice = price);
          }
          if (discount != null) {
            setState(() => _detectedDiscount = discount);
          }

          if (_detectedPrice != null && _detectedDiscount != null) {
            _navigationTimer?.cancel();
            _navigateToResult(_detectedPrice!, _detectedDiscount!);
          } else if (_detectedPrice != null) {
            if (_navigationTimer == null || !_navigationTimer!.isActive) {
              _navigationTimer = Timer(const Duration(seconds: 2), () {
                if (_detectedPrice != null && _detectedDiscount == null) {
                  _navigateToManualDiscount(_detectedPrice!);
                }
              });
            }
          }
        })
        .whenComplete(() => _isBusy = false);
  }

  void _navigateToResult(double price, double discount) {
    if (_isNavigating) return;
    _isNavigating = true;
    _controller?.stopImageStream();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(price: price, discount: discount),
      ),
    ).then((_) => _resetState());
  }

  void _navigateToManualDiscount(double price) {
    if (_isNavigating) return;
    _isNavigating = true;
    _controller?.stopImageStream();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ManualPriceEntryScreen(initialPrice: price),
      ),
    ).then((_) => _resetState());
  }

  void _resetState() {
    _isNavigating = false;
    _detectedPrice = null;
    _detectedDiscount = null;
    _navigationTimer?.cancel();
    if (mounted) {
      _controller?.startImageStream(_processImage);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text('Scan Price Tag'),
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildViewfinderOverlay(),
          if (_isBusy) const LinearProgressIndicator(),
          _buildInfoPanel(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Positioned.fill(child: CameraPreview(_controller!));
  }

  Widget _buildViewfinderOverlay() {
    return CustomPaint(size: Size.infinite, painter: ViewfinderPainter());
  }

  Widget _buildInfoPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black.withValues(alpha: 0.42),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.center_focus_strong, color: AppTheme.amber),
                    SizedBox(width: 8),
                    Text(
                      'Point camera at a price tag',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem('Price', _detectedPrice, ''),
                    _buildInfoItem('Discount', _detectedDiscount, '%'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, double? value, String suffix) {
    final displayValue = value != null
        ? (suffix == '%' ? value.toInt().toString() : value.toStringAsFixed(2))
        : '---';

    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '$displayValue$suffix',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * 0.8,
        height: size.height * 0.3,
      ),
      const Radius.circular(12),
    );

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.48);
    final borderPaint = Paint()
      ..color = AppTheme.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(frame),
    );

    canvas.drawPath(path, backgroundPaint);
    canvas.drawRRect(frame, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
