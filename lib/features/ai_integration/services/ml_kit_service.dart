import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
    return processDocumentImage(inputImage);
  }

  Future<String?> processDocumentImage(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text;

      // Relaxed keywords for demo version
      final lowercaseText = text.toLowerCase();
      final hasKeywords =
          lowercaseText.contains('id') ||
          lowercaseText.contains('card') ||
          lowercaseText.contains('name') ||
          text.length > 30; // Length as a fallback for demo

      if (text.length > 10 && hasKeywords) {
        return text;
      }
      return null;
    } catch (e) {
      return null;
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
