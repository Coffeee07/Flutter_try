//objectdetection.dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class ObjectDetectionService {
  Interpreter? interpreter;
  bool isInitialized = false;

  Future<void> initialize() async {
    try {
      final options = InterpreterOptions()..threads = 4;

      interpreter = await Interpreter.fromAsset(
        'assets/test-cacao-yolov5s-model.tflite',
        options: options,
      );

      // Print model details
      final inputShape = interpreter!.getInputTensor(0).shape;
      final outputShape = interpreter!.getOutputTensor(0).shape;
      print('Input Shape: $inputShape');
      print('Output Shape: $outputShape');

      print('Input Tensor Type: ${interpreter!.getInputTensor(0).type}');
      print('Output Tensor Type: ${interpreter!.getOutputTensor(0).type}');

      isInitialized = true;
      print('Model initialized successfully');
    } catch (e) {
      print('Error initializing model: $e');
      isInitialized = false;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> detectObjects(File imageFile) async {
    if (!isInitialized || interpreter == null) {
      throw Exception(
          'TFLite interpreter not initialized. Call initialize() first.');
    }

    try {
      // Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Get input size from model
      final inputShape = interpreter!.getInputTensor(0).shape;
      final inputSize = inputShape[1]; // Should be 640

      // Preprocess image
      final preprocessedImage = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
      );

      // Create a 4D input tensor [1, 640, 640, 3]
      var inputArray = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (_) => List.generate(
            inputSize,
            (_) => List.filled(3, 0.0),
          ),
        ),
      );

      // Fill the input tensor
      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final pixel = preprocessedImage.getPixel(x, y);
          inputArray[0][y][x][0] = img.getRed(pixel) / 255.0;
          inputArray[0][y][x][1] = img.getGreen(pixel) / 255.0;
          inputArray[0][y][x][2] = img.getBlue(pixel) / 255.0;
        }
      }

      final outputTensor = interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape; // Get the actual output shape
      print('Actual Output Shape: $outputShape');

      // Prepare output tensor
      final outputBuffer = List.generate(
        outputShape[0], // Usually 1 (batch size)
        (_) => List.generate(
          outputShape[1], // 25200 (number of predictions)
          (_) => List.filled(
              outputShape[2], 0.0), // 7 (box coordinates + confidence)
        ),
      );

      // Run inference
      interpreter!.run(inputArray, outputBuffer);

      // Process the outputs (implement your post-processing logic here)
      // For now, returning dummy data for testing
      return {
        'detections': [
          {
            'bbox': [0, 0, 100, 100],
            'score': 0.95,
            'class': 1
          }
        ],
        'imageWidth': image.width,
        'imageHeight': image.height,
      };
    } catch (e) {
      print('Error during detection: $e');
      rethrow;
    }
  }

  void dispose() {
    interpreter?.close();
    isInitialized = false;
  }
}
