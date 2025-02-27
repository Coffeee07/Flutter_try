import 'package:flutter/material.dart';
import 'dart:io';
import 'home_screen.dart';

class NoCacaoScreen extends StatelessWidget {
  final File analyzedImage;
  final double confidence;

  const NoCacaoScreen({
    super.key,
    required this.analyzedImage,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF832637),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildImageContainer(screenHeight),
            const SizedBox(height: 20),
            _buildMessage(),
            const SizedBox(height: 20),
            _buildRetryButton(context),
          ],
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

  // Builds the container to display the analyzed image.
  Widget _buildImageContainer(double screenHeight) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        height: screenHeight * 0.50, // Dynamic height
        width: double.infinity, // Full width
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
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

  // Builds the message showing "No Cacao Detected"
  Widget _buildMessage() {
    return Center(
      child: Column(
        children: [
          Text(
            'No Cacao Detected',
            style: const TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence: ${confidence.toStringAsFixed(2)}%',
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

  // Builds the retry button.
  Widget _buildRetryButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF628E6E),
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
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
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
