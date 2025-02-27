import 'package:PODScan/models/resnet50.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'home_screen.dart';
import 'results.dart';
import 'package:image/image.dart' as img;

class HasCacaoScreen extends StatelessWidget {
  final File analyzedImage;
  final List<double> result;

  const HasCacaoScreen({
    super.key,
    required this.analyzedImage,
    required this.result,
  });

  File _cropImage(File imageFile, List<double> result) {
    final imageBytes = imageFile.readAsBytesSync();

    img.Image originalImage = img.decodeImage(imageBytes)!;

    final xCenter = result[0];
    final yCenter = result[1];
    final bboxWidth = result[2];
    final bboxHeight = result[3];

    final x = ((xCenter - bboxWidth / 2) * originalImage.width).toInt();
    final y = ((yCenter - bboxHeight / 2) * originalImage.height).toInt();
    final w = (bboxWidth * originalImage.width).toInt();
    final h = (bboxHeight * originalImage.height).toInt();

    final croppedImage = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);

    // Save the modified image back to the file
    final croppedImagePath =
        '${imageFile.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final croppedImageFile = File(croppedImagePath)
      ..writeAsBytesSync(img.encodeJpg(croppedImage));
    return croppedImageFile;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF832637),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildImageContainer(screenHeight),
              const SizedBox(height: 20),
              _buildMessage(),
              const SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the header with the app logo and title.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 80.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(width: 8),
          _buildTitle(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 70,
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'CinzelDecorative',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'POD',
            style: TextStyle(color: Color(0xFF7ED957)),
          ),
          TextSpan(
            text: 'SCAN',
            style: TextStyle(color: Color(0xFFFFDE59)),
          ),
        ],
      ),
    );
  }

  // Builds the container to display the analyzed image with bounding boxes.
  Widget _buildImageContainer(double screenHeight) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        height: screenHeight * 0.50,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: FittedBox(
            fit: BoxFit.cover, // Ensures the image fills the container
            alignment:
                Alignment.center, // Centers the image inside the container
            child: Image.file(
              analyzedImage,
            ),
          ),
        ),
      ),
    );
  }

  // Builds the message showing "Cacao Detected"
  Widget _buildMessage() {
    return Center(
      child: Column(
        children: [
          Text(
            'Cacao Detected!',
            style: const TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence: ${(result[4] * 100).toStringAsFixed(2)}%',
            style: const TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Builds a continue and retry button for further action.
  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF628E6E), // Greenish
        foregroundColor: Colors.white,
        minimumSize: const Size(150, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
      ),
      onPressed: () async {
        File croppedImageFile = _cropImage(analyzedImage, result);
        List<double> resnetResult = (await ResNet50Model.runInference(croppedImageFile))[0] as List<double> ;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              cacaoVariety:
                  ResNet50Model.getClassFromResult(resnetResult), // Replace with actual data
              diseaseType:
                  "Disease Type Placeholder", // Replace with actual data
              pestType: "Pest Type Placeholder", // Replace with actual data
              severityLevel:
                  "Severity Level Placeholder", // Replace with actual data
              analyzedImage: Image.file(
                  analyzedImage), // Pass the image with bounding boxes
            ),
          ),
        );
      },
      child: const Text(
        'Continue',
        style: TextStyle(
          fontFamily: 'CinzelDecorative',
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF628E6E),
        foregroundColor: Colors.white,
        minimumSize: const Size(150, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
      ),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
          (route) => false, // Clears all previous routes
        );
      },
      child: const Text(
        'Retry',
        style: TextStyle(
          fontFamily: 'CinzelDecorative',
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centers the buttons
      children: [
        _buildRetryButton(context), // Retry Button
        const SizedBox(width: 15), // Space between buttons
        _buildContinueButton(context), // Continue Button
      ],
    );
  }
}
