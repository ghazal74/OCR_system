import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  static Future<String> extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String extractedText = recognizedText.text;
    textRecognizer.close();

    return extractedText;
  }
}
