import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ResNetVarietyModel {
  late Interpreter _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  ResNetVarietyModel();

  Future<void> loadModel({
    required String modelPath,
    required String labelPath,
  }) async {
    try {
      // Load model
      _interpreter = await Interpreter.fromAsset(modelPath);

      // Load labels
      final labelsData = await rootBundle.loadString(labelPath);
      _labels = labelsData.split('\n');

      _isLoaded = true;
    } catch (e) {
      print('Error loading ResNet Variety model: $e');
    }
  }

  bool get isLoaded => _isLoaded;

  Future<Map<String, dynamic>> runInference(
      File imageFile, List<double> bbox) async {
    if (!_isLoaded) {
      throw Exception('ResNet Variety model is not loaded yet.');
    }

    // Read and decode image
    final imageBytes = await imageFile.readAsBytes();
    final inputImage = img.decodeImage(imageBytes)!;

    // Convert normalized bbox to pixel values
    int x = (bbox[0] * inputImage.width).toInt();
    int y = (bbox[1] * inputImage.height).toInt();
    int width = ((bbox[2] - bbox[0]) * inputImage.width).toInt();
    int height = ((bbox[3] - bbox[1]) * inputImage.height).toInt();

    // Ensure bbox stays within image bounds
    x = x.clamp(0, inputImage.width - 1);
    y = y.clamp(0, inputImage.height - 1);
    width = width.clamp(1, inputImage.width - x);
    height = height.clamp(1, inputImage.height - y);

    // Crop the cacao region
    final croppedImage =
        img.copyCrop(inputImage, x: x, y: y, width: width, height: height);

    // Resize to 224x224
    final resizedImage = img.copyResize(croppedImage, width: 224, height: 224);

    // Normalize and convert to Float32
    var input = Float32List(224 * 224 * 3);
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixel(x, y);
        input[y * 224 * 3 + x * 3 + 0] = pixel.r / 255.0; // Red
        input[y * 224 * 3 + x * 3 + 1] = pixel.g / 255.0; // Green
        input[y * 224 * 3 + x * 3 + 2] = pixel.b / 255.0; // Blue
      }
    }

    // Add batch dimension
    var inputTensor = input.reshape([1, 224, 224, 3]);

    // Prepare output tensor
    var output = List.filled(1 * 3, 0.0).reshape([1, 3]);

    _interpreter.run(inputTensor, output);

    // Get predicted class and confidence
    final prediction = output[0] as List<double>;
    final predictedIndex =
        prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));
    final predictedClass = _labels[predictedIndex];
    final confidence = prediction[predictedIndex];

    return {
      'class': predictedClass,
      'confidence': confidence,
    };
  }

  void dispose() {
    _interpreter.close();
  }
}
