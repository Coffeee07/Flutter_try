import 'package:flutter/material.dart';
import 'dart:typed_data'; // Import this for Uint8List

class CacaoDetectedScreen extends StatelessWidget {
  final Uint8List imageWithBoxes; // Accept the image with bounding boxes

  const CacaoDetectedScreen({Key? key, required this.imageWithBoxes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF832637), // Same as splash screen
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.memory(imageWithBoxes,
                      fit: BoxFit
                          .cover), // Display the image with bounding boxes
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cacao Detected!',
                style: TextStyle(
                  fontFamily: 'CinzelDecorative',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
