import 'package:flutter/material.dart';
import 'dart:typed_data'; // Import this for Uint8List
// import 'dart:io'; // Import this for File

class NoCacaoScreen extends StatelessWidget {
  final Uint8List image; // Accept the image as Uint8List

  const NoCacaoScreen({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('no cacao page');
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 3, 1, 1), // Match splash and home screen
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Container(
              margin: const EdgeInsets.all(16),
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child:
                    Image.memory(image, fit: BoxFit.cover), // Display the image
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Cacao Detected',
              style: TextStyle(
                fontFamily: 'CinzelDecorative',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF628E6E),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
