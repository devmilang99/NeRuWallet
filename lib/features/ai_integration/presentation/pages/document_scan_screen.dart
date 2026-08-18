import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../services/ml_kit_service.dart';
import '../widgets/camera_view.dart';

class DocumentScanScreen extends StatefulWidget {
  final Function(String) onDocumentCaptured;

  const DocumentScanScreen({required this.onDocumentCaptured, super.key});

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen> {
  final MLKitService _mlKitService = MLKitService();
  bool _isProcessing = false;
  bool _isBusy = false;
  bool _isDocumentValid = false;
  String _feedbackMessage = 'Align your document within the frame.';
  int _consecutiveValidFrames = 0;
  static const int _requiredValidFrames = 5; // Increased for better stability

  Future<void> _handleImage(String path) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final text = await _mlKitService.processDocument(path);

    setState(() {
      _isProcessing = false;
    });

    if (text != null && text.isNotEmpty) {
      widget.onDocumentCaptured(text);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not detect text. Please ensure the document is clear and well-lit.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _processImageStream(InputImage inputImage) async {
    if (_isBusy || _isProcessing) return;
    _isBusy = true;

    try {
      final result = await _mlKitService.processDocumentImage(inputImage);
      debugPrint(
        'Stream processing result: ${result.message}, isValid: ${result.isValid}',
      );

      if (mounted) {
        setState(() {
          _isDocumentValid = result.isValid;
          _feedbackMessage = result.message;
        });
      }

      if (result.isValid && result.text != null) {
        _consecutiveValidFrames++;
        debugPrint(
          'Valid frames: $_consecutiveValidFrames/$_requiredValidFrames',
        );
        if (_consecutiveValidFrames >= _requiredValidFrames) {
          _isProcessing = true; // Stop stream processing
          debugPrint('Auto-capture triggered!');
          widget.onDocumentCaptured(result.text!);
        }
      } else {
        _consecutiveValidFrames = 0;
      }
    } catch (e) {
      debugPrint('Error processing stream: $e');
    } finally {
      _isBusy = false;
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
          title: 'Document Scan',
          instruction: _feedbackMessage,
          onImageCaptured: _handleImage,
          onImageStream: _processImageStream,
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
                    'Processing Document...',
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
        final rectWidth = width * 0.85;
        final rectHeight = rectWidth * 0.63; // ID card aspect ratio

        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
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
                        borderRadius: BorderRadius.circular(16),
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
                    color: _isDocumentValid ? Colors.green : Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
