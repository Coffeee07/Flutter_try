import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Yolov5sModel {
  late Interpreter _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  Yolov5sModel();

  Future<void> loadModel({required String modelPath, required String labelPath}) async {
    try {
      // Load Model.
      _interpreter = await Interpreter.fromAsset(modelPath);
      // Load Labels.
      final labelsData = await rootBundle.loadString(labelPath);
      _labels = labelsData.split('\n');

      _isLoaded = true;
    } catch (e) {
      print('Error: $e');
    }
  }

  bool get isLoaded => _isLoaded;

  Future<List<dynamic>> runInference(img.Image inputImage) async {
    if (!_isLoaded) {
      throw Exception('Model is not loaded yet.');
    }
    
    // Resize the image to 640 x 640
    final resizedImage = img.copyResize(inputImage, width: 640, height: 640);

    var input = Float32List(640 * 640 * 3);
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixel(x, y);
        input[y * 640 * 3 + x * 3 + 0] = pixel.r / 255.0; // Red
        input[y * 640 * 3 + x * 3 + 1] = pixel.g / 255.0; // Green
        input[y * 640 * 3 + x * 3 + 2] = pixel.b / 255.0; // Blue
      }
    }

    // Add batch dimension
    var inputTensor = input.reshape([1, 640, 640, 3]);

    var output = List.filled(1 * 25200 * 7, 0).reshape([1, 25200, 7]);

    _interpreter.run(inputTensor, output);
    return output;
  }

  List<String> get labels => _labels;

  void dispose() {
    _interpreter.close();
  }
}