//main.dart
import 'package:flutter/material.dart';

import 'pages/splash_screen.dart';

void main() {
  runApp(const PodScanApp());
}

class PodScanApp extends StatelessWidget {
  const PodScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('main page');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}