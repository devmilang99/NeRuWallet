import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../services/ml_kit_service.dart';
import '../widgets/camera_view.dart';

class FaceVerificationScreen extends StatefulWidget {
  final Function(bool) onFaceVerified;

  const FaceVerificationScreen({super.key, required this.onFaceVerified});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  final MLKitService _mlKitService = MLKitService();
  bool _isProcessing = false;
  bool _isBusy = false;

  Future<void> _handleImage(String path) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final success = await _mlKitService.verifyFace(path);

    setState(() {
      _isProcessing = false;
    });

    widget.onFaceVerified(success);
  }

  Future<void> _processImageStream(InputImage inputImage) async {
    if (_isBusy || _isProcessing) return;
    _isBusy = true;

    final success = await _mlKitService.verifyFaceImage(inputImage);

    if (success) {
      _isProcessing = true; // Stop stream processing
      widget.onFaceVerified(true);
    }

    _isBusy = false;
  }

  @override
  void dispose() {
    _mlKitService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraView(
          title: 'Face Verification',
          instruction:
              'Look straight into the camera. It will capture automatically.',
          onImageCaptured: _handleImage,
          onImageStream: _processImageStream,
          initialDirection: CameraLensDirection.front,
          overlay: _buildOverlay(),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Verifying Face...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final rectWidth = width * 0.7;
        final rectHeight = rectWidth * 1.3;

        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                  Center(
                    child: Container(
                      width: rectWidth,
                      height: rectHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(rectWidth, rectHeight),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                width: rectWidth,
                height: rectHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(rectWidth, rectHeight),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
