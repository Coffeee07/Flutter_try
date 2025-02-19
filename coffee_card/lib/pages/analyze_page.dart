import 'package:flutter/material.dart';
import 'dart:io';

class AnalyzePage extends StatelessWidget {
  final File image;

  const AnalyzePage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    print('analyze page');
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
              _buildImageContainer(image, screenHeight),
              const SizedBox(height: 20),
              _buildAnalyzeButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// Builds the header with the app logo and title.
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.only(left: 15.0, top: 50.0),
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
    'assets/PODScan.png',
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
Widget _buildImageContainer(File image, double screenHeight) {
  const borderColor = Colors.white;
  const borderThickness = 2.0;
  const  borderToImagePadding = 8.0; // Padding inside the border.
  const borderRadius = 5.0;

  return Center(
    child: Container(
      margin: const EdgeInsets.all(16),
      height: screenHeight * 0.5, // 50% of screen height
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
          child: Image.file(
            image,
            fit: BoxFit.contain, // Maintains the aspect ratio while clamping the height.
          ),
        ),
      ),
    ),
  );
}

// Builds the analyze button.
Widget _buildAnalyzeButton() {
  const buttonColor = Color(0xFF628E6E); // greenish.
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
      onPressed: _onAnalyzePressed,
      child: const Text(
        'Analyze',
        style: TextStyle(fontSize: 18),
      ),
    ),
  );
}

void _onAnalyzePressed() {
  // Add analysis logic here.
  print('analyzing...');
}