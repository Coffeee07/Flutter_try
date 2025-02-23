import 'package:PODScan/models/yolov5s.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'nocacao.dart';
import 'hascacao.dart';

class AnalyzePage extends StatefulWidget {
  final File imageFile;
  final Yolov5sModel yoloModel;

  const AnalyzePage(
      {super.key, required this.yoloModel, required this.imageFile});

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  late File _currentImageFile;

  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _currentImageFile = widget.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF832637), // Match splash screen
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
              _buildAnalyzeButton(),
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

  // Builds the container to display the image.
  Widget _buildImageContainer(double screenHeight) {
    const borderColor = Colors.white;
    const borderThickness = 2.0;
    const borderToImagePadding = 0.0; // Padding inside the border.
    const borderRadius = 5.0;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        height: screenHeight * 0.50, // 50% of screen height
        width: double.infinity, // Full width
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: borderThickness,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(borderToImagePadding),
            child: FittedBox(
              fit: BoxFit.cover, // Ensures the image fills the container
              alignment: Alignment.center, // Centers the image
              child: Image.file(
                _currentImageFile,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builds the analyze button.
  Widget _buildAnalyzeButton() {
    const buttonColor = Color(0xFF628E6E); // Greenish color.
    const buttonTextColor = Colors.white;
    const buttonBorderRadius = 10.0;

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          elevation: 5,
        ),
        onPressed:
            _isAnalyzing ? null : _onAnalyzePressed, // Disable when analyzing
        child: Text(
          _isAnalyzing ? 'Analyzing...' : 'Analyze', // Change text dynamically
          style: const TextStyle(
            fontFamily: 'CinzelDecorative',
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _onAnalyzePressed() async {
    if (!widget.yoloModel.isLoaded) {
      print('Model is not yet loaded.');
      return;
    }

    setState(() {
      _isAnalyzing = true; // Show "Analyzing..."
    });

    print('Model is loaded and ready to analyze.');
    await _runInference();

    setState(() {
      _isAnalyzing = false; // Revert to "Analyze" after processing
    });
  }

  Future<void> _runInference() async {
    final results = await widget.yoloModel.runInference(_currentImageFile);

    List<List<double>> selectedBoxes = widget.yoloModel.processOutput(results);

    double maxConfidence = 0.0; // Default confidence

    for (var box in selectedBoxes) {
      double confidence = box[4]; // Assuming confidence score is at index 4
      if (confidence > maxConfidence) {
        maxConfidence = confidence;
      }
    }

    if (selectedBoxes.isEmpty) {
      // No cacao detected → Go to NoCacaoScreen, pass the max confidence (even if it's low)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoCacaoScreen(
            analyzedImage: _currentImageFile,
            confidence: maxConfidence, // Pass the confidence, even if it's 0
            yoloModel: widget.yoloModel,
          ),
        ),
      );
    } else {
      // Cacao detected → Draw bounding boxes
      final updatedImageFile =
          widget.yoloModel.drawBoundingBoxes(_currentImageFile, selectedBoxes);

      // Navigate to HasCacaoScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasCacaoScreen(
            analyzedImage: updatedImageFile,
            confidenceScore: maxConfidence,
            yoloModel: widget.yoloModel,
          ),
        ),
      );
    }
  }
}
