import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DocumentRecognitionResult {
  final String? text;
  final String message;
  final bool isValid;
  final bool isAligned;

  DocumentRecognitionResult({
    this.text,
    required this.message,
    required this.isValid,
    this.isAligned = false,
  });
}

class FaceState {
  final bool isPresent;
  final double? smileProb;
  final double? leftEyeOpenProb;
  final double? rightEyeOpenProb;
  final double? headEulerAngleY; // Left/Right
  final double? headEulerAngleX; // Up/Down

  FaceState({
    required this.isPresent,
    this.smileProb,
    this.leftEyeOpenProb,
    this.rightEyeOpenProb,
    this.headEulerAngleY,
    this.headEulerAngleX,
  });
}

class MLKitService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  Future<String?> processDocument(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await processDocumentImage(inputImage);
    return result.text;
  }

  Future<DocumentRecognitionResult> processDocumentImage(
    InputImage inputImage,
  ) async {
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text;

      if (text.isEmpty) {
        return DocumentRecognitionResult(
          message: 'No document detected. Please align your ID card.',
          isValid: false,
        );
      }

      // Relaxed keywords for demo version
      final lowercaseText = text.toLowerCase();
      final hasKeywords =
          lowercaseText.contains('id') ||
          lowercaseText.contains('card') ||
          lowercaseText.contains('name') ||
          text.length > 50; // Increased threshold for better quality

      if (text.length < 20) {
        return DocumentRecognitionResult(
          message: 'Please move the document closer.',
          isValid: false,
        );
      }

      if (!hasKeywords) {
        return DocumentRecognitionResult(
          message: 'Invalid document type. Please use a valid ID card.',
          isValid: false,
        );
      }

      // Basic alignment check (text should be somewhat distributed)
      final isAligned = recognizedText.blocks.length >= 3;

      if (!isAligned) {
        return DocumentRecognitionResult(
          message: 'Align the document within the frame.',
          isValid: false,
        );
      }

      return DocumentRecognitionResult(
        text: text,
        message: 'Document recognized! Hold still...',
        isValid: true,
        isAligned: true,
      );
    } catch (e) {
      return DocumentRecognitionResult(
        message: 'Error scanning document. Please try again.',
        isValid: false,
      );
    }
  }

  Future<FaceState> detectFaceState(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) return FaceState(isPresent: false);

      final face = faces.first;
      return FaceState(
        isPresent: true,
        smileProb: face.smilingProbability,
        leftEyeOpenProb: face.leftEyeOpenProbability,
        rightEyeOpenProb: face.rightEyeOpenProbability,
        headEulerAngleY: face.headEulerAngleY,
        headEulerAngleX: face.headEulerAngleX,
      );
    } catch (e) {
      return FaceState(isPresent: false);
    }
  }

  void dispose() {
    _textRecognizer.close();
    _faceDetector.close();
  }
}
