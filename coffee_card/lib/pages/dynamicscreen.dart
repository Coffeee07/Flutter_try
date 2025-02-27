import 'package:flutter/material.dart';
import 'package:PODScan/models/yolov5s.dart';
import 'dart:io';
import 'home_screen.dart';
import 'results.dart';

class DynamicCacaoScreen extends StatelessWidget {
  final File analyzedImage;
  final double confidenceScore;
  final Yolov5sModel yoloModel;
  final bool hasCacao;
  final bool hasPlastic;

  const DynamicCacaoScreen({
    super.key,
    required this.analyzedImage,
    required this.confidenceScore,
    required this.yoloModel,
    required this.hasCacao,
    required this.hasPlastic,
  });

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
              const SizedBox(height: 5),
              _buildMessage(),
              const SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

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
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: Image.file(analyzedImage),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    String message;
    if (!hasCacao) {
      message = 'No Cacao Detected';
    } else if (hasPlastic) {
      message = 'Cacao Detected with Plastic!';
    } else {
      message = 'Cacao Detected!';
    }

    return Center(
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Confidence: ${(confidenceScore * 100).toStringAsFixed(2)}%',
            style: const TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
          if (hasPlastic) ...[
            const SizedBox(height: 8),
            Center(
              // Centering the warning text
              child: Text(
                '⚠ Please remove the plastic before proceeding.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'CinzelDecorative',
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
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
            builder: (context) => HomeScreen(yoloModel: yoloModel),
          ),
          (route) => false,
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

  Widget _buildContinueButton(BuildContext context) {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              cacaoVariety: "Cacao Variety Placeholder",
              diseaseType: "Disease Type Placeholder",
              pestType: "Pest Type Placeholder",
              severityLevel: "Severity Level Placeholder",
              analyzedImage: Image.file(analyzedImage),
              yoloModel: yoloModel,
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRetryButton(context),
        const SizedBox(width: 15),
        if (hasCacao && !hasPlastic)
          _buildContinueButton(
              context), // Show Continue only if there's no plastic
      ],
    );
  }
}
