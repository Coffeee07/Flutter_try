import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

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

  Future<List<dynamic>> runInference(File imageFile) async {
    if (!_isLoaded) {
      throw Exception('Model is not loaded yet.');
    }

    // Read and decode the image
    final imageBytes = await imageFile.readAsBytes();
    final inputImage = img.decodeImage(imageBytes)!;
    
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

  List<List<double>> processOutput(List<dynamic> output) {
    List<List<double>> allBoxes = [];

    for (var predictions in output) {
      for (var prediction in predictions) {
        final xCenter = prediction[0];
        final yCenter = prediction[1];
        final width = prediction[2];
        final height = prediction[3];
        final confidence = prediction[4];
        final classProb = prediction.sublist(5);

        final classIndex = prediction[5] > prediction[6] ? 0 : 1;
        final classConfidence = classProb[classIndex];

        if (confidence > 0.5 && classConfidence > 0.5) {
          final xmin = xCenter - width / 2;
          final ymin = yCenter - height / 2;
          final xmax = xCenter + width / 2;
          final ymax = yCenter + height / 2;

          allBoxes.add([xmin, ymin, xmax, ymax, confidence * classConfidence, classIndex.toDouble()]);
        }
      }
    }

    final selectedBoxes = nonMaxSupression(allBoxes, 0.5);
    return selectedBoxes;
  }

  List<List<double>> nonMaxSupression(List<List<double>> boxes, double iouThreshold) {
    boxes.sort((a, b) => b[4].compareTo(a[4]));

    List<List<double>> selectedBoxes = [];

    while(boxes.isNotEmpty) {
      final bestBox = boxes.removeAt(0);
      selectedBoxes.add(bestBox);

      boxes.removeWhere((box) => iou(box, bestBox) > iouThreshold);
    }
    return selectedBoxes;
  }

  double iou(List<double> boxA, List<double> boxB) {
    final xminA = boxA[0]; final yminA = boxA[1];
    final xmaxA = boxA[2]; final ymaxA = boxA[3];

    final xminB = boxB[0]; final yminB = boxB[1];
    final xmaxB = boxB[2]; final ymaxB = boxB[3];

    final interXmin = math.min(xminA, xminB);
    final interYmin = math.min(yminA, yminB);
    final interXmax = math.max(xmaxA, xmaxB);
    final interYmax = math.max(ymaxA, ymaxB);

    final interArea = math.max(0, interXmax - interXmin) * math.max(0, interYmax - interYmin);
    final areaA = (xmaxA - xminA) * (ymaxA - yminA);
    final areaB = (xmaxB - xminB) * (ymaxB - yminB);

    return interArea / (areaA + areaB - interArea);
  }

  File drawBoundingBoxes(File imageFile, List<List<double>> boxes) {
    final imageBytes = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(imageBytes)!;

    for (var box in boxes) {
      final xmin = (box[0] * decodedImage.width).toInt();
      final ymin = (box[1] * decodedImage.height).toInt();
      final xmax = (box[2] * decodedImage.width).toInt();
      final ymax = (box[3] * decodedImage.height).toInt();
      final classIndex = box[5].toInt();

      print('Drawing box: ($xmin, $ymin, $xmax, $ymax)');

      // Draw rectangle
      img.drawRect(decodedImage, x1: xmin, y1: ymin, x2: xmax, y2: ymax, color: img.ColorUint8.rgb(255, 0, 0), thickness: 5);
    }

    // Save the modified image back to the file
    final newImageFilePath = '${imageFile.parent.path}/modified_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newImageFile = File(newImageFilePath)..writeAsBytesSync(img.encodeJpg(decodedImage));
    print('bounding box drawn and saved to:\n${newImageFile.path}');
    return newImageFile;
  }

  List<String> get labels => _labels;

  void dispose() {
    _interpreter.close();
  }
}