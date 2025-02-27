import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ResNet50Model {
  // Singleton instance
  static final ResNet50Model _instance = ResNet50Model._internal();

  // Private constructor for singleton
  ResNet50Model._internal();

  // Factory constructor to return the singleton instance
  factory ResNet50Model() {
    return _instance;
  }

  late Interpreter _interpreter;
  List<String> _classes = [];
  bool _isLoaded = false;

  static Future<void> loadModel({
    required String modelPath,
    required String labelPath,
  }) async {
    _instance._loadModel(modelPath: modelPath, labelPath: labelPath);
  }

  Future<void> _loadModel({
    required String modelPath,
    required String labelPath,
  }) async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      final classesData = await rootBundle.loadString(labelPath);
      _classes = classesData.split('\n');
      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load the model: $e');
    }
  }

  static String getClassFromResult(List<dynamic> probabilities) {
    double highestProb = probabilities[0];
    int highestProbIndex = 0;

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > highestProb) {
        highestProb = probabilities[i];
        highestProbIndex = i;
      }
    }

    return _instance._classes[highestProbIndex];
  }

  bool get isLoaded => _isLoaded;

  static Future<List<dynamic>> runInference(File imageFile) async {
    return _instance._runInference(imageFile);
  }

  Future<List<dynamic>> _runInference(File imageFile) async {
    if (!_isLoaded) {
      throw Exception('Model is not loaded yet.');
    }
    final imageBytes = await imageFile.readAsBytes();
    final inputImage = img.decodeImage(imageBytes)!;

    // Get the input and output shapes
    var outputShape = _interpreter.getOutputTensor(0).shape;
    var inputShape = _interpreter.getInputTensor(0).shape;

    final imageWidth = inputShape[2];
    final imageHeight = inputShape[1];
    final channels = inputShape[3];

    // Resize the image to 224 x 224
    final resizedImage = img.copyResize(inputImage, width: imageWidth, height: imageHeight);

    // Create the list of output and initialize its values to 0
    var output = List.filled(_classes.length, 0);
     // Create the list of input
     var input = Float32List(imageHeight * imageWidth * channels);

     // Populate the input list
     for (int y = 0; y < imageHeight; y++) {
      for (int x = 0; x < imageWidth; x++) {
        var pixel = resizedImage.getPixel(x, y);
        var index = (y * imageWidth + x) * channels;
        input[index] = pixel.r / 255.0; // Red
        input[index + 1] = pixel.g / 255.0; // Green
        input[index + 2] = pixel.b / 255.0; // Blue
      }
    }
    
    // Convert the lists to the shapes of the input and output
    var inputTensor = input.reshape(inputShape);
    var outputTensor = output.reshape(outputShape);

    // Run the model
    _interpreter.run(inputTensor, outputTensor);
    
    // Return the output
    return outputTensor;
  }

  void dispose() {
    _interpreter.close();
  }
}