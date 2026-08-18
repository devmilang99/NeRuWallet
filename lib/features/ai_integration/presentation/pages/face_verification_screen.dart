import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../services/ml_kit_service.dart';
import '../widgets/camera_view.dart';

enum LivenessStep { centerFace, blink, smile, turnLeft, turnRight, complete }

class FaceVerificationScreen extends StatefulWidget {
  final Function(bool) onFaceVerified;

  const FaceVerificationScreen({required this.onFaceVerified, super.key});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  final MLKitService _mlKitService = MLKitService();
  bool _isProcessing = false;
  bool _isBusy = false;

  LivenessStep _currentStep = LivenessStep.centerFace;
  double _stepProgress = 0.0;
  String _instruction = 'Center your face in the frame';

  // Detection state
  bool _hasBlinked = false;
  bool _isFaceAligned = false;

  Future<void> _processImageStream(InputImage inputImage) async {
    if (_isBusy || _isProcessing) return;
    _isBusy = true;

    try {
      final faceState = await _mlKitService.detectFaceState(inputImage);

      if (!faceState.isPresent) {
        _updateInstruction('No face detected. Please center your face.');
        if (mounted && _isFaceAligned) setState(() => _isFaceAligned = false);
        _isBusy = false;
        return;
      }

      // Check basic alignment for green border - Relaxed for demo
      final rotY = faceState.headEulerAngleY ?? 0;
      final rotX = faceState.headEulerAngleX ?? 0;
      final aligned = rotY.abs() < 25 && rotX.abs() < 25;
      if (mounted && _isFaceAligned != aligned) {
        setState(() => _isFaceAligned = aligned);
      }

      switch (_currentStep) {
        case LivenessStep.centerFace:
          if (rotY.abs() < 15) {
            _nextStep(LivenessStep.blink, 'Now, please blink your eyes');
          } else {
            _updateInstruction('Look straight at the camera');
          }
          break;

        case LivenessStep.blink:
          final leftEye = faceState.leftEyeOpenProb ?? 1.0;
          final rightEye = faceState.rightEyeOpenProb ?? 1.0;
          if (leftEye < 0.4 && rightEye < 0.4) {
            _hasBlinked = true;
          }
          if (_hasBlinked && leftEye > 0.5 && rightEye > 0.5) {
            _nextStep(LivenessStep.smile, 'Great! Now, give us a smile');
          }
          break;

        case LivenessStep.smile:
          final smile = faceState.smileProb ?? 0.0;
          if (smile > 0.4) {
            _nextStep(
              LivenessStep.turnLeft,
              'Almost there! Turn your head slowly to the left',
            );
          }
          break;

        case LivenessStep.turnLeft:
          if (rotY > 15) {
            _nextStep(
              LivenessStep.turnRight,
              'Now turn your head slowly to the right',
            );
          }
          break;

        case LivenessStep.turnRight:
          if (rotY < -15) {
            _nextStep(LivenessStep.complete, 'Verification complete!');
          }
          break;

        case LivenessStep.complete:
          if (!_isProcessing) {
            _isProcessing = true;
            widget.onFaceVerified(true);
          }
          break;
      }
    } catch (e) {
      debugPrint('Liveness error: $e');
    } finally {
      _isBusy = false;
    }
  }

  void _nextStep(LivenessStep step, String instruction) {
    if (mounted) {
      setState(() {
        _currentStep = step;
        _instruction = instruction;
        _stepProgress = (step.index) / (LivenessStep.values.length - 1);
      });
    }
  }

  void _updateInstruction(String instruction) {
    if (mounted && _instruction != instruction) {
      setState(() {
        _instruction = instruction;
      });
    }
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
          title: 'Liveness Test',
          instruction: _instruction,
          onImageCaptured: (_) {},
          onImageStream: _processImageStream,
          initialDirection: CameraLensDirection.front,
          overlay: _buildOverlay(),
        ),
        Positioned(
          top: 100,
          left: 40,
          right: 40,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _stepProgress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                borderRadius: BorderRadius.circular(10),
                minHeight: 10,
              ),
              const SizedBox(height: 8),
              Text(
                'Step ${(_currentStep.index + 1).clamp(1, 5)} of 5',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
                  Text('Finalizing...', style: TextStyle(color: Colors.white)),
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
                  border: Border.all(
                    color: _isFaceAligned ? Colors.green : Colors.white,
                    width: 3,
                  ),
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
