import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:discount_scanner/manual_discount_screen.dart';
import 'package:discount_scanner/result_screen.dart';
import 'package:discount_scanner/utils/text_parser.dart';
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
  String _recognizedText = '';

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
        ResolutionPreset.high,
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

    final InputImageRotation rotation = InputImageRotationValue.fromRawValue(
            _cameras![0].sensorOrientation) ??
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

    _textRecognizer.processImage(inputImage).then((RecognizedText recognizedText) {
      setState(() {
        _recognizedText = recognizedText.text;
      });

      print('Recognized text: ${_recognizedText}');

      final parsedResult = TextParser.parse(recognizedText.text);
      final price = parsedResult['price'];
      final discount = parsedResult['discount'];

      print('Parsed result: price=$price, discount=$discount');

      if (price != null && discount != null) {
        _navigateToResult(price, discount);
      } else if (price != null) {
        _navigateToManualDiscount(price);
      }
    }).whenComplete(() => _isBusy = false);
  }

  void _navigateToResult(double price, double discount) {
    print('Navigating to ResultScreen with price=$price, discount=$discount');
    if (_isNavigating) return;
    _isNavigating = true;
    _controller?.stopImageStream();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(price: price, discount: discount),
      ),
    ).then((_) => _isNavigating = false);
  }

  void _navigateToManualDiscount(double price) {
    print('Navigating to ManualDiscountScreen with price=$price');
    if (_isNavigating) return;
    _isNavigating = true;
    _controller?.stopImageStream();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ManualDiscountScreen(price: price),
      ),
    ).then((_) => _isNavigating = false);
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Price Tag')),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _recognizedText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
