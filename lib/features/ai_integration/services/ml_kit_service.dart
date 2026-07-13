import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MLKitService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<String?> processDocument(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return processDocumentImage(inputImage);
  }

  Future<String?> processDocumentImage(InputImage inputImage) async {
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    String text = recognizedText.text;
    if (text.isEmpty) return null;

    return text;
  }

  Future<bool> verifyFace(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return verifyFaceImage(inputImage);
  }

  Future<bool> verifyFaceImage(InputImage inputImage) async {
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) return false;

    final face = faces.first;

    final double? rotY = face.headEulerAngleY;
    final double? rotZ = face.headEulerAngleZ;

    if (rotY != null && (rotY > 10 || rotY < -10)) return false;
    if (rotZ != null && (rotZ > 10 || rotZ < -10)) return false;

    if (face.leftEyeOpenProbability != null &&
        face.leftEyeOpenProbability! < 0.5) {
      return false;
    }
    if (face.rightEyeOpenProbability != null &&
        face.rightEyeOpenProbability! < 0.5) {
      return false;
    }

    return true;
  }

  void dispose() {
    _textRecognizer.close();
    _faceDetector.close();
  }
}
