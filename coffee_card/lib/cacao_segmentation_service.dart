import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';

class CacaoSegmentationService {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/optimized_modelv2.tflite');
      _isModelLoaded = true;
      debugPrint('TFLite model loaded successfully');
    } catch (e) {
      debugPrint('Failed to load TFLite model: $e');
    }
  }

  Future<File?> processImage(File inputImageFile) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    try {
      // Read the image
      final imageData = await inputImageFile.readAsBytes();
      final inputImage = img.decodeImage(imageData);
      
      if (inputImage == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      // Resize image to 192x192 (model input size)
      final resizedImage = img.copyResize(inputImage, width: 192, height: 192);
      
      // Prepare input: normalize to [0,1] and reshape to [1, 192, 192, 3]
      var input = List.generate(
        1,
        (_) => List.generate(
          192,
          (y) => List.generate(
            192,
            (x) {
              final pixel = resizedImage.getPixel(x, y);
              // Updated pixel access methods
              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            },
          ),
        ),
      );
      
      // Prepare output tensor
      var output = List.filled(1 * 192 * 192 * 1, 0.0).reshape([1, 192, 192, 1]);
      
      // Run inference
      _interpreter.run(input, output);
      
      // Convert output to binary mask
      final mask = img.Image(width: 192, height: 192);
      for (int y = 0; y < 192; y++) {
        for (int x = 0; x < 192; x++) {
          final value = output[0][y][x][0] > 0.5 ? 255 : 0;
          // Updated color creation
          mask.setPixel(x, y, img.ColorRgba8(value, value, value, 255));
        }
      }
      
      // Resize mask to original image size
      final resizedMask = img.copyResize(
        mask,
        width: inputImage.width,
        height: inputImage.height,
        interpolation: img.Interpolation.nearest,
      );
      
      // Apply mask to original image
      final maskedImage = img.Image(width: inputImage.width, height: inputImage.height);
      for (int y = 0; y < inputImage.height; y++) {
        for (int x = 0; x < inputImage.width; x++) {
          final originalPixel = inputImage.getPixel(x, y);
          final maskPixel = resizedMask.getPixel(x, y);
          
          // Updated pixel color access
          if (maskPixel.r > 127) {
            // Keep the original pixel if mask is white
            maskedImage.setPixel(x, y, originalPixel);
          } else {
            // Set black pixel if mask is black
            maskedImage.setPixel(x, y, img.ColorRgba8(0, 0, 0, 255));
          }
        }
      }
      
      // Save masked image to file
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/segmented_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final maskedImageFile = File(path);
      await maskedImageFile.writeAsBytes(img.encodePng(maskedImage));
      
      return maskedImageFile;
      
    } catch (e) {
      debugPrint('Error during image processing: $e');
      return null;
    }
  }

  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
    }
  }
}