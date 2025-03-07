import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const PodScanApp());
}

class PodScanApp extends StatelessWidget {
  const PodScanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home screen after 10 seconds
    Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF832637), // Updated background color
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/PODScan.png', // Updated logo path
              height: 120, // Slightly smaller logo size
            ),
            const SizedBox(width: 10), // Spacing between logo and text
            // Vertical line container
            Container(
              height: 50, // Height same as the text
              width: 2, // Width of the line
              color: Colors.white, // Color of the vertical line
            ),
            const SizedBox(width: 10), // Spacing between line and text
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36, // Slightly larger text size
                  fontWeight: FontWeight.normal,
                ),
                children: [
                  TextSpan(
                    text: 'POD',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Scan',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Screen (after Splash Screen)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Set the background image
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.png'), // Update with your image path
            fit: BoxFit.cover, // This will make the image cover the entire screen
          ),
        ),
        child: Center(
          child: Stack(
            children: [
              // Decorative corner borders (as you had them earlier)
              Positioned(
                top: 100,
                left: 30,
                child: Container(
                  width: 70,
                  height: 5,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: 100,
                left: 30,
                child: Container(
                  width: 5,
                  height: 70,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: 100,
                right: 30,
                child: Container(
                  width: 70,
                  height: 5,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: 100,
                right: 30,
                child: Container(
                  width: 5,
                  height: 70,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 80,
                left: 30,
                child: Container(
                  width: 70,
                  height: 5,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 80,
                left: 30,
                child: Container(
                  width: 5,
                  height: 70,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 80,
                right: 30,
                child: Container(
                  width: 70,
                  height: 5,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 80,
                right: 30,
                child: Container(
                  width: 5,
                  height: 70,
                  color: Colors.white,
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo - White Circle
                    Container(
                      width: 105, // Circle width
                      height: 105, // Circle height
                      decoration: BoxDecoration(
                        color: Colors.white, // White color for the circle
                        shape: BoxShape.circle, // Makes it a circle
                      ),
                    ),
                    const SizedBox(height: 10),
                    // App name
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.normal,
                        ),
                        children: [
                          TextSpan(
                            text: 'Pod',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: 'Scan'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Divider(
                      color: Colors.white,
                      thickness: 3,
                      indent: 50,
                      endIndent: 50,
                    ),
                    const SizedBox(height: 20),
                    // Buttons
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1E6BB), // Light yellow color
                        foregroundColor: Colors.black, // Text color
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8, // Retains the shadow
                        shadowColor: Colors.black.withOpacity(0.5), // Shadow color and opacity
                      ),
                      onPressed: () {
                        // Add functionality for "Take Photo"
                      },
                      child: const Text(
                        'Take Photo',
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,  // Makes text bold
                          fontSize: 20,  // Increases font size (adjust as needed)
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Add space between the buttons

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF628E6E), // Updated to the #f1e6bb color
                        foregroundColor: Colors.white, // Text color
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8, // Retains the shadow
                        shadowColor: Colors.white.withOpacity(0.5), // Shadow color and opacity
                      ),
                      onPressed: () {
                        // Add functionality for "Upload Photo"
                      },
                      child: const Text(
                        'Upload Photo',
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,  // Makes text bold
                          fontSize: 20,  // Increases font size (adjust as needed)
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}