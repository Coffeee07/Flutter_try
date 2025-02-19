import 'dart:async';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.wait([
      _loadAssets(),
      _initializeAppSettings(),
    ]);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _loadAssets() async {
    // Simulate asset loading.
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> _initializeAppSettings() async {
    // Simulate settings initialization.
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF832637), // Set background color
      body: Center(child: _buildLogo()),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/PODScan.png',
          height: 120,
        ),
        const SizedBox(width: 10),
        _buildDivider(),
        const SizedBox(width: 10),
        _buildAppTitle(),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 2,
      color: Colors.white,
    );
  }

  Widget _buildAppTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'CinzelDecorative', // Apply custom font
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'POD',
            style: TextStyle(
              color: Color(0xFF7ED957), // Green color for "POD"
            ),
          ),
          TextSpan(
            text: 'SCAN',
            style: TextStyle(
              color: Color(0xFFFFDE59), // Yellow color for "SCAN"
            ),
          ),
        ],
      ),
    );
  }

}
