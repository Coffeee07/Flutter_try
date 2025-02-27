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

  Future<void> loadModel(
      {required String modelPath, required String labelPath}) async {
    try {
      // Load Model.
      _interpreter = await Interpreter.fromAsset(modelPath);
      // Load Labels.
      final labelsData = await rootBundle.loadString(labelPath);
      _labels = labelsData.split('\n');

      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load the model: $e');
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

    // Get the input and output shapes
    var outputShape = _interpreter.getOutputTensor(0).shape; // [1 = batchSize, 25200 = numPredictions, 8 = bbox(4) + confidence(1) + numClasses(3)]
    var inputShape = _interpreter.getInputTensor(0).shape; // [1 = batchSize, 640 = height, 640 = width, 3 = channels]

    final imageWidth = inputShape[2];
    final imageHeight = inputShape[1];
    final channels = inputShape[3];

    // Resize the image to 640 x 640
    final resizedImage = img.copyResize(inputImage, width: imageWidth, height: imageHeight);

    // Create the list of output and initialize its values to 0
    var output = List.filled(outputShape[0] * outputShape[1] * outputShape[2], 0);
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

        final classIndex = _argmax(classProb);
        final classConfidence = classProb[classIndex];

        if (confidence > 0.7 && classConfidence > 0.7) {
          final xmin = xCenter - width / 2;
          final ymin = yCenter - height / 2;
          final xmax = xCenter + width / 2;
          final ymax = yCenter + height / 2;

          allBoxes.add([
            xmin,
            ymin,
            xmax,
            ymax,
            confidence * classConfidence,
            classIndex.toDouble()
          ]);
        }
      }
    }

    final selectedBoxes = _nonMaxSupression(allBoxes, 0.5);
    return selectedBoxes;
  }

  int _argmax(List<double> list) {
    int maxIndex = 0;
    
    for (int i = 1; i < list.length; i++) {
      maxIndex = list[i] > list[maxIndex] ? i : maxIndex;
    }

    return maxIndex;
  }

  List<List<double>> _nonMaxSupression(
      List<List<double>> boxes, double iouThreshold) {
    boxes.sort((a, b) => b[4].compareTo(a[4]));

    List<List<double>> selectedBoxes = [];

    while (boxes.isNotEmpty) {
      final bestBox = boxes.removeAt(0);
      selectedBoxes.add(bestBox);

      boxes.removeWhere((box) => _iou(box, bestBox) > iouThreshold);
    }
    return selectedBoxes;
  }

  double _iou(List<double> boxA, List<double> boxB) {
    final xminA = boxA[0];
    final yminA = boxA[1];
    final xmaxA = boxA[2];
    final ymaxA = boxA[3];

    final xminB = boxB[0];
    final yminB = boxB[1];
    final xmaxB = boxB[2];
    final ymaxB = boxB[3];

    final interXmin = math.min(xminA, xminB);
    final interYmin = math.min(yminA, yminB);
    final interXmax = math.max(xmaxA, xmaxB);
    final interYmax = math.max(ymaxA, ymaxB);

    final interArea =
        math.max(0, interXmax - interXmin) * math.max(0, interYmax - interYmin);
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

      // Draw rectangle
      img.drawRect(decodedImage,
          x1: xmin,
          y1: ymin,
          x2: xmax,
          y2: ymax,
          color: img.ColorUint8.rgb(255, 0, 0),
          thickness: 5);
    }

    // Save the modified image back to the file
    final newImageFilePath =
        '${imageFile.parent.path}/modified_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newImageFile = File(newImageFilePath)
      ..writeAsBytesSync(img.encodeJpg(decodedImage));
    return newImageFile;
  }

  List<String> get labels => _labels;

  void dispose() {
    _interpreter.close();
  }
}
